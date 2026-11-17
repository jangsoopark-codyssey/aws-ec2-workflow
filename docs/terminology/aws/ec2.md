# Elastic Compute Cloud (EC2)

## 개요

Amazon EC2는 AWS에서 가상 서버인 인스턴스를 실행하는 서비스이다. 웹 서버나 애플리케이션을 설치하고 운영체제를 직접 관리할 수 있다.

## 역할과 동작 방식

| 구성 요소 | 역할 |
|:---|:---|
| AMI | 운영체제와 초기 소프트웨어를 담은 인스턴스 생성 이미지 |
| Instance type | CPU, 메모리 등 컴퓨팅 자원 구성 |
| EBS | 운영체제와 데이터에 사용하는 블록 저장소 |
| Network interface | 서브넷의 사설 IP 등 네트워크 설정을 보유 |
| Security group | 네트워크 인터페이스에 적용하는 상태 저장 방식의 트래픽 허용 규칙 |
| Key pair | 일반적인 Linux SSH 접속에 사용하는 공개 키와 개인 키 |

인스턴스는 선택한 서브넷의 AZ에서 실행된다. AMI와 인스턴스 유형은 서로 지원하는 아키텍처를 선택해야 한다.

## EC2 실습에서의 사용

서울 리전의 퍼블릭 서브넷에 인스턴스를 배치하고 웹 서버를 실행하는 구성을 학습한다. IPv4 인터넷 직접 접속에는 공인 IPv4, 인터넷 게이트웨이 경로, 허용된 보안 규칙이 필요하다. HTTP는 TCP 80, SSH는 TCP 22를 사용하며 SSH 허용 출발지는 학습자의 IP 범위로 제한한다.

## 주의사항

중지(Stop)는 종료(Terminate)와 다르다. EBS 기반 인스턴스는 중지 후 다시 시작할 수 있지만 종료한 인스턴스는 복구할 수 없다. 종료 시 EBS 삭제 여부는 `DeleteOnTermination` 설정에 따른다. 자동 할당 공인 IPv4는 중지 후 시작하면 바뀔 수 있다.

## 관련 용어

- [EBS](ebs.md)
- [Subnet](../networking/subnet.md)
- [SSH](../networking/ssh.md)

[용어 요약으로 돌아가기](../../terminology.md)

## 참고 자료

- [AWS 공식 문서](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/concepts.html)
