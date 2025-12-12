# 🛠️ Tooling Strategy: Terragrunt & Terraform

## 1. What is Terragrunt?
Terragrunt is a thin wrapper that provides extra tools for keeping Terraform configurations **DRY** (Don't Repeat Yourself), working with multiple Terraform modules, and managing remote state.

In this project, **Terraform** is the engine that communicates with the AWS API to create resources, while **Terragrunt** is the orchestrator that manages the configuration and state files.

## 2. Why Terragrunt? (The Problems Solved)

### A. DRY Backend Configuration
**Without Terragrunt:** You must copy-paste the `backend "s3" {...}` block into every single module (`vpc/main.tf`, `ec2/main.tf`, etc.).
**With Terragrunt:** We define the backend **once** in the root `terragrunt.hcl`. All child modules automatically inherit this configuration.

### B. DRY CLI Arguments
**Without Terragrunt:** You often need long commands like `terraform apply -var-file=common.tfvars -var-file=region.tfvars`.
**With Terragrunt:** Arguments are defined in the code. You simply run `terragrunt apply`.

### C. Dependency Management
Terragrunt explicitly handles dependencies between infrastructure layers.
* *Example:* It knows it **must** deploy the VPC layer before the EC2 layer because the EC2 `terragrunt.hcl` contains a `dependency "vpc"` block.

## 3. Directory Structure (The "Live" Pattern)
This project uses a **Split-Repo** architecture pattern (Monorepo with logical separation):



* **`modules/` (The Blueprints):** Pure Terraform code (`.tf`). These are reusable templates that take inputs and create resources. They know *how* to build something, but not *what* specifically to build.
* **`live/` (The Implementation):** Terragrunt code (`.hcl`). These files define the specific environment (Dev/Prod), region (us-east-1), and variable values.

---

## 4. Deep Dive: Features & Patterns Used

### A. Configuration Management (DRY Principles)
We use three key features to reduce code duplication:
* **Remote State Inheritance:** The `remote_state` block in the root `terragrunt.hcl` configures S3/DynamoDB once. Every child module inherits this, so we never write a backend block manually.
* **Code Generation:** The `generate "provider"` block dynamically creates a `provider.tf` file with our AWS Region and Profile settings in every folder.
* **Include Block:** `include { path = find_in_parent_folders() }` tells every child module to read the root configuration.

### B. Advanced Dependency Handling
We pass data between modules without complex state lookups:
* **Dependency Blocks:** `dependency "name" { config_path = "..." }` links modules (e.g., EC2 reading VPC IDs).
* **Mock Outputs:** `mock_outputs = { ... }` allows `terragrunt plan` to work even if the parent dependency (like the VPC) hasn't been created yet by generating fake temporary IDs.

### C. Helper Functions
We use Terragrunt's built-in functions to make paths dynamic:
* **`find_in_parent_folders()`**: Traverses up the directory tree to find the root config.
* **`get_terragrunt_dir()`**: Returns the absolute path of the current directory. Used to point modules to local config folders (e.g., `config_folder = "${get_terragrunt_dir()}/configs"`).

---

## 5. CLI Commands & Operations

| Command | Description |
| :--- | :--- |
| `terragrunt init` | Downloads provider plugins and configures the S3 backend. |
| `terragrunt plan` | Shows a preview of changes without making them. |
| `terragrunt apply` | Deploys the infrastructure. |
| `terragrunt run-all apply` | **Orchestrator Mode:** Deploys all sub-folders in the correct dependency order (e.g., VPC $\rightarrow$ EC2). |
| `terragrunt run-all destroy` | **Nuclear Option:** Destroys all resources in reverse dependency order (EC2 $\rightarrow$ VPC). |
| `terragrunt force-unlock <ID>` | **Emergency Fix:** Removes a lock from the DynamoDB table if a previous apply command crashed. |