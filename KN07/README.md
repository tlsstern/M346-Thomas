# KN07: PaaS - Thomas Stern

## A) Database in PaaS Model (20%)

### RDS Database Setup

**Connection Test:**

![MySQL Query Test](screenshots/A/MySQL_Query.png)

---

### Why PaaS/SaaS Database is Better than Self-Managed

**Advantages:**

1. **Automatic Maintenance** - AWS handles OS patches, database updates, and security fixes automatically
2. **Automated Backups** - Daily automatic backups with point-in-time recovery
3. **High Availability** - Multi-AZ deployment with automatic failover
4. **Scalability** - Easy vertical scaling (instance size) and horizontal scaling (read replicas)
5. **Monitoring** - Built-in CloudWatch metrics and Performance Insights
6. **Security** - Encryption at rest, encryption in transit, IAM authentication
7. **Cost-Effective** - No need to manage infrastructure, pay only for what you use
8. **Focus on Application** - Developers can focus on building features instead of managing databases

**Disadvantages of Self-Managed:**
- Manual patching and security updates required
- Need to configure and manage backups yourself
- Scaling requires downtime and manual intervention
- Higher operational overhead and expertise needed
- Potential security risks if not configured properly

---

## B) PaaS Application Deployment (60%)

### Elastic Beanstalk Application

**Application Details:**
- **Application Name**: KN07-App
- **Environment Name**: KN07-App-env
- **Platform**: Java (Amazon Corretto 17)
- **Sample Application**: AWS Corretto Sample Application

**Screenshots:**

**1. Service Access & Networking Configuration:**

![Service Access Configuration](screenshots/B/Service_Access.png)

**Configuration Choices:**
- **Service Role**: Allows Elastic Beanstalk to manage AWS resources on your behalf
- **VPC**: Default VPC for simplicity (in production, use custom VPC)
- **Public IP**: Enabled for direct internet access to instances
- **Subnets**: Multi-AZ deployment across 3 availability zones for high availability

---

**2. Instance Traffic and Scaling:**

![Instance Scaling Configuration](screenshots/B/Instance_Scaling.png)

**Configuration Choices:**
- **Load Balancer**: Application Load Balancer (ALB) distributes traffic across multiple instances
- **Instance Type**: t3.micro (cost-effective for testing, sufficient for low traffic)
- **Min Instances**: 1 (ensures at least one instance is always running)
- **Max Instances**: 4 (allows scaling up during high traffic)
- **Auto Scaling**: Based on network metrics (NetworkOut) for automatic scaling

**Why Load Balancer?**
- Distributes traffic evenly across healthy instances
- Provides health checks and automatic instance replacement
- Enables zero-downtime deployments
- Supports SSL/TLS termination

---

**3. Monitoring & Logging:**

![Monitoring Configuration](screenshots/B/Monitoring_Logging.png)

**Configuration Choices:**
- **CloudWatch Monitoring**: Basic monitoring (5-minute intervals) enabled by default
- **Enhanced Health Reporting**: Provides detailed health status of the environment
- **Log Streaming**: Automatically streams application logs to CloudWatch Logs
- **Managed Updates**: Weekly maintenance window for automatic platform updates

**Why CloudWatch?**
- Centralized logging for troubleshooting
- Performance metrics and alerting
- Historical data for capacity planning
- Integration with other AWS services

---

**4. Running Application:**

![Running Application](screenshots/B/Running_App.png)

✅ Application successfully deployed and accessible via the Elastic Beanstalk URL.

---

## C) Auto-Created Resources and CloudFormation (20%)

### AWS Resources Created Automatically

When deploying an Elastic Beanstalk application with load balancing, AWS automatically creates the following resources via CloudFormation:

**1. EC2 Instances:**

![EC2 Instances](screenshots/C/EC2_Instances.png)

- **Instance Type**: t3.micro
- **Status**: Running

---

**2. Security Groups:**

![Security Groups](screenshots/C/Security_Groups.png)

Two security groups were created:
- **Instance Security Group**: Protects EC2 instances, allows HTTP only from Load Balancer
- **Load Balancer Security Group**: Protects Load Balancer, allows HTTP from anywhere

**Security Best Practice:** Instances are not directly exposed to the internet, only accessible through the Load Balancer.

---

**3. Application Load Balancer:**

![Load Balancer](screenshots/C/Load_Balancer.png)

- **Type**: Application Load Balancer
- **Status**: Active
- **Scheme**: Internet-facing
- **Availability Zones**: 3 (us-east-1a, us-east-1b, us-east-1c)

---

**4. Target Groups:**

![Target Groups](screenshots/C/Target_Groups.png)

- **Name**: awseb-AWSEB-GXGVMUHTTWWZ
- **Target Type**: Instance
- **Protocol**: HTTP (Port 80)
- **Health Check**: HTTP on port 80
- **Registered Targets**: 1 healthy instance

---

**5. Auto Scaling Group:**

![Auto Scaling Group](screenshots/C/Auto_Scaling.png)

- **Name**: awseb-e-b3hga3ddxp-stack-AWSEBAutoScalingGroup-pMQtsKv64dRx
- **Desired Capacity**: 1 instance
- **Min**: 1, **Max**: 4
- **Instance Type**: t3.micro
- **Scaling Policies**:
  - **Scale Up**: Triggered when NetworkOut > 6,000,000 bytes for 300 seconds
  - **Scale Down**: Triggered when NetworkOut < 2,000,000 bytes for 300 seconds

---

**6. CloudFormation Stack:**

![CloudFormation Resources](screenshots/C/CloudFormation.png)

- **Stack Name**: awseb-e-b3hga3ddxp-stack
- **Total Resources Created**: 14
- **Status**: CREATE_COMPLETE

**Key Resources Include:**
- Auto Scaling Group and Launch Configuration
- Security Groups
- Load Balancer, Target Group, and Listeners
- CloudWatch Alarms for scaling policies
- IAM roles and instance profiles

---

### CloudFormation vs Cloud-Init

#### What is CloudFormation?

**CloudFormation** is AWS's **Infrastructure as Code (IaC)** service that allows you to define and provision AWS infrastructure resources using JSON or YAML templates.

**Key Features:**
- **Declarative**: You describe what resources you want, not how to create them
- **Infrastructure Management**: Creates entire stacks of AWS resources (VPC, EC2, RDS, Load Balancers, etc.)
- **Version Control**: Templates can be versioned and stored in Git
- **Rollback**: Automatically rolls back if creation fails
- **Updates**: Can update existing stacks without recreating everything
- **Drift Detection**: Detects manual changes made outside of CloudFormation

**Example Use Cases:**
- Creating an entire application environment (VPC, subnets, EC2, RDS, Load Balancer)
- Setting up multi-tier applications
- Replicating environments (Dev, Staging, Production)

---

#### What is Cloud-Init?

**Cloud-Init** is an industry-standard tool for **initializing cloud instances at boot time**. It runs scripts to configure the operating system and applications.

**Key Features:**
- **OS-Level Configuration**: Configures the operating system (users, packages, files)
- **Boot-Time Execution**: Runs once when the instance first starts
- **Application Setup**: Installs and configures applications (Nginx, databases, etc.)
- **User Data**: Passed to EC2 instances via User Data field

**Example Use Cases:**
- Installing software packages (`apt install nginx`)
- Creating users and SSH keys
- Configuring network settings
- Starting services automatically

---

#### Key Differences

| Aspect | CloudFormation | Cloud-Init |
|--------|---------------|------------|
| **Scope** | AWS Infrastructure (resources) | OS Configuration (software) |
| **Level** | Infrastructure Layer | Operating System Layer |
| **Purpose** | Create/manage AWS resources | Configure instances at boot |
| **Format** | JSON/YAML templates | YAML or shell scripts |
| **Execution** | AWS API calls | Runs inside the instance |
| **Idempotency** | Yes (manages state) | Partially (depends on script) |
| **Rollback** | Automatic | Manual |
| **Example** | Create VPC, EC2, RDS | Install Apache, configure users |

**Zusammenfassung:**
- **CloudFormation** = "What AWS resources do I need?" (Infrastructure)
- **Cloud-Init** = "How do I configure those resources?" (Software)

In Elastic Beanstalk, both are used together:
1. **CloudFormation** creates the infrastructure (EC2, Load Balancer, etc.)
2. **Cloud-Init/User Data** configures the instances with the application

---
