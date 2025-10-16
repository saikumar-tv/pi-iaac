# Terraform AKS Deployment

This Terraform project deploys an Azure Kubernetes Service (AKS) cluster and then deploys ArgoCD and the Kube-Prometheus-Stack (which includes Grafana and Prometheus) onto the cluster using Helm.

## Table of Contents
- [Prerequisites](#prerequisites)
- [Setup](#setup)
- [Post-Deployment Access](#post-deployment-access)
- [Terraform Code Flow](#terraform-code-flow)

## Prerequisites

Before you begin, ensure you have the following tools installed:

*   **Azure CLI:** For authenticating with Azure and managing resources.
    *   [Install Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)
*   **Terraform:** For deploying the infrastructure.
    *   [Install Terraform](https://learn.hashicorp.com/terraform/getting-started/install.html)
*   **kubectl:** For interacting with the Kubernetes cluster.
    *   [Install kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)

## Setup

1.  **Log in to Azure:**
    ```bash
    az login
    ```

2.  **Initialize Terraform:**
    Navigate to the root of this Terraform project and initialize the providers.
    ```bash
    terraform init
    ```

3.  **Review the Plan (Optional but Recommended):**
    See what Terraform plans to create, modify, or destroy.
    ```bash
    terraform plan
    ```

4.  **Apply the Terraform Configuration:**
    Deploy the AKS cluster and the Helm releases.
    ```bash
    terraform apply
    ```
    You will be prompted to confirm the apply operation. Type `yes` and press Enter.

## Post-Deployment Access

After successful deployment, you can connect to your AKS cluster and access the deployed applications.

1.  **Configure `kubectl`:**
    Get the credentials for your AKS cluster and configure `kubectl` to connect to it. Replace `PI-AKS-rg` with your actual resource group name and `PI-aks-cluster` with your actual AKS cluster name if they differ.
    ```bash
    az aks get-credentials --resource-group PI-AKS-rg --name PI-aks-cluster --overwrite-existing
    ```

2.  **Access ArgoCD Dashboard:**
    *   **External IP:** To get the external IP for ArgoCD, run:
        ```bash
        kubectl get svc -n argocd argocd-server -o jsonpath='{.status.loadBalancer.ingress[0].ip}'
        ```
        (Example IP: `4.187.240.59`)
    *   **URL:** `https://<ARGO_CD_EXTERNAL_IP>` (e.g., `https://4.187.240.59`)
    *   **Username:** `admin`
    *   **Password:** To get the initial admin password, run:
        ```bash
        kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
        ```
        (Example Password: `req8I0jemLrqWlEX`)

3.  **Access Grafana Dashboard:**
    *   **External IP:** To get the external IP for Grafana, run:
        ```bash
        kubectl get svc -n monitoring kube-prometheus-stack-grafana -o jsonpath='{.status.loadBalancer.ingress[0].ip}'
        ```
        (Example IP: `4.187.234.21`)
    *   **URL:** `http://<GRAFANA_EXTERNAL_IP>` (e.g., `http://4.187.234.21`)
    *   **Username:** `admin`
    *   **Password:** To get the initial admin password, run:
        ```bash
        kubectl get secret -n monitoring kube-prometheus-stack-grafana -o jsonpath="{.data.admin-password}" | base64 --decode
        ```
        (Example Password: `prom-operator`)

## Terraform Code Flow

This project is structured to logically separate concerns:

*   **`main.tf`**:
    *   Defines the Azure provider and Helm provider configurations.
    *   Creates an Azure Resource Group (`azurerm_resource_group`).
    *   Calls the `aks` module to deploy the AKS cluster.
    *   Creates a `local_file` resource to save the generated `kube_config` to a file.
    *   Deploys ArgoCD using a `helm_release` resource, configuring its server service as a `LoadBalancer`.
    *   Deploys the Kube-Prometheus-Stack (including Grafana) using a `helm_release` resource, configuring Grafana's service as a `LoadBalancer`.

*   **`variables.tf`**:
    *   Declares input variables for the Terraform configuration, such as `rgname`, `location`, and `cluster-name`. These variables allow for customization of the deployment.

*   **`output.tf`**:
    *   Defines output values that are displayed after Terraform applies the configuration, such as the resource group name and location.

*   **`modules/aks/`**:
    *   This directory contains a reusable Terraform module specifically for deploying the AKS cluster. It encapsulates the details of AKS creation, making the main configuration cleaner. It likely contains its own `main.tf`, `variables.tf`, and `output.tf` to manage the AKS cluster's resources.