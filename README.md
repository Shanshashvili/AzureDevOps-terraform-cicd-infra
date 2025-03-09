## This task requires the creation of a backend resource group, a storage account, a container, and the generation of five backend keys.

## NOTE: Template is not tested
---
## **How to Use Templates in Azure DevOps Pipelines**
### **Why Use Templates?**
- **Reduce duplication** (e.g., `Terraform Init`, `Terraform Plan`, and `Terraform Apply` are repeated across environments).
- **Improve maintainability** (update once, use everywhere).
- **Enhance readability** (shorter pipeline files).

---

## **🔹 Step 1: Organize Your Pipeline into Templates**
### **1️⃣ Create a `templates` folder in your repository**
Store the YAML templates here:
```
/templates
  ├── terraform-init.yml
  ├── terraform-plan.yml
  ├── terraform-apply.yml
  ├── manual-validation.yml
  ├── build.yml
```

---

## **🔹 Step 2: Create Templates**
### **1️⃣ `terraform-init.yml` (Terraform Initialization)**
```yaml
parameters:
  environment: ""
  state_key: ""

steps:
  - task: TerraformTaskV2@2
    displayName: "Terraform Init - ${{ parameters.environment }}"
    inputs:
      provider: "azurerm"
      command: "init"
      backendServiceArm: "$(AZURE_SERVICE_CONNECTION)"
      backendAzureRmResourceGroupName: "$(TF_STATE_RESOURCE_GROUP)"
      backendAzureRmStorageAccountName: "$(TF_STATE_STORAGE_ACCOUNT)"
      backendAzureRmContainerName: "$(TF_STATE_CONTAINER)"
      backendAzureRmKey: "${{ parameters.state_key }}"
    env:
      ARM_CLIENT_ID: "$(ARM_CLIENT_ID)"
      ARM_CLIENT_SECRET: "$(ARM_CLIENT_SECRET)"
      ARM_SUBSCRIPTION_ID: "$(ARM_SUBSCRIPTION_ID)"
      ARM_TENANT_ID: "$(ARM_TENANT_ID)"
      TF_LOG: DEBUG
```

---

### **2️⃣ `terraform-plan.yml` (Terraform Plan)**
```yaml
parameters:
  environment: ""
  state_key: ""

steps:
  - task: TerraformTaskV2@2
    displayName: "Terraform Plan - ${{ parameters.environment }}"
    inputs:
      provider: "azurerm"
      command: "plan"
      environmentServiceNameAzureRM: "$(AZURE_SERVICE_CONNECTION)"
      backendAzureRmResourceGroupName: "$(TF_STATE_RESOURCE_GROUP)"
      backendAzureRmStorageAccountName: "$(TF_STATE_STORAGE_ACCOUNT)"
      backendAzureRmContainerName: "$(TF_STATE_CONTAINER)"
      backendAzureRmKey: "${{ parameters.state_key }}"
    env:
      ARM_CLIENT_ID: "$(ARM_CLIENT_ID)"
      ARM_CLIENT_SECRET: "$(ARM_CLIENT_SECRET)"
      ARM_SUBSCRIPTION_ID: "$(ARM_SUBSCRIPTION_ID)"
      ARM_TENANT_ID: "$(ARM_TENANT_ID)"
      TF_LOG: DEBUG
```

---

### **3️⃣ `terraform-apply.yml` (Terraform Apply)**
```yaml
parameters:
  environment: ""
  state_key: ""

steps:
  - task: TerraformTaskV2@2
    displayName: "Terraform Apply - ${{ parameters.environment }}"
    inputs:
      provider: "azurerm"
      command: "apply"
      environmentServiceNameAzureRM: "$(AZURE_SERVICE_CONNECTION)"
      backendAzureRmResourceGroupName: "$(TF_STATE_RESOURCE_GROUP)"
      backendAzureRmStorageAccountName: "$(TF_STATE_STORAGE_ACCOUNT)"
      backendAzureRmContainerName: "$(TF_STATE_CONTAINER)"
      backendAzureRmKey: "${{ parameters.state_key }}"
    env:
      ARM_CLIENT_ID: "$(ARM_CLIENT_ID)"
      ARM_CLIENT_SECRET: "$(ARM_CLIENT_SECRET)"
      ARM_SUBSCRIPTION_ID: "$(ARM_SUBSCRIPTION_ID)"
      ARM_TENANT_ID: "$(ARM_TENANT_ID)"
      TF_LOG: DEBUG
```

---

### **4️⃣ `manual-validation.yml` (Manual Approval)**
```yaml
parameters:
  notifyUsers: "your-email@example.com"
  timeoutMinutes: 2880
  displayName: "Wait for External Validation"

steps:
  - task: ManualValidation@0
    displayName: "${{ parameters.displayName }}"
    timeoutInMinutes: ${{ parameters.timeoutMinutes }}
    inputs:
      notifyUsers: "${{ parameters.notifyUsers }}"
      instructions: "Please validate and approve deployment."
      onTimeout: "resume"
```

---

### **5️⃣ `build.yml` (Build Stage)**
```yaml
steps:
  - script: |
      bash scripts/validate_commit.sh "$(Build.SourceVersionMessage)"
    displayName: "Validate Commit Message"

  - script: |
      bash scripts/set_build_number.sh
    displayName: "Set Build Number Format"  

  - task: TerraformInstaller@0
    displayName: "Install Terraform"
    inputs:
      terraformVersion: "latest"

  - script: |
      terraform fmt -check -recursive
    displayName: "Terraform Format Check"

  - task: TerraformTaskV2@2
    displayName: "Terraform Validate"
    inputs:
      provider: "azurerm"
      command: "validate"
    env:
      ARM_CLIENT_ID: "$(ARM_CLIENT_ID)"
      ARM_CLIENT_SECRET: "$(ARM_CLIENT_SECRET)"
      ARM_SUBSCRIPTION_ID: "$(ARM_SUBSCRIPTION_ID)"
      ARM_TENANT_ID: "$(ARM_TENANT_ID)"
      TF_LOG: DEBUG
```

---

## **🔹 Step 3: Use Templates in Your Main Pipeline**
### **Updated `azure-pipelines.yml` (Shorter & Clean)**
```yaml
trigger: none

variables:
- group: Terraform-Backend
- group: Terraform-Provider
- group: AzureDevOps-Provider
- group: DEV-Environment
- group: QA-Environment
- group: UAT-Environment
- group: PROD-Environment

stages:

# Build Stage
- stage: Build
  displayName: "Build Stage"
  jobs:
  - job: Build
    displayName: "Validate & Prepare Terraform Artifacts"
    steps:
      - template: templates/build.yml

# Terraform Plan & Apply for DEV
- stage: Terraform_DEV
  displayName: "Terraform Plan & Apply (DEV)"
  dependsOn: Build
  jobs:
  - deployment: Plan_DEV
    displayName: "Terraform Plan (DEV)"
    environment: DEV
    strategy:
      runOnce:
        deploy:
          steps:
            - template: templates/terraform-init.yml
              parameters:
                environment: "DEV"
                state_key: "$(DEV_TF_STATE_KEY)"

            - template: templates/terraform-plan.yml
              parameters:
                environment: "DEV"
                state_key: "$(DEV_TF_STATE_KEY)"

  - job: waitForValidation
    displayName: "Manual Approval (DEV)"
    pool: server
    steps:
      - template: templates/manual-validation.yml
        parameters:
          notifyUsers: "your-email@example.com"

  - deployment: Apply_DEV
    displayName: "Terraform Apply (DEV)"
    dependsOn: waitForValidation
    environment: DEV
    strategy:
      runOnce:
        deploy:
          steps:
            - template: templates/terraform-apply.yml
              parameters:
                environment: "DEV"
                state_key: "$(DEV_TF_STATE_KEY)"

# Repeat the same pattern for QA, UAT, and PROD
```

---

## **Final Benefits of Using Templates**
✅ **Shorter `azure-pipelines.yml`** (Easier to read and manage).  
✅ **Code Reusability** (No duplication; update one template, and it affects all environments).  
✅ **Scalability** (Easier to add more environments in the future).  
✅ **Easier Debugging** (Each component is modular and isolated).

---

## **Next Steps**
1️⃣ **Create a `templates/` folder and save each template file.**  
2️⃣ **Modify `azure-pipelines.yml` to reference the templates.**  
3️⃣ **Commit and push the changes to test the pipeline.**  
4️⃣ **Enjoy a cleaner, maintainable, and scalable pipeline!**   
