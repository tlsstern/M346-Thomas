# KN09 Part B: Terraform Database Server

This Terraform configuration creates a database server on AWS with MariaDB installed and configured.

## Prerequisites

1. **Terraform installed** (download from https://www.terraform.io/downloads)
2. **AWS CLI configured** with valid credentials
3. **vockey key pair** exists in your AWS account

## Files

- `provider.tf` - AWS provider configuration
- `variables.tf` - Input variables
- `cloud-init.tf` - Cloud-init script for database setup
- `security-group.tf` - Security group allowing SSH (22) and MySQL (3306)
- `main.tf` - EC2 instance configuration
- `outputs.tf` - Output values (IP address, instance ID, etc.)

## Usage

### 1. Set AWS Credentials

Make sure your AWS credentials are set as environment variables:

```powershell
$env:AWS_ACCESS_KEY_ID="YOUR_ACCESS_KEY"
$env:AWS_SECRET_ACCESS_KEY="YOUR_SECRET_KEY"
$env:AWS_SESSION_TOKEN="YOUR_SESSION_TOKEN"
$env:AWS_DEFAULT_REGION="us-east-1"
```

### 2. Initialize Terraform

```bash
terraform init
```

This downloads the AWS provider plugin.

### 3. Format Configuration

```bash
terraform fmt
```

### 4. Validate Configuration

```bash
terraform validate
```

### 5. Preview Changes

```bash
terraform plan
```

This shows what resources will be created.

### 6. Apply Configuration

```bash
terraform apply
```

Type `yes` when prompted. This creates:
- Security group (db-sg-kn09-terraform)
- EC2 instance (DB-Server-KN09-Terraform)
- Installs and configures MariaDB via cloud-init

### 7. View Outputs

```bash
terraform output
```

This shows:
- Instance ID
- Public IP address
- Security group ID
- Test command for database connectivity

### 8. Test Database Connection

Wait 2-3 minutes for cloud-init to complete, then:

```bash
# Using telnet
telnet <PUBLIC-IP> 3306

# Or using PowerShell
Test-NetConnection -ComputerName <PUBLIC-IP> -Port 3306
```

### 9. Destroy Resources (When Done)

```bash
terraform destroy
```

Type `yes` when prompted.

## What Gets Created

1. **Security Group**: Allows inbound SSH (22) and MySQL (3306) from anywhere
2. **EC2 Instance**: Ubuntu 22.04 t2.micro instance
3. **Cloud-Init Setup**:
   - Installs mariadb-server
   - Starts and enables MariaDB service
   - Creates admin user with remote access
   - Configures MariaDB to listen on all interfaces (0.0.0.0)

## Configuration Details

- **AMI**: Latest Ubuntu 22.04 LTS (automatically selected)
- **Instance Type**: t2.micro (customizable via variable)
- **Key Pair**: vockey (must exist)
- **Region**: us-east-1
- **Database**: MariaDB
- **Admin User**: admin / password

## Customization

You can customize the instance by modifying `terraform.tfvars`:

```hcl
instance_type = "t2.small"
db_name       = "Custom-DB-Name"
```

## Why Terraform is Better Than CLI

As explained in the guide, Terraform provides:

1. **Automatic Dependency Management** - Creates resources in correct order
2. **State Tracking** - Knows what exists and what needs to change
3. **Idempotency** - Safe to run multiple times
4. **Preview Changes** - See what will happen before it happens (terraform plan)
5. **Declarative Syntax** - Describe desired state, not steps
6. **Error Recovery** - Can clean up or retry easily
7. **Version Control** - Infrastructure as code in Git

With CLI, we would need to:
- Manually capture resource IDs between commands
- Add wait logic
- Implement error handling
- Track state ourselves
- Understand and manage all dependencies

Terraform does all of this automatically!
