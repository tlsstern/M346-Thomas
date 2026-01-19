# KN09 Part A: AWS CLI Commands

## Configuration

```powershell
# Set AWS credentials (must be done every time you start AWS Academy)
$env:AWS_ACCESS_KEY_ID="YOUR_ACCESS_KEY"
$env:AWS_SECRET_ACCESS_KEY="YOUR_SECRET_KEY"
$env:AWS_SESSION_TOKEN="YOUR_SESSION_TOKEN"
$env:AWS_DEFAULT_REGION="us-east-1"
```

## Test Configuration

```cmd
REM Verify AWS CLI is configured correctly
aws ec2 describe-instances
```

## Task 1: Stop and Start an Instance

### List all instances
```cmd
REM View all instances in a table format
aws ec2 describe-instances --query "Reservations[*].Instances[*].[InstanceId,State.Name,Tags[?Key==`Name`].Value|[0],InstanceType,PublicIpAddress]" --output table
```

### Stop an instance
```cmd
REM Replace i-xxxxx with your actual instance ID
aws ec2 stop-instances --instance-ids i-xxxxx
```

### Check instance stopped
```cmd
REM Verify the instance is stopping/stopped
aws ec2 describe-instances --instance-ids i-xxxxx --query "Reservations[*].Instances[*].[InstanceId,State.Name]" --output table
```

### Start an instance
```cmd
REM Start the same instance
aws ec2 start-instances --instance-ids i-xxxxx
```

### Check instance started
```cmd
REM Verify the instance is running and get the new public IP
aws ec2 describe-instances --instance-ids i-xxxxx --query "Reservations[*].Instances[*].[InstanceId,State.Name,PublicIpAddress]" --output table
```

## Task 2: Create Database Server Instance

### Step 1: Get Default VPC ID
```cmd
aws ec2 describe-vpcs --filters "Name=is-default,Values=true" --query "Vpcs[0].VpcId" --output text
```

### Step 2: Create Security Group
```cmd
REM Create security group for database server
aws ec2 create-security-group ^
  --group-name db-sg-kn09 ^
  --description "Security group for KN09 database server" ^
  --tag-specifications "ResourceType=security-group,Tags=[{Key=Name,Value=db-sg-kn09}]"
```

### Step 3: Add Security Group Rules
```cmd
REM Get the security group ID from previous command output, then:

REM Allow SSH (port 22)
aws ec2 authorize-security-group-ingress --group-id sg-xxxxx --protocol tcp --port 22 --cidr 0.0.0.0/0

REM Allow MySQL (port 3306)
aws ec2 authorize-security-group-ingress --group-id sg-xxxxx --protocol tcp --port 3306 --cidr 0.0.0.0/0
```

### Step 4: Create EC2 Instance
```cmd
REM Create the database server instance
REM Make sure db-cloud-init.yaml is in the current directory
aws ec2 run-instances ^
  --image-id ami-0e86e20dae9224db8 ^
  --instance-type t2.micro ^
  --key-name vockey ^
  --security-group-ids sg-xxxxx ^
  --user-data file://db-cloud-init.yaml ^
  --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=DB-Server-KN09}]"
```

### Step 5: Get Instance Public IP
```cmd
REM Replace i-xxxxx with the instance ID from previous command
aws ec2 describe-instances --instance-ids i-xxxxx --query "Reservations[*].Instances[*].PublicIpAddress" --output text
```

### Step 6: Test Database Connection
```cmd
REM Wait 2-3 minutes for cloud-init to complete, then test
telnet YOUR-PUBLIC-IP 3306
```

**Alternative using PowerShell:**
```powershell
Test-NetConnection -ComputerName YOUR-PUBLIC-IP -Port 3306
```

## Task 3: CLI Commands to Recreate KN05 Infrastructure

These commands show how you would recreate the complete KN05 infrastructure using AWS CLI. Note that IDs (vpc-EXAMPLE, etc.) are placeholders - in a real script, you would capture these dynamically.

### 1. Create VPC
```cmd
aws ec2 create-vpc ^
  --cidr-block 10.0.0.0/16 ^
  --tag-specifications "ResourceType=vpc,Tags=[{Key=Name,Value=vpc-kn09}]"
```

### 2. Create Internet Gateway
```cmd
aws ec2 create-internet-gateway ^
  --tag-specifications "ResourceType=internet-gateway,Tags=[{Key=Name,Value=igw-kn09}]"
```

### 3. Attach Internet Gateway to VPC
```cmd
aws ec2 attach-internet-gateway ^
  --vpc-id vpc-EXAMPLE123 ^
  --internet-gateway-id igw-EXAMPLE456
```

### 4. Create Public Subnet
```cmd
aws ec2 create-subnet ^
  --vpc-id vpc-EXAMPLE123 ^
  --cidr-block 10.0.1.0/24 ^
  --availability-zone us-east-1a ^
  --tag-specifications "ResourceType=subnet,Tags=[{Key=Name,Value=subnet-public-kn09}]"
```

### 5. Create Route Table
```cmd
aws ec2 create-route-table ^
  --vpc-id vpc-EXAMPLE123 ^
  --tag-specifications "ResourceType=route-table,Tags=[{Key=Name,Value=rtb-public-kn09}]"
```

### 6. Create Route to Internet Gateway
```cmd
aws ec2 create-route ^
  --route-table-id rtb-EXAMPLE789 ^
  --destination-cidr-block 0.0.0.0/0 ^
  --gateway-id igw-EXAMPLE456
```

### 7. Associate Route Table with Subnet
```cmd
aws ec2 associate-route-table ^
  --subnet-id subnet-EXAMPLE101 ^
  --route-table-id rtb-EXAMPLE789
```

### 8. Create Security Group for Web Server
```cmd
aws ec2 create-security-group ^
  --group-name web-sg-kn09 ^
  --description "Security group for web server" ^
  --vpc-id vpc-EXAMPLE123 ^
  --tag-specifications "ResourceType=security-group,Tags=[{Key=Name,Value=sg-web-kn09}]"
```

### 9. Add Web Server Security Group Rules
```cmd
REM SSH access
aws ec2 authorize-security-group-ingress ^
  --group-id sg-WEB-EXAMPLE ^
  --protocol tcp --port 22 --cidr 0.0.0.0/0

REM HTTP access
aws ec2 authorize-security-group-ingress ^
  --group-id sg-WEB-EXAMPLE ^
  --protocol tcp --port 80 --cidr 0.0.0.0/0

REM HTTPS access
aws ec2 authorize-security-group-ingress ^
  --group-id sg-WEB-EXAMPLE ^
  --protocol tcp --port 443 --cidr 0.0.0.0/0
```

### 10. Create Security Group for Database Server
```cmd
aws ec2 create-security-group ^
  --group-name db-sg-kn09 ^
  --description "Security group for database server" ^
  --vpc-id vpc-EXAMPLE123 ^
  --tag-specifications "ResourceType=security-group,Tags=[{Key=Name,Value=sg-db-kn09}]"
```

### 11. Add Database Server Security Group Rules
```cmd
REM SSH access from anywhere
aws ec2 authorize-security-group-ingress ^
  --group-id sg-DB-EXAMPLE ^
  --protocol tcp --port 22 --cidr 0.0.0.0/0

REM MySQL access only from web server security group
aws ec2 authorize-security-group-ingress ^
  --group-id sg-DB-EXAMPLE ^
  --protocol tcp --port 3306 --source-group sg-WEB-EXAMPLE
```

### 12. Allocate Elastic IP
```cmd
aws ec2 allocate-address ^
  --domain vpc ^
  --tag-specifications "ResourceType=elastic-ip,Tags=[{Key=Name,Value=eip-web-kn09}]"
```

### 13. Create Network Interface for Web Server
```cmd
aws ec2 create-network-interface ^
  --subnet-id subnet-EXAMPLE101 ^
  --groups sg-WEB-EXAMPLE ^
  --tag-specifications "ResourceType=network-interface,Tags=[{Key=Name,Value=eni-web-kn09}]"
```

### 14. Associate Elastic IP with Network Interface
```cmd
aws ec2 associate-address ^
  --allocation-id eipalloc-EXAMPLE333 ^
  --network-interface-id eni-EXAMPLE444
```

### 15. Launch Web Server Instance
```cmd
aws ec2 run-instances ^
  --image-id ami-0e86e20dae9224db8 ^
  --instance-type t2.micro ^
  --key-name vockey ^
  --subnet-id subnet-EXAMPLE101 ^
  --security-group-ids sg-WEB-EXAMPLE ^
  --user-data file://web-cloud-init.yaml ^
  --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=WebServer-KN09}]"
```

### 16. Launch Database Server Instance
```cmd
aws ec2 run-instances ^
  --image-id ami-0e86e20dae9224db8 ^
  --instance-type t2.micro ^
  --key-name vockey ^
  --subnet-id subnet-EXAMPLE101 ^
  --security-group-ids sg-DB-EXAMPLE ^
  --user-data file://db-cloud-init.yaml ^
  --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=DBServer-KN09}]"
```

## What is needed for automation?

To fully automate these CLI commands, we need:

### 1. Dynamic Variable Capture
The commands above have placeholders like `vpc-EXAMPLE123`. In a real automation script, we need to capture the output from each command and use it in subsequent commands.

**Example in CMD/Batch:**
```cmd
REM Create VPC and capture its ID
FOR /F "tokens=*" %%i IN ('aws ec2 create-vpc --cidr-block 10.0.0.0/16 --query "Vpc.VpcId" --output text') DO SET VPC_ID=%%i

REM Use the captured VPC ID in the next command
aws ec2 create-subnet --vpc-id %VPC_ID% --cidr-block 10.0.1.0/24
```

**Example in PowerShell:**
```powershell
# Create VPC and capture its ID
$VPC_ID = (aws ec2 create-vpc --cidr-block 10.0.0.0/16 --query 'Vpc.VpcId' --output text)

# Use the captured VPC ID in the next command
aws ec2 create-subnet --vpc-id $VPC_ID --cidr-block 10.0.1.0/24
```

### 2. Error Handling
Check if each command succeeds before proceeding to the next one.

**CMD/Batch example:**
```cmd
FOR /F "tokens=*" %%i IN ('aws ec2 create-vpc --cidr-block 10.0.0.0/16 --query "Vpc.VpcId" --output text') DO SET VPC_ID=%%i
IF %ERRORLEVEL% NEQ 0 (
    echo Failed to create VPC
    exit /b 1
)
```

**PowerShell example:**
```powershell
$VPC_ID = (aws ec2 create-vpc --cidr-block 10.0.0.0/16 --query 'Vpc.VpcId' --output text)
if ($LASTEXITCODE -ne 0) {
    Write-Error "Failed to create VPC"
    exit 1
}
```

### 3. Wait States
Some AWS resources take time to become available. We need to add wait commands:

```cmd
REM Create instance
FOR /F "tokens=*" %%i IN ('aws ec2 run-instances ... --query "Instances[0].InstanceId" --output text') DO SET INSTANCE_ID=%%i

REM Wait for instance to be running
aws ec2 wait instance-running --instance-ids %INSTANCE_ID%

REM Now the instance is ready for further operations
```

### 4. Idempotency
The script should check if resources already exist before creating them:

**CMD/Batch example:**
```cmd
REM Check if VPC already exists
FOR /F "tokens=*" %%i IN ('aws ec2 describe-vpcs --filters "Name=tag:Name,Values=vpc-kn09" --query "Vpcs[0].VpcId" --output text') DO SET EXISTING_VPC=%%i

IF "%EXISTING_VPC%"=="None" (
    REM VPC doesn't exist, create it
    FOR /F "tokens=*" %%i IN ('aws ec2 create-vpc --cidr-block 10.0.0.0/16 --tag-specifications "ResourceType=vpc,Tags=[{Key=Name,Value=vpc-kn09}]" --query "Vpc.VpcId" --output text') DO SET VPC_ID=%%i
) ELSE (
    REM VPC exists, use it
    SET VPC_ID=%EXISTING_VPC%
)
```

**PowerShell example:**
```powershell
# Check if VPC already exists
$EXISTING_VPC = (aws ec2 describe-vpcs --filters "Name=tag:Name,Values=vpc-kn09" --query 'Vpcs[0].VpcId' --output text)

if ($EXISTING_VPC -eq "None" -or $null -eq $EXISTING_VPC) {
    # VPC doesn't exist, create it
    $VPC_ID = (aws ec2 create-vpc --cidr-block 10.0.0.0/16 --tag-specifications 'ResourceType=vpc,Tags=[{Key=Name,Value=vpc-kn09}]' --query 'Vpc.VpcId' --output text)
} else {
    # VPC exists, use it
    $VPC_ID = $EXISTING_VPC
}
```

### 5. State Management
Keep track of all created resources for later cleanup or modification:

**CMD/Batch example (saving to file):**
```cmd
REM Save all resource IDs to a file
echo VpcId=%VPC_ID% > infrastructure-state.txt
echo SubnetId=%SUBNET_ID% >> infrastructure-state.txt
echo SecurityGroupId=%SG_ID% >> infrastructure-state.txt
echo InstanceId=%INSTANCE_ID% >> infrastructure-state.txt
```

**PowerShell example:**
```powershell
# Save all resource IDs to a file
@{
    VpcId = $VPC_ID
    SubnetId = $SUBNET_ID
    SecurityGroupId = $SG_ID
    InstanceId = $INSTANCE_ID
} | ConvertTo-Json | Out-File "infrastructure-state.json"
```

### 6. Dependency Management
Ensure resources are created in the correct order and all dependencies are satisfied.

### Why This Is Complex

With raw CLI commands, we need to:
- Manually capture and pass resource IDs between commands
- Add wait logic for resources to become available
- Implement error handling at every step
- Track what has been created
- Understand and manage all dependencies

**This is why tools like Terraform are so valuable!** Terraform handles all of this automatically:
- Dependency management (creates resources in correct order)
- State tracking (knows what exists)
- Automatic waits (waits for resources to be ready)
- Idempotency (safe to run multiple times)
- Error recovery (can clean up or retry)

## Cleanup Commands

When you're done testing, clean up resources:

```cmd
REM Terminate instances
aws ec2 terminate-instances --instance-ids i-xxxxx

REM Wait for termination
aws ec2 wait instance-terminated --instance-ids i-xxxxx

REM Delete security groups
aws ec2 delete-security-group --group-id sg-xxxxx

REM (Continue with other resources in reverse order of creation)
```
