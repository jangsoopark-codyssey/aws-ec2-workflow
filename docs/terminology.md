# Terminology

AWS EC2 웹 서비스 실습에 필요한 주요 용어를 정리한다. 각 상세 문서는 개념, 동작 방식, 실습에서의 사용과 주의사항을 설명한다. 아래 구성 예시는 학습용이며 실제 배포 또는 접속 검증 결과가 아니다.

## Summary

### AWS 계정·컴퓨팅·스토리지

| Term | Abbreviation | Description | Detail |
|:---|:---:|:---|:---:|
| Amazon Web Services | AWS | 컴퓨팅, 스토리지, 네트워킹 등을 제공하는 클라우드 플랫폼 | [상세](terminology/aws/aws.md) |
| Identity and Access Management | IAM | AWS 리소스에 접근하는 주체의 인증과 권한을 관리하는 서비스 | [상세](terminology/aws/iam.md) |
| Elastic Compute Cloud | EC2 | 가상 서버인 인스턴스를 생성하고 실행하는 서비스 | [상세](terminology/aws/ec2.md) |
| Elastic Block Store | EBS | EC2에 연결해 디스크처럼 사용하는 영구 블록 저장소 | [상세](terminology/aws/ebs.md) |

### AWS 네트워크

| Term | Abbreviation | Description | Detail |
|:---|:---:|:---|:---:|
| Amazon Virtual Private Cloud | VPC | AWS 계정에 구성하는 논리적으로 격리된 가상 네트워크 | [상세](terminology/aws/vpc.md) |
| Internet Gateway | IGW | VPC와 인터넷 사이의 통신 경로를 제공하는 구성 요소 | [상세](terminology/aws/internet-gateway.md) |
| Elastic IP | EIP | 계정에 할당해 리소스에 연결하는 고정 공인 IPv4 주소 | [상세](terminology/aws/elastic-ip.md) |

### 일반 네트워크

| Term | Abbreviation | Description | Detail |
|:---|:---:|:---|:---:|
| Subnet | - | 네트워크를 나눈 IP 주소 범위. AWS에서는 하나의 AZ에 속함 | [상세](terminology/networking/subnet.md) |
| Route Table | - | 목적지 주소에 따라 트래픽을 전달할 경로를 정하는 규칙 목록 | [상세](terminology/networking/route-table.md) |
| Secure Shell | SSH | 암호화된 연결로 원격 서버에 로그인하고 명령을 실행하는 프로토콜 | [상세](terminology/networking/ssh.md) |

## EC2 웹 서비스 구성에서의 관계

1. **AWS와 IAM**: 계정과 리전을 확인하고, 필요한 리소스만 관리할 권한을 준비한다.
2. **VPC와 Subnet**: 네트워크 주소 범위를 정하고 서울 리전의 한 AZ에 서브넷을 배치한다.
3. **Route Table과 Internet Gateway**: 퍼블릭 서브넷의 IPv4 기본 경로 `0.0.0.0/0`을 인터넷 게이트웨이로 지정한다.
4. **EC2와 EBS**: 서브넷 안에서 가상 서버를 실행하고 같은 AZ의 EBS를 디스크로 사용한다.
5. **공인 IPv4와 SSH**: 자동 할당 공인 IPv4 또는 선택적으로 Elastic IP를 사용한다. SSH는 관리용이며 웹 접속은 별도로 HTTP 80을 사용한다.

IPv4 인터넷 직접 접속에는 공인 IPv4, 인터넷 경로, 보안 그룹 및 Network ACL의 허용, 실행 중인 서버가 함께 필요하다. 보안 그룹에서 HTTP 80은 실습 요구에 따라 공개하고 SSH 22는 학습자의 IP 범위로 제한한다. 라우팅 테이블과 IAM은 포트 접근 규칙을 대신하지 않는다.

## 학습 시 유의사항

- 상세 문서는 `docs/terminology/aws/`와 `docs/terminology/networking/`에 분류되어 있다.
- CIDR은 IP 주소 범위를 나타내는 표기이다. 예를 들어 `10.0.1.0/24`는 학습용 사설 네트워크 범위이다.
- 실제 리소스 생성, 외부 접속 검증 및 정리 여부는 별도 증거로 확인해야 한다.
- EC2 중지 후에도 EBS와 공인 IPv4 등의 비용이 남을 수 있다. 비용과 정리 대상을 개별적으로 확인한다.
