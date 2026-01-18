# KN07 PAAS - Complete Step-by-Step Guide

![TBZ Logo](../x_gitres/tbz_logo.png)

## 📋 Overview

This guide will help you complete all parts of KN07, which focuses on Platform as a Service (PaaS) on AWS. You'll learn to:
- Set up a MariaDB database using AWS RDS (PaaS)
- Deploy an application using AWS Elastic Beanstalk (PaaS)
- Understand CloudFormation and how PaaS differs from IaaS

---

## Part A: Database in PaaS Model (20%)

### 🎯 Goal
Create a MariaDB database using AWS RDS and test the connection with MySQL Workbench.

### 📝 Step-by-Step Instructions

#### Step 1: Sign in to AWS Console
1. Go to [AWS Management Console](https://console.aws.amazon.com/)
2. Sign in with your AWS account

#### Step 2: Navigate to RDS
1. In the search bar at the top, type "RDS"
2. Click on "RDS" under Services

#### Step 3: Create Database
1. Click the **"Create database"** button
2. **Choose a database creation method**: Select **"Standard create"**

#### Step 4: Select Engine
1. **Engine type**: Select **"MariaDB"**
2. **Templates**: **IMPORTANT** - Choose **"Free tier"** to avoid charges

#### Step 5: Configure Settings
1. **DB instance identifier**: Give it a unique name (e.g., `kn07-mariadb-thomas`)
2. **Master username**: Use `admin` or your preferred username
3. **Master password**: 
   - Create a strong password
   - ⚠️ **IMPORTANT**: Do NOT use `#` (hash) or `-` (hyphen) characters!
   - Example: `Thomas-Password`
   - Write it down! You'll need it later.

#### Step 6: Instance Configuration
1. **DB instance class**: Should automatically be set to `db.t3.micro` or `db.t4g.micro` (Free Tier)
2. **Storage type**: General Purpose SSD (gp2)
3. **Allocated storage**: 20 GB
4. ⚠️ **IMPORTANT**: **Uncheck "Enable storage autoscaling"** to stay within free tier limits!

#### Step 7: Connectivity Settings
1. **Virtual Private Cloud (VPC)**: Choose the default VPC
2. **Public access**: Select **"Yes"** (for this exercise)
3. **VPC security group**: 
   - Create new security group OR
   - Select existing security group
4. **Availability Zone**: No preference
5. **Database port**: Keep default 3306

#### Step 8: Security Group Configuration
⚠️ **CRITICAL**: You need to allow access to your database!

1. After creating the database, go to **EC2 Console** → **Security Groups**
2. Find the security group associated with your RDS instance
3. Click **"Edit inbound rules"**
4. Add a new rule:
   - **Type**: MySQL/Aurora (port 3306)
   - **Source**: 
     - Option 1: "My IP" (recommended for security)
     - Option 2: "Anywhere-IPv4" (0.0.0.0/0) - only for testing!
5. Click **"Save rules"**

#### Step 9: Wait for Database to be Available
1. Go back to RDS Console → Databases
2. Wait until the **Status** shows **"Available"** (can take 5-10 minutes)
3. Click on your database instance
4. Under **"Connectivity & security"** tab, find and copy the **Endpoint**
   - Example: `kn07-mariadb-thomas.xxxxx.eu-central-1.rds.amazonaws.com`
   - **Your actual endpoint**: `kn07-mariadb.cqoodppaydn1.us-east-1.rds.amazonaws.com`

#### Step 10: Install MySQL Workbench
1. Download from [MySQL Workbench Download Page](https://dev.mysql.com/downloads/workbench/)
2. Install the application

#### Step 11: Connect with MySQL Workbench
1. Open MySQL Workbench
2. Click **"+"** next to "MySQL Connections"
3. Enter connection details:
   - **Connection Name**: KN07 RDS MariaDB
   - **Hostname**: Paste the endpoint from Step 9 (without port)
   - **Port**: 3306
   - **Username**: admin (or what you chose)
   - **Password**: Click "Store in Vault" and enter your password
4. Click **"Test Connection"**
   - If successful, click **"OK"**
   - If failed, check your security group settings!
5. Double-click the new connection to open it

#### Step 12: Execute Test Query
1. In MySQL Workbench, create a new query tab
2. Execute the same query from your `db.php` file. For example:
   ```sql
   CREATE DATABASE IF NOT EXISTS test_db;
   USE test_db;
   
   CREATE TABLE IF NOT EXISTS users (
       id INT AUTO_INCREMENT PRIMARY KEY,
       name VARCHAR(100),
       email VARCHAR(100),
       created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
   );
   
   INSERT INTO users (name, email) VALUES ('Thomas', 'thomas@example.com');
   
   SELECT * FROM users;
   ```
3. Take a **screenshot** showing the successful query execution

### ✅ Deliverables for Part A
- [ ] Screenshot from MySQL Workbench with executed query results
- [ ] Written explanation of why PaaS/SaaS is better than managing your own database

#### Sample Answer for "Why use PaaS/SaaS?"
```
Vorteile von PAAS/SAAS für Datenbanken:

1. **Automatische Wartung**: AWS übernimmt Updates, Patches und Sicherheitsupdates automatisch
2. **Backup & Recovery**: Automatische Backups und einfache Wiederherstellung im Notfall
3. **Skalierbarkeit**: Mit wenigen Klicks kann die Datenbank vertikal oder horizontal skaliert werden
4. **Hochverfügbarkeit**: Multi-AZ Deployment für höhere Verfügbarkeit möglich
5. **Zeitersparnis**: Keine Installation, Konfiguration oder Infrastruktur-Verwaltung nötig
6. **Kosteneffizienz**: Pay-as-you-go Modell, keine Hardware-Investitionen
7. **Monitoring**: Integrierte Überwachung und Alarmierung durch CloudWatch
8. **Sicherheit**: AWS-Level Sicherheit, Verschlüsselung, IAM-Integration

Fazit: Man kann sich auf die Applikation fokussieren statt auf Infrastruktur-Management.
```

---

## Part B: PaaS Application Creation (60%)

### 🎯 Goal
Deploy an application using AWS Elastic Beanstalk and configure it properly.

### 📝 Step-by-Step Instructions

#### Step 1: Navigate to Elastic Beanstalk
1. In AWS Console, search for "Elastic Beanstalk"
2. Click on the service

#### Step 2: Create New Application
1. Click **"Create application"**
2. **Application name**: `kn07-app-thomas` (or your preferred name)
3. **Application tags**: (optional) Add tags for organization

#### Step 3: Choose Platform
1. **Platform**: Choose one of:
   - **Java** (for Spring PetClinic)
   - **Node.js**
   - **Python**
   - **.NET**
   - **PHP**
   - **Docker**
2. **Platform branch**: Use the recommended/latest stable version
3. **Platform version**: Usually leave as recommended

#### Step 4: Application Code
Choose one of these options:

**Option 1: Use Sample Application** (Easiest)
- Select **"Sample application"**
- AWS provides a working demo app

**Option 2: Use Spring PetClinic** (Recommended for learning)
1. Download Spring PetClinic:
   ```bash
   git clone https://github.com/spring-projects/spring-petclinic.git
   cd spring-petclinic
   ./mvnw package
   ```
2. Create a ZIP file of the JAR file from `target/` directory
3. Select **"Upload your code"**
4. Upload the ZIP file

**Option 3: Your Own Application**
- Upload your own application as a ZIP file

#### Step 5: Configure Service Access
1. **Service role**: 
   - If first time: Select **"Create and use new service role"**
   - If exists: Select existing `aws-elasticbeanstalk-service-role`
2. **EC2 instance profile**:
   - Create new profile OR
   - Select existing `aws-elasticbeanstalk-ec2-role`
3. **EC2 key pair**: Select a key pair (or create one) for SSH access

📸 **Take Screenshot #1**: Service access configuration

#### Step 6: Configure Networking & Database (Optional)
1. **VPC**: Select default VPC
2. **Public IP address**: Enable
3. **Instance subnets**: Select at least 2 subnets for high availability
4. **Database**: You can skip this since you created RDS in Part A

📸 **Take Screenshot #2**: Networking configuration (if you changed anything)

#### Step 7: Configure Instance Traffic and Scaling
This is **IMPORTANT** for the exercise!

1. **Environment type**: Select **"Load balanced"** (not Single instance)
2. **Instances**:
   - **Min**: 1
   - **Max**: 4
   - **Fleet composition**: On-Demand instances
3. **Instance types**: Select `t2.micro` or `t3.micro` (Free Tier eligible)
4. **Scaling triggers**:
   - **Metric**: CPUUtilization
   - **Upper threshold**: 75%
   - **Lower threshold**: 20%

📸 **Take Screenshot #3**: Instance traffic and scaling configuration

**Explanation to document**:
```
Load Balancer: Verteilt den Traffic auf mehrere Instanzen für höhere Verfügbarkeit
Auto Scaling: Erstellt automatisch neue Instanzen bei hoher Last (CPU > 75%)
Min/Max Instances: Definiert die Grenzen für die Skalierung
t2.micro: Free Tier eligible, ausreichend für Demo-Zwecke
```

#### Step 8: Configure Updates, Monitoring and Logging
1. **Managed platform updates**: Enable
2. **CloudWatch logs**: Enable log streaming
3. **Instance log streaming to CloudWatch**: Select logs you want to stream

📸 **Take Screenshot #4**: Monitoring configuration

**Explanation to document**:
```
CloudWatch Integration: Ermöglicht Monitoring der Applikation und Infrastruktur
Log Streaming: Logs werden automatisch zu CloudWatch gesendet für zentrale Analyse
Managed Updates: AWS updated automatisch die Platform (OS, Runtime, etc.)
```

#### Step 9: Review and Create
1. Review all your settings
2. Click **"Submit"**
3. **Wait 5-15 minutes** for environment creation

#### Step 10: Verify Deployment
1. Once status is **"Ok"** (green checkmark)
2. Click on the **Environment URL** (looks like: `kn07-app-thomas.eu-central-1.elasticbeanstalk.com`)
3. Your application should be running!

📸 **Take Screenshot #5**: Running application in browser

### ✅ Deliverables for Part B
- [ ] Screenshots for all configured/changed areas
- [ ] Explanations for each configuration choice

---

## Part C: Created Resources and CloudFormation (20%)

### 🎯 Goal
Understand what resources Elastic Beanstalk created automatically and compare with KN06 (IaaS).

### 📝 Step-by-Step Instructions

#### Step 1: Check EC2 Resources
Go to the EC2 Console and verify the following resources were created:

**1.1 EC2 Instances**
1. Navigate to EC2 → Instances
2. Find instances with your Elastic Beanstalk app name
3. Note: There should be 1-4 instances depending on your scaling config

📸 **Screenshot #1**: EC2 Instances

**1.2 Security Groups**
1. Navigate to EC2 → Security Groups
2. Find security groups created by Elastic Beanstalk
3. Typical groups:
   - `awseb-*-stack-AWSEBSecurityGroup` (for EC2 instances)
   - `awseb-*-stack-AWSEBLoadBalancerSecurityGroup` (for load balancer)

📸 **Screenshot #2**: Security Groups with inbound/outbound rules

**1.3 Load Balancer**
1. Navigate to EC2 → Load Balancers
2. Find the Application Load Balancer created by Beanstalk

📸 **Screenshot #3**: Load Balancer details

**1.4 Target Groups**
1. Navigate to EC2 → Target Groups
2. Find the target group associated with your load balancer
3. Check registered targets (your EC2 instances)

📸 **Screenshot #4**: Target Group and registered targets

**1.5 Auto Scaling Groups**
1. Navigate to EC2 → Auto Scaling Groups
2. Find the ASG created by Elastic Beanstalk
3. Check the configuration (min, max, desired capacity)

📸 **Screenshot #5**: Auto Scaling Group configuration

#### Step 2: Explore CloudFormation
1. In AWS Console, search for "CloudFormation"
2. Click on the service
3. Find the stack(s) related to your Elastic Beanstalk application
   - Stack name will contain your environment name
4. Click on the stack
5. Go to the **"Resources"** tab
6. See ALL resources created automatically!

📸 **Screenshot #6**: CloudFormation stack and resources

#### Step 3: Compare with KN06
Think about the differences:

**In KN06 (IaaS - Manual Setup)**, you had to:
- Manually create EC2 instances
- Manually install and configure web server (Nginx)
- Manually set up security groups
- Manually configure load balancers
- Manually set up auto scaling
- Manual application deployment

**In KN07 (PaaS - Elastic Beanstalk)**, AWS did:
- ✅ Automatically created EC2 instances
- ✅ Automatically configured web server
- ✅ Automatically created security groups
- ✅ Automatically set up load balancer
- ✅ Automatically configured auto scaling
- ✅ Automatic deployment and updates

### 📚 CloudFormation vs Cloud-Init

#### What is CloudFormation?
**AWS CloudFormation** is an Infrastructure as Code (IaC) service that allows you to:
- Define AWS infrastructure using templates (JSON/YAML)
- Provision and manage entire environments as "stacks"
- Automate infrastructure deployment
- Manage the full lifecycle of resources (create, update, delete)
- Works at the **infrastructure layer**

**Example**: CloudFormation creates EC2 instances, databases, networking, load balancers, etc.

#### What is Cloud-Init?
**Cloud-Init** is an industry-standard tool that:
- Configures the **operating system inside** a virtual machine
- Runs during the **first boot** of an instance
- Executes user data scripts (shell scripts, configurations)
- Installs software, creates users, sets up services
- Works at the **guest OS layer**

**Example**: Cloud-Init installs Apache, creates user accounts, sets hostname, etc.

#### Key Differences

| Aspect | CloudFormation | Cloud-Init |
|--------|---------------|------------|
| **Layer** | Infrastructure (AWS resources) | Guest OS (inside the VM) |
| **Purpose** | Provisions infrastructure | Configures OS/software |
| **When it runs** | Anytime you deploy a stack | First boot only |
| **Scope** | Creates EC2, RDS, VPC, etc. | Installs packages, runs scripts |
| **File format** | JSON/YAML templates | Shell scripts, YAML |
| **AWS-specific** | Yes | No (multi-cloud) |

#### How they work together
1. **CloudFormation** creates an EC2 instance
2. In the template, you specify **UserData** (Cloud-Init script)
3. When the instance boots, **Cloud-Init** runs the UserData
4. Cloud-Init configures the OS (install software, etc.)

**Sample answer for the assignment**:
```
CloudFormation vs Cloud-Init:

CloudFormation:
- Infrastructure as Code (IaC) Service für AWS
- Erstellt und verwaltet AWS Ressourcen (EC2, RDS, VPC, etc.)
- Arbeitet auf der Infrastruktur-Ebene
- Verwendet JSON/YAML Templates
- Verwaltet den gesamten Lifecycle (create, update, delete)
- Beispiel: Erstellt einen Load Balancer mit 3 EC2 Instanzen

Cloud-Init:
- Tool für Betriebssystem-Konfiguration
- Läuft beim ersten Boot einer Instanz
- Arbeitet innerhalb der VM/Instanz
- Führt UserData Scripts aus
- Installiert Software, konfiguriert Services
- Beispiel: Installiert Apache, erstellt User, setzt Hostname

Unterschied:
CloudFormation ERSTELLT die Infrastruktur, Cloud-Init KONFIGURIERT das OS.
Oft werden beide zusammen verwendet: CloudFormation erstellt eine EC2 Instanz
und übergibt UserData an Cloud-Init, das beim Boot die Software installiert.
```

### ✅ Deliverables for Part C
- [ ] Explanation: What is CloudFormation? What's the difference to Cloud-Init?
- [ ] Screenshots of EC2 objects that were automatically created (Instances, Security Groups, Load Balancer, Target Groups, Auto Scaling)
- [ ] Screenshot of CloudFormation resources for your PaaS application

---

## 🎓 Summary

By completing this exercise, you've learned:
- ✅ How to use AWS RDS (PaaS database)
- ✅ How to deploy applications with Elastic Beanstalk (PaaS)
- ✅ The differences between PaaS and IaaS
- ✅ How CloudFormation automates infrastructure
- ✅ How PaaS abstracts away infrastructure management

**Key Takeaway**: PaaS services like RDS and Elastic Beanstalk handle the infrastructure for you, allowing you to focus on your application instead of managing servers!

---

## 🔗 Helpful Resources

- [AWS RDS Documentation](https://docs.aws.amazon.com/rds/)
- [AWS Elastic Beanstalk Documentation](https://docs.aws.amazon.com/elasticbeanstalk/)
- [AWS CloudFormation Documentation](https://docs.aws.amazon.com/cloudformation/)
- [Spring PetClinic GitHub](https://github.com/spring-projects/spring-petclinic)
- [Cloud-Init Documentation](https://cloud-init.io/)

---

## 🆘 Troubleshooting

### RDS Connection Issues
- ✅ Check security group allows port 3306 from your IP
- ✅ Verify "Public accessibility" is enabled
- ✅ Confirm you're using the correct endpoint
- ✅ Check password doesn't contain `#` or `-`

### Elastic Beanstalk Deployment Failed
- ✅ Check application logs in Beanstalk console
- ✅ Verify your application ZIP is correctly formatted
- ✅ Ensure you selected correct platform/runtime
- ✅ Check CloudWatch logs for error messages

### Can't Access Application URL
- ✅ Wait for environment to finish deploying (status = OK)
- ✅ Check security group allows HTTP (port 80)
- ✅ Verify load balancer is healthy
- ✅ Check target group has healthy targets

---

**Good luck with KN07! 🚀**
