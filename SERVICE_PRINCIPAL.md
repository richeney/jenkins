# Service Principal

You could set up a service principal rather than using a managed identity. The managed identity has a number of benefits, but for those wishing to use a service principal then below are some of the key commands to create it, assign the roles and then create the credential. I have also included an example Jenkinsfile.

Assumes you have followed the main README.md up to the point where you have configured Terraform as a tool in Jenkins.

## Plugins

* Install the Azure Credentials plugin and restart

## Credential

1. Create a service principal

    ```bash
    az ad sp create-for-rbac --name http://jenkins_terraform_sp --output jsonc
    ```

1. Get the service principal's object ID

    ```bash
    objectId=$(az ad sp list --filter "displayname eq 'http://jenkins_terraform_sp'" --query [0].id -otsv)
    ```

1. Create Owner RBAC role assignment on the subscription

    ```bash
    subscriptionId=/subscriptions/$(az account show --query id -otsv)
    az role assignment create --assignee $objectId --role "Contributor" --scope $subscriptionId
    ```

1. Display the subscription ID

    ```bash
    az account show --query id --output tsv
    ```

1. Recreate the service principal

    This will patch it, resetting the password.

    ```bash
    az ad sp create-for-rbac --name http://jenkins_terraform_sp --output jsonc
    ```

1. Manage Jenkins | Manage Credentials
1. Click on *System*
1. Click on *Global credentials*
1. *+ Add Credentials*
    * Kind = **Azure Service Principal**
    * **Subscription ID**
    * **Client ID** (appId)
    * **Client Secret** (password)
    * **Tenant ID**
    * Id = **jenkins_terraform_sp**
    * Description = **ht<span>tp://</span>jenkins_terraform_sp**
1. *Verify Service Principal*

    ![Adding a Service Principal in Jenkins](images/service_principal.png)

    If there are any issues then try to authenticate using `az login --service-principal`.

1. *Create*

## Remote state

1. Create a storage account and container for the Terraform remote state

    ```bash
    rgId=$(az group show --name $(az config get defaults.group --query value -otsv) --query id -otsv)
    sa=terraform$(md5sum <<< $rgId | cut -c1-12)
    az storage account create --name $sa --sku Standard_LRS --allow-blob-public-access false
    az storage container create --name "tfstate" --account-name $sa --auth-mode login
    ```

    Uses md5sum to generate a predictable hash from the resource group's resource ID.

1. Add Storage Blob Data Contributor RBAC role assignment

    ```bash
    saId=$(az storage account show --name $sa --query id -otsv)
    az role assignment create --assignee $objectId --role "Storage Blob Data Contributor" --scope $saId
    ```

1. Display resource group name and storage account name

    ```bash
    az storage account show --name $sa --query "{resource_group:resourceGroup, storage_account:name}" --output yaml
    ```

1. Manage Jenkins | Manage Credentials
1. *System*, *Global credentials*, *+ Add Credentials*
1. Kind = **Secret text**

    Create two credentials, for **resource_group** and **storage_account**.

    ![Adding additional secrets in Jenkins](images/secret.png)

    These will be used later by `terraform init` for the backend.

## Continue

Then you can carry on with the pipeline creation and SCM webhook.

## Example Jenkinsfile

```groovy
pipeline {
    agent any

    tools {
        'org.jenkinsci.plugins.terraform.TerraformInstallation' 'terraform'
    }

    environment {
        TF_IN_AUTOMATION = 'true'
        ARM = credentials('jenkins_terraform_sp')
        // Exports env vars: ARM_CLIENT_ID, ARM_CLIENT_SECRET, ARM_SUBSCRIPTION_ID, ARM_TENANT_ID
        // which is the same as those used by Terraform
        ARM_BACKEND_RESOURCEGROUP = credentials('resource_group')
        ARM_BACKEND_STORAGEACCOUNT = credentials('storage_account')
    }

    options {
        ansiColor('xterm')
    }

    stages {
        stage('Info') {
            steps {
                echo "Running ${env.JOB_NAME} (${env.BUILD_ID}) on ${env.JENKINS_URL}."

                sh '''
                az login --service-principal -u $ARM_CLIENT_ID -p $ARM_CLIENT_SECRET -t $ARM_TENANT_ID --output jsonc
                az account set --subscription $ARM_SUBSCRIPTION_ID
                storageId=$(az storage account show --name $ARM_BACKEND_STORAGEACCOUNT \
                  --resource-group $ARM_BACKEND_RESOURCEGROUP --query id --output tsv)
                az role assignment list --include-inherited \
                  --scope $storageId --query "[?contains(roleDefinitionName, 'Storage')]" --output jsonc
                az logout
                '''
            }
        }

        stage('Terraform Init') {
            steps {
                sh '''
                echo "Initialising Terraform"
                terraform init \
                    --backend-config="resource_group_name=$ARM_BACKEND_RESOURCEGROUP" \
                    --backend-config="storage_account_name=$ARM_BACKEND_STORAGEACCOUNT"
                '''
            }
        }

        stage('Terraform Validate') {
            steps {
                sh '''
                echo "Validating Terraform"
                terraform fmt -check
                terraform validate
                '''
            }
        }

        stage('Terraform Plan') {
            steps {
                sh '''
                echo "Validating Terraform"
                terraform plan --input=false
                '''
            }
        }

        stage('Waiting for approval...') {
            steps {
                timeout(time: 10, unit: 'MINUTES') {
                        input(message: 'Deploy the infrastructure?')
                }
            }
        }

        stage('Terraform Apply') {
            steps {
                sh '''
                echo "Validating Terraform"
                terraform apply --input=false --auto-approve
                '''
            }
        }
    }
}
```
