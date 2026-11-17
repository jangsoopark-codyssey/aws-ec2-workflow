# Elastic IP (EIP)

## 개요

Elastic IP는 AWS 계정에 할당해 사용하는 고정 공인 IPv4 주소이다. 주소를 해제하기 전까지 유지하며 EC2 등의 리소스에 연결할 수 있다. IPv6용 Elastic IP는 제공하지 않는다.

## 역할과 동작 방식

주소를 계정에 할당(Allocate)하는 것과 리소스에 연결(Associate)하는 것은 별도 작업이다. 같은 리전 안에서 다른 인스턴스로 재연결하여 접속 주소를 유지하는 데 사용할 수 있다. 다른 리전으로 그대로 옮길 수는 없다.

자동 할당 공인 IPv4와 달리, Elastic IP는 인스턴스를 중지 후 시작하더라도 연결을 유지하는 동안 주소가 유지된다. DNS가 해당 주소를 가리키는 구성에서 서버 교체 시 활용할 수 있다.

## EC2 실습에서의 사용

고정 주소가 필요한지 먼저 판단한다. 기본 웹 접속 실습은 자동 할당 공인 IPv4로도 가능하며 Elastic IP가 반드시 필요한 것은 아니다. 연결 후에도 퍼블릭 서브넷의 인터넷 게이트웨이 경로와 보안 그룹 설정이 있어야 외부 접속이 가능하다.

## 주의사항

연결 해제(Disassociate)는 계정에서 주소를 해제(Release)하는 것과 다르다. 사용 중이거나 유휴 상태인 Elastic IP 모두 비용이 발생할 수 있다. 정리할 때 계정에 할당된 주소가 남아 있는지 확인하고, 해제 후 같은 주소를 다시 받을 수 있다고 가정하지 않는다.

## 관련 용어

- [EC2](ec2.md)
- [Internet Gateway](internet-gateway.md)

[용어 요약으로 돌아가기](../../terminology.md)

## 참고 자료

- [AWS 공식 문서](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/elastic-ip-addresses-eip.html)
