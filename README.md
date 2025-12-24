# AWS 3-Tier Web Application Infrastructure

## 아키텍처 다이어그램

```
    Internet Gateway
          |
        [ALB]
          |
    Public Subnets
    ├── NGINX (us-east-2a)
    └── NGINX (us-east-2c)
          |
      NAT Gateways
          |
    Private Subnets
    ├── Tomcat (us-east-2a)
    ├── Tomcat (us-east-2c)
    ├── RDS Primary (us-east-2a)
    └── RDS Standby (us-east-2c)
```

## 실행 방법

### 1. 소프트웨어 설치
- **Terraform**: v1.0 이상
- **AWS CLI**: v2.0 이상
- **SSH 클라이언트**: OpenSSH 또는 PuTTY

### 2. AWS 계정 설정
- AWS 계정이 필요합니다
- 적절한 IAM 권한이 있는 사용자 또는 역할이 필요합니다

### 3. 필요한 AWS 권한
다음 서비스에 대한 권한이 필요합니다:
- EC2 (인스턴스, 키페어, 보안 그룹)
- VPC (VPC, 서브넷, 라우트 테이블, NAT Gateway, Internet Gateway)
- RDS (데이터베이스 인스턴스, 서브넷 그룹)
- ELB (Application Load Balancer, Target Groups)
- Route 53 (Hosted Zones, DNS Records) - 선택사항
- IAM (역할 생성) - 선택사항

==========================================================================

### 1. 저장소 클론 또는 파일 준비
```bash
# 현재 디렉토리에 Terraform 파일이 있는지 확인
ls -la *.tf
```

### 2. AWS 자격 증명 구성
```bash
# AWS CLI를 사용한 프로파일 설정
aws configure --profile kakaoTest

# 또는 환경 변수 설정
export AWS_ACCESS_KEY_ID="your-access-key"
export AWS_SECRET_ACCESS_KEY="your-secret-key"
export AWS_DEFAULT_REGION="us-east-2"
```

### 3. 변수 설정 (선택사항)
`terraform.tfvars` 파일을 생성하여 기본값을 재정의할 수 있습니다:

```hcl
# terraform.tfvars
project_name = "my-project"
environment  = "production"
vpc_cidr     = "10.250.0.0/16"

# 데이터베이스 비밀번호 변경 (필수 권장)
db_password = "YourSecurePassword123!"

# 도메인 설정 (Route 53 사용 시)
enable_route53 = true
domain_name    = "yourdomain.com"

# HTTPS 설정 (ACM 인증서 필요)
enable_https        = true
acm_certificate_arn = "arn:aws:acm:us-east-2:ACCOUNT:certificate/CERT-ID"
```

### 4. Terraform 초기화
```bash
terraform init
```

### 5. 실행 계획 확인
```bash
terraform plan
```

### 6. 인프라 배포
```bash
terraform apply
```

### 7. SSH 키 저장
```bash
# Terraform이 생성한 private key를 저장
terraform output -raw private_key > @@@-key-pair.pem
chmod 400 @@@-key-pair.pem
```
===================================================================
## 주요 설정 변수

### 필수 변경 권장 사항
| 변수명 | 기본값 | 설명 | 권장사항 |
|--------|--------|------|----------|
| `db_password` | YourStrongPassword123! | RDS 마스터 비밀번호 | 변경 권장 |
| `allowed_ssh_cidr_blocks` | ["0.0.0.0/0"] | SSH 접근 허용 IP | 특정 IP로 제한 |

### 주요 구성 옵션
| 변수명 | 기본값 | 설명 |
|--------|--------|------|
| `project_name` | yhj09-VEC-PRD | 프로젝트 이름 (리소스 명명에 사용) |
| `environment` | production | 환경 (production/staging/development) |
| `region` | us-east-2 | AWS 리전 |
| `vpc_cidr` | 10.250.0.0/16 | VPC CIDR 블록 |
| `enable_bastion` | true | Bastion Host 활성화 여부 |
| `enable_alb` | false | Application Load Balancer 사용 여부 |
| `enable_route53` | true | Route 53 DNS 관리 활성화 |
| `domain_name` | popori.store | 도메인 이름 |

### 인스턴스 타입
| 변수명 | 기본값 | 용도 |
|--------|--------|------|
| `nginx_instance_type` | t2.micro | NGINX 웹 서버 |
| `tomcat_instance_type` | t2.micro | Tomcat 애플리케이션 서버 |
| `bastion_instance_type` | t3.micro | Bastion Host |
| `db_instance_class` | db.t3.micro | RDS 인스턴스 |

## 접속 방법

### 1. Bastion Host 접속
```bash
# 직접 접속
ssh -i @@@-key-pair.pem ec2-user@[bastion_public_ip]
```

### 2. Private 인스턴스 접속
```bash
# Tomcat 서버 접속
ssh -i @@@-key-pair.pem \
    -o ProxyCommand="ssh -i @@@-key-pair.pem -W %h:%p ec2-user@[bastion_public_ip]" \
    ec2-user@[tomcat-private-ip]
```

### 3. 웹 애플리케이션 접속

#### ALB 사용 시 (enable_alb = true)
```bash
# 브라우저에서 접속
http://[alb-dns-name]
```

#### 직접 IP 접속 (enable_alb = false)
```bash
# 브라우저에서 접속
http://[nginx-public-ip]
```

#### Route 53 도메인 사용 시
```bash
# 브라우저에서 접속
http://yourdomain.com
```

### 4. 데이터베이스 접속
```bash
# Bastion Host에서 MySQL 클라이언트로 접속
mysql -h <rds-endpoint> -u admin -p
```

## terraform outputs 출력 값

주요 출력 값들:
- `vpc_id`: VPC ID
- `nginx_public_ips`: NGINX 서버들의 Public IP
- `tomcat_private_ips`: Tomcat 서버들의 Private IP
- `rds_endpoint`: RDS 데이터베이스 엔드포인트
- `bastion_public_ip`: Bastion Host Public IP
- `nginx_alb_dns`: ALB DNS 이름 (ALB 활성화 시)
- `route53_nameservers`: Route 53 네임서버 (도메인 등록기관에 설정 필요)

모든 출력 값 확인:
```bash
terraform output
```

## 인프라 삭제

### 삭제 명령
```bash
# 삭제 계획 확인
terraform plan -destroy

# 인프라 삭제
terraform destroy
```

### 삭제 보호가 설정된 경우
```bash
# variables.tf 또는 terraform.tfvars에서 변경
db_deletion_protection = false
alb_deletion_protection = false

# 변경 적용 후 삭제
terraform apply
terraform destroy
```
