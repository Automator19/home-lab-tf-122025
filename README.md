# 🏠 My AWS Home Lab

Welcome to my infrastructure-as-code learning repository. I am using **Terragrunt** and **Terraform** to deploy a modular, cost-effective AWS environment.

## 📚 Documentation
* **[Prerequisites](./docs/00-prerequisites.md)** - Tools and Configd required for the lab setup.
* **[Terragrunt-Concepts](./docs/01-terragrunt-concepts.md)** - Terragrunt concepts explained.
* **[Network Layer (VPC)](./docs/02-vpc.md)** - Logic for subnets, gateways, and routing.
* **[Compute Layer (EC2)](./docs/03-ec2.md)** - Logic for Spot instances, security groups, and auto-scaling.

## 🚀 Quick Start
1. Configure AWS credentials: `$Env:AWS_PROFILE = "homelab"`
2. Deploy VPC: `cd live/dev/us-east-1/vpc && terragrunt apply`
3. Deploy Apps: `cd live/dev/us-east-1/ec2 && terragrunt apply`