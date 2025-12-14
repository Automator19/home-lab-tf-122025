Here is a comprehensive design and operational document for your OpenTelemetry setup. You can use this for a README, Confluence page, or internal wiki.

---

# OpenTelemetry Collector Infrastructure Design

## 1. Overview
This document outlines the architecture and deployment strategy for the OpenTelemetry (OTel) Collector running on AWS Fargate. The Collector serves as a centralized telemetry processing system, receiving traces, metrics, and logs from applications via the OTLP protocol and exporting them to AWS CloudWatch and other observability backends.

## 2. Architecture

The system is designed as a standalone ECS Service running on AWS Fargate. It decouples telemetry collection from application logic, allowing for centralized management of secrets, sampling rates, and export destinations without redeploying application code.



### **Data Flow**
1.  **Ingestion:** Applications send telemetry data (Traces/Metrics) to the Collector via OTLP (OpenTelemetry Protocol).
    * **gRPC:** Port 4317
    * **HTTP:** Port 4318
2.  **Processing:** The Collector buffers and batches the data to optimize network throughput.
3.  **Export:**
    * **Metrics:** Sent to Amazon CloudWatch Metrics via the `awsemf` exporter.
    * **Logs:** (Optional) Sent to CloudWatch Logs.
    * **Debug:** Telemetry is logged to the console for immediate troubleshooting during development.

---

## 3. Infrastructure as Code (IaC) Strategy

The infrastructure is provisioned using **Terraform** managed by **Terragrunt** to ensure a DRY (Don't Repeat Yourself) and modular codebase.

### **Module Hierarchy**
The code is organized into three distinct layers to promote reusability and standardization.

1.  **Standard Modules (The "Building Blocks")**
    * *Purpose:* Generic, atomic resources that adhere to company tagging and security standards.
    * *Components:*
        * **IAM Role:** Creates roles with strictly scoped trust policies.
        * **Security Group:** Manages firewall rules and VPC association.
        * **ECS Fargate:** Manages the Task Definition and ECS Service lifecycle.

2.  **Blueprint Module (The "Logic")**
    * *Purpose:* A composition module that orchestrates the Standard Modules to build the specific "OpenTelemetry Collector" solution.
    * *Responsibilities:*
        * Uploads the OTel configuration YAML to **AWS Systems Manager (SSM) Parameter Store**.
        * Creates specific **IAM Roles** (Execution Role for pulling images/reading config; Task Role for writing metrics).
        * Configures the **Security Group** to open ports 4317 and 4318.
        * Links these components into a resilient **ECS Service**.

3.  **Live Configuration (The "Deployment")**
    * *Purpose:* Environment-specific instantiation of the Blueprint.
    * *Function:* Uses **Terragrunt** to inject environment variables (VPC IDs, Subnet IDs) dynamically from existing network modules.

---

## 4. Security & Networking

### **IAM Roles & Permissions**
The infrastructure operates on the principle of Least Privilege.

* **Task Execution Role:**
    * Permitted to pull container images from ECR.
    * Permitted to read *only* the specific SSM Parameter containing the OTel configuration.
    * Permitted to write logs to CloudWatch (stdout/stderr).
* **Task Role:**
    * Permitted to write metrics and logs to Amazon CloudWatch (application data).

### **Network Configuration**
* **VPC Placement:** The service runs in Public Subnets (or Private Subnets with NAT Gateway) to ensure connectivity to AWS APIs.
* **Security Group:**
    * **Inbound:** Accepts TCP traffic on ports 4317 (gRPC) and 4318 (HTTP).
    * **Outbound:** Allows all outbound traffic (required to reach AWS APIs and external vendors).

### **Configuration Management**
* **Dynamic Config:** The Collector configuration (YAML) is **not** baked into the container image. Instead, it is injected at runtime via an environment variable (`AOT_CONFIG_CONTENT`) sourced directly from SSM Parameter Store. This allows configuration updates without rebuilding the Docker image.

---

## 5. Operational Guide

### **How to Update Configuration**
To modify the telemetry pipeline (e.g., add a new exporter or change sampling rates):
1.  Edit the local `otel-config.yaml` file in the Live directory.
2.  Run the deployment command (`terragrunt apply`).
3.  Terragrunt will update the SSM Parameter.
4.  The ECS Service will automatically be forced to redeploy, picking up the new configuration immediately.

### **Verification & Troubleshooting**

**1. Check Service Status**
* Navigate to the ECS Console and verify the Task status is `RUNNING`.
* Ensure the "Last Status" is not flapping between `RUNNING` and `STOPPED`.

**2. Verify Logs**
* Check the **CloudWatch Logs** group `/ecs/otel-collector-{env}`.
* Look for the startup message: *"Everything is ready. Begin running and processing data."*
* If using the `debug` exporter, verify that incoming metrics are printed to these logs.

**3. Verify Connectivity**
* From a client machine or application, send a test payload using `curl` to the Collector's public IP (or internal DNS).
* A response of `HTTP 200` or `HTTP 201` indicates successful ingestion.

**4. Verify Metrics**
* Navigate to **CloudWatch Metrics** > **All Metrics**.
* Look for the namespace **`Otel/Metrics`**.
* Verify that data points are populating for the expected service names.