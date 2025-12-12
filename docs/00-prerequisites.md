# ⚡ Prerequisites & Setup

## 1. Install Tools (via Chocolatey)
Open **PowerShell as Administrator** and run this single command to install all required software at once:

```powershell
choco install terraform terragrunt awscli vscode git -y
```

## 2. Configure AWS Credentials
1. Enter your keys when prompted (Default region: us-east-1, Format: json)
```powershell
aws configure --profile homelab
```
2. Set the profile for your current session
```powershell
$Env:AWS_PROFILE = "homelab"
```

3. Verify it works (Should show your Account ID and ARN)
```powershell
aws sts get-caller-identity
```

## 3. Setup VS Code Extensions
```powershell
code --install-extension hashicorp.terraform
code --install-extension hashicorp.hcl
```

## 4. Verify Installation

```powershell
echo "Terraform:  $(terraform -version)"
echo "Terragrunt: $(terragrunt -version)"
echo "AWS CLI:    $(aws --version)"
echo "Git:        $(git --version)"
```