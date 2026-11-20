# HTTPS 적용 기록

## 목적

도메인이 없는 실습 EC2에 HTTPS를 적용하고, Draft의 노트 생성 기능이 공인 IP의 HTTP 주소에서 실패하는 문제를 해결했다. Let’s Encrypt에서 EC2의 공인 IPv4 주소를 대상으로 단기 인증서를 발급하고 NGINX 컨테이너에 적용했다.

실습 당시 Certbot 버전은 `5.10.0`이었으며, 인증서의 유효기간은 약 6일(160시간)이었다. IP 주소 인증서가 단기 인증서로 발급되는 것은 Let’s Encrypt의 `shortlived` 프로필 정책에 따른다. [Let’s Encrypt 인증서 프로필](https://letsencrypt.org/docs/profiles/)

## 적용 전 구성

- Ubuntu EC2에서 Docker로 `draft-web` NGINX 컨테이너 실행
- 컨테이너 이미지: `draft-web:1.0`
- HTTP 서비스 포트: TCP 80
- Security Group 인바운드:
  - TCP 22: 관리자 공인 IP만 허용
  - TCP 80: 웹 접속 및 인증 검증을 위해 허용
  - TCP 443: HTTPS 접속을 위해 허용
- 도메인 이름과 Elastic IP는 사용하지 않음
- NGINX 상태 확인 경로: `/health`
- Draft 경로: `/Draft/`

> Security Group에서 TCP 80과 443을 허용하고, 인스턴스가 외부에서 접근 가능한 공인 IPv4 주소를 가지고 있어야 한다. 공인 IP는 인스턴스 중지 후 다시 시작할 때 바뀔 수 있다.

## 적용 스크립트

전 과정을 자동화한 스크립트는 [`scripts/enable-https-ip.sh`](../scripts/enable-https-ip.sh)이다. 이 스크립트는 프로젝트 루트에 `Draft/`와 `docker/`가 있는 구성 또는 홈 디렉터리에 `~/Draft`와 `~/docker`가 있는 구성을 지원한다.

저장소 디렉터리에서 실행한다.

```bash
chmod +x ./scripts/enable-https-ip.sh
./scripts/enable-https-ip.sh
```

스크립트는 `sudo -n true`로 비밀번호 입력 없이 sudo를 사용할 수 있는지 확인한다. 이 명령은 성공해도 출력이 없는 것이 정상이며, 종료 코드가 0이면 통과한 것이다.

## 수행한 과정

### 1. Certbot 설치 및 버전 확인

스크립트는 `snapd`가 없으면 설치하고, Snap으로 Certbot을 설치하거나 기존 설치를 갱신한다. 설치된 Certbot이 최소 요구 버전 `5.4.0` 이상인지 확인한다. 실습에서 확인한 버전은 `5.10.0`이다.

### 2. 공인 IP 확인

스크립트가 `https://checkip.amazonaws.com`에 요청해 인스턴스의 현재 공인 IPv4 주소를 확인한다. 이 IP가 인증서 이름과 NGINX 접속 주소로 사용된다.

### 3. IP 주소 인증서 발급

인증서가 아직 없으면 이메일 주소를 입력한다. Certbot은 standalone 방식으로 HTTP 검증을 수행한다. TCP 80 포트를 사용하기 위해 실행 중인 `draft-web` 컨테이너를 잠시 중지하고, 발급 절차가 실패하면 기존 컨테이너를 다시 시작하도록 구성되어 있다.

주요 발급 옵션은 다음과 같다.

```text
certbot certonly
  --standalone
  --preferred-profile shortlived
  --ip-address <EC2_PUBLIC_IP>
```

인증서와 개인 키의 경로는 다음 형식이다.

```text
/etc/letsencrypt/live/<EC2_PUBLIC_IP>/fullchain.pem
/etc/letsencrypt/live/<EC2_PUBLIC_IP>/privkey.pem
```

인증서의 개인 키(`privkey.pem`)는 외부에 공개하거나 Git 저장소에 올리지 않는다.

### 4. NGINX HTTPS 설정 및 컨테이너 재생성

스크립트는 NGINX 설정을 작성하고 Docker 이미지를 다시 빌드한다.

- TCP 80의 `/health` 요청은 `200 OK`와 `healthy`를 반환
- 그 외 HTTP 요청은 HTTPS 주소로 리다이렉트
- TCP 443에서 TLS 1.2 및 TLS 1.3 사용
- 인증서 디렉터리 `/etc/letsencrypt`를 컨테이너에 읽기 전용으로 마운트
- 새 컨테이너의 NGINX 설정 검증 후 `draft-web` 컨테이너 실행
- 컨테이너 재시작 정책은 `unless-stopped`

실습 당시 NGINX 설정 검사에서 문법 오류가 없음을 확인했다.

### 5. 인증서 자동 갱신 구성

인증서 유효기간이 약 6일이므로 자동 갱신을 설정했다.

- 갱신 서비스: `draft-certbot-renew.service`
- 갱신 확인 타이머: `draft-certbot-renew.timer`
- 타이머 확인 주기: 12시간
- 갱신 전 Hook: 인증서 검증을 위해 `draft-web` 컨테이너 중지
- 갱신 후 Hook: 컨테이너 재시작
- `certbot renew --dry-run`으로 갱신 모의 시험 수행

Certbot 기본 타이머와 사용자 정의 타이머가 함께 실행되면 Certbot이 동시에 두 번 시작될 수 있다. 스크립트는 기본 Snap 갱신 타이머와 기존 `draft-certbot-renew.timer`를 비활성화한 뒤 사용자 정의 타이머 하나를 등록한다.

## 적용 후 검증

브라우저에서 Draft를 HTTPS로 열고, HTTP 상태 확인 경로도 유지되는지 확인한다.

```text
https://<EC2_PUBLIC_IP>/Draft/#/notes
http://<EC2_PUBLIC_IP>/health
```

인스턴스에서 다음 명령으로 컨테이너와 타이머 상태를 확인할 수 있다.

```bash
docker ps
sudo systemctl status draft-certbot-renew.timer
sudo systemctl list-timers draft-certbot-renew.timer
sudo certbot renew --dry-run
```

실습에서는 HTTPS 접속과 노트 생성, `/health` 응답, Certbot 갱신 모의 시험 성공을 확인했다.

## 트러블슈팅 기록

### Certbot이 이미 실행 중이라는 메시지

**증상**

```text
Another instance of Certbot is already running.
```

**원인**

기존 Certbot 타이머와 수동 명령 또는 새 갱신 타이머가 겹쳐 실행된 경우 발생할 수 있다.

**조치**

현재 실행 중인 Certbot 작업이 끝났는지 확인하고, 갱신 타이머가 중복으로 활성화되어 있는지 점검했다. 사용자 정의 갱신 타이머 하나만 사용하도록 설정한 뒤 다음 명령으로 갱신을 모의 시험했다.

```bash
sudo certbot renew --dry-run
sudo systemctl status draft-certbot-renew.timer
```

실습에서는 재시도 결과 모의 갱신이 성공했다.

### Draft에서 노트 생성 시 `crypto.randomUUID is not a function`

**증상**

HTTP 공인 IP 주소로 접속한 Draft에서 노트를 생성할 때 다음 오류가 발생했다.

```text
Uncaught TypeError: crypto.randomUUID is not a function
```

**원인**

`crypto.randomUUID()`는 보안 컨텍스트에서만 사용할 수 있는 브라우저 API다. 공인 IP의 일반 HTTP 페이지는 보안 컨텍스트가 아니므로 API를 사용할 수 없었다. [MDN: Crypto.randomUUID()](https://developer.mozilla.org/en-US/docs/Web/API/Crypto/randomUUID)

**조치 및 결과**

IP 주소 인증서를 발급하고 NGINX에 HTTPS를 적용했다. 이후 HTTPS 주소로 접속해 노트 생성 기능이 동작하는 것을 확인했다.

## 운영 시 주의사항

- IP 주소 인증서는 약 6일(160시간)만 유효하므로 자동 갱신 타이머를 유지한다.
- 갱신 타이머와 Certbot 수동 실행을 동시에 시작하지 않는다.
- 인스턴스 공인 IP가 바뀌면 기존 인증서의 IP와 실제 접속 주소가 일치하지 않을 수 있다. 새 IP에 맞는 인증서를 발급한다.
- 실습에서는 Elastic IP를 사용하지 않았다.
- 인증서와 개인 키 파일을 저장소에 포함하지 않는다.
- 실습 종료 시 EC2와 관련 AWS 리소스를 삭제했으므로, 현재 인증서와 타이머는 실행 중인 서버에 남아 있지 않다.

## 참고 자료

- [Let’s Encrypt: Certificate Profiles](https://letsencrypt.org/docs/profiles/)
- [Let’s Encrypt: Six-Day and IP Address Certificates Available in Certbot](https://letsencrypt.org/2026/03/11/shorter-certs-certbot/)
- [Certbot documentation](https://eff-certbot.readthedocs.io/)
- [MDN: Crypto.randomUUID()](https://developer.mozilla.org/en-US/docs/Web/API/Crypto/randomUUID)

