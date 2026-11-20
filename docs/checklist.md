# Checklist

## Todo

### 1. 계정 및 실습 환경 준비
- [x] AWS 계정 보유 여부 확인
  - 기존 계정이 있으면 해당 계정 사용
  - 계정이 없으면 신규 계정 생성
- [x] 루트 계정 보안 설정
  - MFA 활성화
  - 실습 리소스 작업에는 루트 계정 사용 금지
- [x] 실습용 IAM 사용자 또는 역할 준비
  - EC2, VPC, Security Group 구성에 필요한 권한 부여
  - AdministratorAccess 권한 부여 금지
- [x] ~~과금 알림 및 프리티어 적용 여부 확인~~
- [x] 리전을 서울(ap-northeast-2)로 설정

---

### 2. 네트워크 및 접근 제어 구성
- [x] VPC 및 Subnet CIDR 계획 수립
- [x] VPC 생성
- [x] Public Subnet 생성
- [x] Internet Gateway 생성 및 VPC 연결
- [x] Route Table 생성 및 Public Subnet 연결
- [x] 0.0.0.0/0 → Internet Gateway 경로 추가
- [x] Security Group 인바운드 규칙 설정
  - HTTP(80): 0.0.0.0/0 허용
  - SSH(22): 학습자 공인 IP로 제한
  - 전체 포트 공개 금지
- [x] EC2 접속용 키페어 생성 및 개인 키 안전 보관
- [x] SSH 접속에 사용할 현재 공인 IP 확인

---

### 3. EC2 및 웹 서버 배포
- [x] Public Subnet에 EC2 인스턴스 생성
  - 프리티어 대상 micro급 인스턴스 선택
  - Ubuntu LTS 또는 Amazon Linux 선택
  - EBS 8–10 GiB로 설정
- [x] 인스턴스에 SSH 접속
- [x] Nginx 등 웹 서버 설치 및 실행
- [x] 인스턴스 내부에서 curl http://localhost 실행
  - HTTP 200 응답 확인

---

### 4. 외부 접속 검증 및 문서 작성
- [x] 외부 접속 방식 선택
  - 브라우저에서 http://<public-ip> 접속
  - 또는 GET http://<public-ip>/health 요청 후 HTTP 200 확인
- [ ] 외부 접속 결과 스크린샷 저장
- [ ] 실제 발생한 오류를 하나 이상 기록
  - 증상 → 가설 → 검증 → 조치 → 결과 → 재발 방지
- [ ] 실제 구성에 맞춰 아키텍처 다이어그램 수정 및 완성
- [ ] README에 접속 방식, URL 또는 IP, 증빙 링크 작성
- [ ] 리소스 정리 체크리스트 작성
- [ ] HTTPS 및 Docker 보너스 과제 수행 여부 결정
- [ ] 아키텍처 다이어그램 초안 작성

---

### 5. 실습 종료 및 리소스 정리
- [ ] 증빙 자료 확보 여부 확인
- [ ] EC2 인스턴스 종료
- [ ] EBS 볼륨 및 Elastic IP 정리
- [ ] Internet Gateway 분리 및 삭제
- [ ] VPC, Subnet, Route Table 삭제
- [ ] NAT Gateway, Load Balancer, RDS 생성 여부 확인 및 정리
- [ ] Billing 화면에서 잔여 리소스 및 과금 항목 확인

---