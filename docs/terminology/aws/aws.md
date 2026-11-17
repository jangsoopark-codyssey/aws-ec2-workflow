# Amazon Web Services (AWS)

## 개요

Amazon Web Services(AWS)는 서버, 저장소, 네트워크 등을 필요에 따라 사용하는 클라우드 플랫폼이다. 직접 장비를 구매하는 대신 서비스와 리소스를 선택해 구성한다.

## 역할과 동작 방식

- **Region(리전)**: 리소스를 배치할 지리적 영역이다. 서울 리전의 코드는 `ap-northeast-2`이다.
- **Availability Zone(가용 영역, AZ)**: 리전 안의 서로 분리된 인프라 영역이다. 여러 AZ에 분산하면 한 AZ의 장애에 대비할 수 있다.
- **서비스와 리소스**: EC2는 서비스이고, 생성한 가상 서버인 인스턴스는 리소스이다. 서비스마다 리전 또는 AZ에 대한 범위가 다르다.

## EC2 실습에서의 사용

IAM으로 작업 권한을 정하고, VPC와 서브넷에 EC2를 배치한다. EBS는 디스크 역할을 하며, 인터넷 통신에는 라우팅과 보안 설정이 필요하다. 콘솔이나 AWS CLI에서 작업할 때 선택한 계정과 리전을 확인한다.

## 주의사항

AWS가 물리적 인프라를 관리하더라도 사용자는 자신이 구성한 접근 권한, 데이터, EC2 운영체제와 애플리케이션을 관리해야 한다. 인스턴스를 중지해도 저장소와 공인 IPv4 등 다른 리소스의 비용이 남을 수 있으므로 무료 사용을 전제하지 않는다.

## 관련 용어

- [IAM](iam.md)
- [EC2](ec2.md)
- [VPC](vpc.md)

[용어 요약으로 돌아가기](../../terminology.md)

## 참고 자료

- [AWS 공식 문서](https://docs.aws.amazon.com/whitepapers/latest/aws-overview/introduction.html)
