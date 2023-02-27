pipeline {
    agent any

    tools {
        'org.jenkinsci.plugins.terraform.TerraformInstallation' 'terraform'
    }

    environment {
        TF_IN_AUTOMATION           = 'true'
        ARM_USE_MSI                = true
        ARM_TENANT_ID              = credentials('tenant_id')
        ARM_SUBSCRIPTION_ID        = credentials('subscription_id')
        ARM_BACKEND_RESOURCEGROUP  = credentials('resource_group')
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
                az login --identity --output jsonc
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
                echo "Terraform Plan"
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
                echo "Terraform Apply"
                terraform apply --input=false --auto-approve
                '''
            }
        }
    }
}
