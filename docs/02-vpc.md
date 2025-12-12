# 🌐 Component: Networking Layer (VPC)

## 1. High-Level Overview
The VPC (Virtual Private Cloud) module lays the foundational network for the Home Lab. It provides an isolated environment where compute resources (EC2, Lambda, ECS) reside.

**Key Design Decisions:**
* **Layered Architecture:** Networking is decoupled from the Application layer to reduce "Blast Radius."
* **Cost Optimization:** Uses **Public Subnets only** to avoid the high cost of NAT Gateways (~$32/mo) while maintaining a standard VPC structure.

## 2. Architecture Diagram
[ Internet ] <--> [ Internet Gateway ] <--> [ VPC Route Table ] <--> [ Public Subnet ] <--> [ EC2 Instances ]

* **VPC CIDR:** `10.0.0.0/16` (65,536 IPs)
* **Public Subnet:** `10.0.1.0/24` (256 IPs)

## 3. Technical Implementation

### The Module (`modules/vpc`)
The reusable Terraform logic including:
* `aws_vpc`: The main network container.
* `aws_internet_gateway`: Provides internet access.
* `aws_subnet`: Configured with `map_public_ip_on_launch = true` so instances automatically get reachable IPs.

### The Live Config (`live/.../vpc`)
* **State Path:** `live/dev/us-east-1/vpc/terraform.tfstate`
* **Inputs:**
    ```hcl
    inputs = {
      env_name           = "dev-homelab"
      vpc_cidr           = "10.0.0.0/16"
      public_subnet_cidr = "10.0.1.0/24"
    }
    ```

## 4. Usage & Dependencies

### How other modules use this
This module outputs `vpc_id` and `public_subnet_id`. Downstream modules (like EC2) consume these via Terragrunt dependencies:

**Example in EC2 `terragrunt.hcl`:**
```hcl
dependency "vpc" {
  config_path = "../vpc"
}
inputs = {
  vpc_id = dependency.vpc.outputs.vpc_id
}