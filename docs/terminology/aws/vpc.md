# Amazon Virtual Private Cloud (VPC)

## 개요

VPC는 AWS 계정에 구성하는 논리적으로 격리된 가상 네트워크이다. IP 주소 범위, 서브넷, 라우팅과 보안 설정을 조합하여 리소스의 통신 구조를 정한다.

## 역할과 동작 방식

VPC는 리전 단위의 리소스이며 여러 AZ에 서브넷을 둘 수 있다. IPv4 주소 범위는 CIDR로 표현한다. 예를 들어 `10.0.0.0/16` VPC 안에 `10.0.1.0/24` 서브넷을 구성할 수 있다. 이는 설명용 주소 계획이며 실제 환경과 충돌하지 않도록 설계해야 한다.

| 구성 요소 | 역할 |
|:---|:---|
| Subnet | 리소스를 배치하는 IP 주소 범위 |
| Route Table | 목적지에 따른 트래픽 전달 경로 |
| Internet Gateway | VPC와 인터넷 사이의 통신 경로 |
| Security group | 네트워크 인터페이스 수준의 상태 저장 허용 규칙 |
| Network ACL | 서브넷 수준의 상태 비저장 허용·거부 규칙 |

## EC2 실습에서의 사용

퍼블릭 서브넷의 라우팅 테이블에 인터넷 게이트웨이를 향하는 기본 경로를 둔다. EC2에 공인 IPv4를 할당하고 필요한 보안 규칙을 설정하면 외부에서 웹 서버에 접근하는 구성을 만들 수 있다.

## 주의사항

VPC를 만들었다고 인터넷 접속이 자동으로 보장되지는 않는다. 라우팅, IP 주소, 보안 그룹, Network ACL, 운영체제 방화벽을 함께 확인한다. IAM은 AWS API 접근 권한을 관리하며 네트워크 방화벽을 대체하지 않는다.

## 관련 용어

- [Subnet](../networking/subnet.md)
- [Route Table](../networking/route-table.md)
- [Internet Gateway](internet-gateway.md)

[용어 요약으로 돌아가기](../../terminology.md)

## 참고 자료

- [AWS 공식 문서](https://docs.aws.amazon.com/vpc/latest/userguide/how-it-works.html)
