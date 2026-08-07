# Terraform Two-Tier Application on AWS

**HUG Lagos/Ibadan Terraform Challenge Week 3 — Project 3**

This project provisions a secure, two-tier architecture on AWS using Terraform. It follows infrastructure best practices: modular code organization, least-privilege security groups, and remote state management.

## Architecture Overview

- **Networking tier**: A VPC spanning two Availability Zones, with 2 public subnets and 2 private subnets, an Internet Gateway for public traffic, and a NAT Gateway for outbound-only private traffic.
- **Compute tier**: A single EC2 instance in a public subnet, running Nginx, serving a static HTML page deployed via a startup script.
- **Database tier**: A MySQL RDS instance in the private subnets, with public accessibility disabled, reachable only from the compute instance's security group.
- **Security**: Two security groups — one for compute (HTTP open to the internet, SSH restricted to a single IP), and one for the database (MySQL restricted to the compute security group only).

```
                        Internet
                           │
                    ┌──────▼──────┐
                    │  Internet   │
                    │  Gateway    │
                    └──────┬──────┘
                           │
              ┌────────────┴────────────┐
              │           VPC            │
              │                          │
      ┌───────▼────────┐        ┌────────▼───────┐
      │ Public Subnet 1 │        │ Public Subnet 2│
      │  (AZ-a)         │        │  (AZ-b)        │
      │  ┌───────────┐  │        │                │
      │  │  EC2 +    │  │        │                │
      │  │  Nginx    │  │        │                │
      │  └───────────┘  │        │                │
      └────────┬─────────┘        └────────────────┘
               │ NAT Gateway
      ┌────────▼─────────┐        ┌────────────────┐
      │ Private Subnet 1  │        │ Private Subnet 2│
      │  (AZ-a)           │        │  (AZ-b)         │
      │  ┌─────────────┐  │        │                 │
      │  │  RDS MySQL  │  │        │                 │
      │  └─────────────┘  │        │                 │
      └────────────────────┘        └─────────────────┘
```

## Project Structure

```
terraform-two-tier/
├── modules/
│   ├── vpc/                # VPC resource only
│   ├── networking/         # Subnets, IGW, NAT, route tables
│   ├── security-groups/    # Compute SG + DB SG
│   ├── compute/             # EC2 instance + key pair + Nginx startup script
│   └── database/            # RDS instance + DB subnet group
├── main.tf                  # Root module — wires everything together
├── variables.tf              # Root input variables
├── outputs.tf                 # Root outputs
├── versions.tf                # Provider + remote state backend config
├── terraform.tfvars           # Variable values (gitignored — not committed)
├── screenshots/                # Deliverable screenshots (see below)
├── .gitignore
└── README.md
```

## Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/downloads) >= 1.5.0
- An AWS account with credentials configured (`aws configure`)
- [AWS CLI](https://aws.amazon.com/cli/) installed
- An SSH key pair (`ssh-keygen -t rsa -b 2048 -f ~/.ssh/id_rsa` if you don't have one)
- An S3 bucket and DynamoDB table for remote state (created once, manually, before first use — see below)

## Remote State Setup (one-time)

This project stores Terraform state remotely in S3 with DynamoDB locking. Before running `terraform init` for the first time, create the backend resources:

```bash
aws s3 mb s3://YOUR-UNIQUE-TFSTATE-BUCKET-NAME --region us-east-1

aws dynamodb create-table \
  --table-name terraform-locks \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region us-east-1
```

Update the bucket name in `versions.tf` under the `backend "s3"` block to match.

## Configuration

Copy the example variables file and fill in your own values:

```bash
cp terraform.tfvars.example terraform.tfvars
```

Key variables you'll need to set:

| Variable | Description | Example |
|---|---|---|
| `aws_region` | AWS region to deploy into | `us-east-1` |
| `vpc_cidr_block` | CIDR block for the VPC | `10.0.0.0/16` |
| `public_subnet_cidr_blocks` | CIDRs for the 2 public subnets | `["10.0.1.0/24", "10.0.2.0/24"]` |
| `private_subnet_cidr_blocks` | CIDRs for the 2 private subnets | `["10.0.11.0/24", "10.0.12.0/24"]` |
| `azs` | Availability Zones to spread subnets across | `["us-east-1a", "us-east-1b"]` |
| `my_ip_cidr_block` | Your public IP, for SSH access (get it via `curl ifconfig.me`) | `1.2.3.4/32` |
| `instance_type` | EC2 instance type | `t3.micro` |
| `key_name` | Name for the generated EC2 key pair | `my-challenge-key` |
| `public_key_path` | Path to your local SSH public key | `~/.ssh/id_rsa.pub` |
| `db_name` | Initial database name | `myappdb` |
| `db_username` | RDS master username | `admin` |
| `db_password` | RDS master password (sensitive — do not commit) | — |

> ⚠️ `terraform.tfvars` is gitignored since it contains your IP and DB password. Never commit it.

## Deployment

```bash
# Initialize providers, modules, and backend
terraform init

# Review what will be created
terraform plan -out=tfplan

# Apply the plan
terraform apply "tfplan"
```

Deployment takes roughly 6–8 minutes — the NAT Gateway and RDS instance are the slowest resources to provision.

Once complete, Terraform will output the EC2 public IP and DNS. Open it in a browser to confirm the Nginx page is live:

```bash
terraform output instance_public_ip
```

## Verifying the Deployment

**Webpage:**
```bash
curl http://$(terraform output -raw instance_public_ip)
```

**SSH into the instance** (only works from the IP set in `my_ip_cidr_block`):
```bash
ssh -i ~/.ssh/id_rsa ec2-user@$(terraform output -raw instance_public_ip)
```

**Confirm the database is not publicly reachable** (should time out/refuse from your local machine):
```bash
nc -zv $(terraform output -raw db_endpoint | cut -d: -f1) 3306
```

## Outputs

| Output | Description |
|---|---|
| `vpc_id` | ID of the created VPC |
| `public_subnet_ids` | IDs of the two public subnets |
| `private_subnet_ids` | IDs of the two private subnets |
| `instance_public_ip` | Public IP of the EC2 instance |
| `instance_public_dns` | Public DNS of the EC2 instance |
| `db_endpoint` | RDS connection endpoint (sensitive) |

## Security Design

- **Compute security group**: allows inbound HTTP (80) from anywhere, and SSH (22) only from a single whitelisted IP.
- **Database security group**: allows inbound MySQL (3306) only from the compute security group — no CIDR-based access at all.
- **RDS `publicly_accessible`** is explicitly set to `false`.
- **State file** is stored in S3 with encryption enabled and locked via DynamoDB to prevent concurrent writes.

## Screenshots

All deliverable screenshots are stored in the [`/screenshots`](./screenshots) folder:

| File | Description |
|---|---|
| `screenshots/vpc.png` | VPC console view showing the created VPC |
| `screenshots/ec2-running.png` | EC2 console showing the compute instance in "Running" state |
| `screenshots/rds-running.png` | RDS console showing the database instance in "Available" state |
| `screenshots/webpagenew.png` | Browser screenshot of the live Nginx webpage |

## Tearing Down

To avoid ongoing AWS charges (NAT Gateway and RDS both bill hourly):

```bash
terraform destroy
```

Type `yes` when prompted. This removes all 20 resources created by this project.

## Author

Oghenetejiri Edwin — HUG Lagos/Ibadan Terraform Challenge, Week 3