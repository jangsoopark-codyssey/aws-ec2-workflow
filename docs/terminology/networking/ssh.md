# Secure Shell (SSH)

## 개요

SSH는 암호화된 연결로 원격 서버에 로그인하고 명령을 실행하는 프로토콜이다. 기본적으로 TCP 22를 사용한다. EC2 Linux 인스턴스 관리에 사용할 수 있다.

## 역할과 동작 방식

서버의 호스트 키로 접속 대상의 신원을 확인하고, 사용자 인증 후 암호화된 세션을 연다. 공개 키 인증에서는 서버에 등록된 공개 키에 대응하는 개인 키를 클라이언트가 보유해야 한다. 개인 키 자체를 서버에 업로드하는 방식이 아니다.

## EC2 실습에서의 사용

다음은 macOS/Linux의 OpenSSH 클라이언트에서 실행할 수 있는 **형식 예시**이다. 키 경로와 주소를 실제 값으로 바꾸고, AMI에 맞는 사용자 이름을 선택한다.

```sh
chmod 400 /path/to/key.pem
ssh -i /path/to/key.pem ec2-user@<public-ip>
```

Amazon Linux는 일반적으로 `ec2-user`, Ubuntu는 `ubuntu`를 사용한다. 첫 연결에서는 서버 호스트 키 지문을 신뢰할 수 있는 경로로 확인한다. 위 명령은 예시이며 실제 접속 수행 결과가 아니다.

## 접속 문제 확인

- **시간 초과**: 공인 주소, 인터넷 경로, 보안 그룹의 TCP 22 출발지 허용, Network ACL과 로컬 네트워크를 확인한다.
- **Connection refused**: 서버의 SSH 서비스 실행 상태와 수신 포트, 방화벽 거부 여부를 확인한다.
- **Permission denied (publickey)**: AMI의 사용자 이름, 개인 키와 등록된 공개 키의 대응 관계를 확인한다.

## 주의사항

SSH 출발지는 `<your-ip>/32`처럼 필요한 범위로 제한한다. 개인 키를 Git에 커밋하거나 문서에 넣지 않는다. 호스트 키가 바뀌었다는 경고가 나오면 서버 교체 여부를 확인하고, 검증 없이 호스트 키 검사를 끄지 않는다. IAM API 권한과 Linux 로그인 권한은 구분한다.

## 관련 용어

- [EC2](../aws/ec2.md)
- [IAM](../aws/iam.md)
- [Route Table](route-table.md)

[용어 요약으로 돌아가기](../../terminology.md)

## 참고 자료

- [AWS 공식 문서](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/connect-linux-inst-ssh.html)
