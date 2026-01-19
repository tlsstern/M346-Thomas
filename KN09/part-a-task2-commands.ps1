# ============================================================
# KN09 - Part A - Task 2: Create DB Instance with AWS CLI
# ============================================================
# IMPORTANT: Run these commands ONE BY ONE and take screenshots!
# ============================================================

# Prerequisites: Make sure AWS credentials are set
# Check with:
aws sts get-caller-identity

# ============================================================
# STEP 1: Create Security Group (SSH ONLY - No MySQL port!)
# ============================================================

# Create the security group
aws ec2 create-security-group `
  --group-name db-sg-kn09-cli `
  --description "Security group for KN09 DB server - CLI created (SSH only)" `
  --output json

# IMPORTANT: Copy the GroupId from the output above!
# It will look like: sg-0123456789abcdef0
# Set it as a variable:
$SG_ID = "REPLACE_WITH_YOUR_SECURITY_GROUP_ID"

# Add SSH rule (port 22 only - NO port 3306 to avoid AWS Academy ban!)
aws ec2 authorize-security-group-ingress `
  --group-id $SG_ID `
  --protocol tcp `
  --port 22 `
  --cidr 0.0.0.0/0

# Verify the security group was created
aws ec2 describe-security-groups --group-ids $SG_ID --output table

# 📸 SCREENSHOT 1: Security group details


# ============================================================
# STEP 2: Create the EC2 Instance with Cloud-Init
# ============================================================

# Create the instance
aws ec2 run-instances `
  --image-id ami-0e86e20dae9224db8 `
  --instance-type t2.micro `
  --key-name vockey `
  --security-group-ids $SG_ID `
  --user-data file://db-cloud-init.yaml `
  --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=DB-Server-KN09-CLI}]" `
  --output json

# IMPORTANT: Copy the InstanceId from the output above!
# Set it as a variable:
$INSTANCE_ID = "REPLACE_WITH_YOUR_INSTANCE_ID"

# 📸 SCREENSHOT 2: Instance creation output


# ============================================================
# STEP 3: Wait for Instance to be Running
# ============================================================

# Wait for instance to be running (this may take 1-2 minutes)
aws ec2 wait instance-running --instance-ids $INSTANCE_ID

Write-Host "✅ Instance is now running!"

# Get instance details
aws ec2 describe-instances `
  --instance-ids $INSTANCE_ID `
  --query 'Reservations[*].Instances[*].[InstanceId,State.Name,PublicIpAddress,Tags[?Key==`Name`].Value|[0]]' `
  --output table

# 📸 SCREENSHOT 3: Instance running with public IP


# ============================================================
# STEP 4: Get the Public IP and Wait for Cloud-Init
# ============================================================

# Get just the public IP
$PUBLIC_IP = aws ec2 describe-instances `
  --instance-ids $INSTANCE_ID `
  --query 'Reservations[*].Instances[*].PublicIpAddress' `
  --output text

Write-Host "Public IP: $PUBLIC_IP"
Write-Host "⏳ Waiting 3 minutes for cloud-init to install MariaDB..."

# Wait 3 minutes for cloud-init to complete
Start-Sleep -Seconds 180


# ============================================================
# STEP 5: SSH into Instance to Verify MariaDB
# ============================================================

# SSH into the instance (you'll need to have your vockey.pem file)
# Replace the path with your actual key path
# ssh -i path\to\vockey.pem ubuntu@$PUBLIC_IP

Write-Host ""
Write-Host "============================================"
Write-Host "SSH into the instance with this command:"
Write-Host "ssh -i path\to\vockey.pem ubuntu@$PUBLIC_IP"
Write-Host ""
Write-Host "Once connected, run these commands to verify MariaDB:"
Write-Host "  sudo systemctl status mariadb"
Write-Host "  sudo netstat -tulpn | grep 3306"
Write-Host "  sudo mysql -u root -e 'SELECT VERSION();'"
Write-Host "============================================"

# 📸 SCREENSHOT 4: SSH session showing MariaDB status
# 📸 SCREENSHOT 5: MariaDB version output


# ============================================================
# STEP 6: View Instance in AWS Console
# ============================================================

Write-Host ""
Write-Host "Go to AWS Console and view your instance:"
Write-Host "https://us-east-1.console.aws.amazon.com/ec2/home?region=us-east-1#Instances:"

# 📸 SCREENSHOT 6: AWS Console showing the instance


# ============================================================
# CLEANUP (Optional - run later when done with assignment)
# ============================================================

# When you're done with the assignment, clean up:
# aws ec2 terminate-instances --instance-ids $INSTANCE_ID
# aws ec2 delete-security-group --group-id $SG_ID


# ============================================================
# SUMMARY OF WHAT TO SCREENSHOT FOR PART A - TASK 2
# ============================================================
# 1. Security group creation and details
# 2. Instance creation command output
# 3. Instance running with public IP
# 4. SSH session showing MariaDB status
# 5. MariaDB running and version
# 6. AWS Console showing the instance
# ============================================================
