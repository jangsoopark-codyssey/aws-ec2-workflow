# Internet Gateway (IGW)

## 개요

인터넷 게이트웨이는 VPC의 리소스가 인터넷과 통신할 수 있도록 연결하는 구성 요소이다. VPC에 연결하며, 특정 서브넷에 직접 연결하는 리소스는 아니다.

## 역할과 동작 방식

서브넷의 라우팅 테이블에서 인터넷 목적지의 대상을 인터넷 게이트웨이로 지정한다. IPv4 기본 경로의 예는 `0.0.0.0/0 → igw-…`이다. IPv4에서는 인스턴스의 사설 IPv4와 공인 IPv4 사이의 주소 변환도 담당한다.

## EC2 실습에서의 사용

IPv4로 인터넷에서 EC2 웹 서버에 직접 접속하는 구성에는 다음 조건이 필요하다.

1. 인터넷 게이트웨이가 해당 VPC에 연결되어 있다.
2. EC2가 있는 서브넷의 라우팅 테이블에 게이트웨이를 향하는 경로가 있다.
3. EC2에 자동 할당 공인 IPv4 또는 Elastic IP가 있다.
4. 보안 그룹, Network ACL, 운영체제 방화벽이 필요한 통신을 허용하고 서버가 실행 중이다.

위 목록은 구성 조건이며 이 저장소에서 실제 접속을 검증했다는 의미는 아니다.

## 주의사항

게이트웨이를 연결하는 것만으로 모든 서브넷이 퍼블릭 서브넷이 되지는 않는다. 사설 IPv4만 가진 인스턴스는 이 경로만으로 IPv4 인터넷에 직접 접속할 수 없다. 프라이빗 서브넷에서 외부로 나가는 IPv4 연결에는 NAT Gateway 등의 별도 구성이 필요할 수 있다. NAT Gateway는 이번 기본 구성의 필수 요소가 아니다.

## 관련 용어

- [VPC](vpc.md)
- [Elastic IP](elastic-ip.md)
- [Route Table](../networking/route-table.md)

[용어 요약으로 돌아가기](../../terminology.md)

## 참고 자료

- [AWS 공식 문서](https://docs.aws.amazon.com/vpc/latest/userguide/VPC_Internet_Gateway.html)
