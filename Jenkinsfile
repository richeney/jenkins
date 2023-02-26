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
            }
        }

        stage('Terraform Init') {
            steps {
                sh '''
                az login --service-principal -u $ARM_CLIENT_ID -p $ARM_CLIENT_SECRET -t $ARM_TENANT_ID --output jsonc
                az account set --subscription $ARM_SUBSCRIPTION_ID

                echo "Initialising Terraform"
                terraform init \
                    --backend-config="resource_group_name=$ARM_BACKEND_RESOURCEGROUP" \
                    --backend-config="storage_account_name=$ARM_BACKEND_STORAGEACCOUNT"

                az logout
                '''
            }
        }

        stage('Terraform Validate') {
            steps {
                sh '''
                az login --service-principal -u $ARM_CLIENT_ID -p $ARM_CLIENT_SECRET -t $ARM_TENANT_ID --output none
                az account set --subscription $ARM_SUBSCRIPTION_ID --output none

                echo "Validating Terraform"
                terraform fmt -check
                terraform validate

                az logout
                '''
            }
        }

        stage('Terraform {Plan}') {
            steps {
                sh '''
                az login --service-principal -u $ARM_CLIENT_ID -p $ARM_CLIENT_SECRET -t $ARM_TENANT_ID --output none
                az account set --subscription $ARM_SUBSCRIPTION_ID --output none

                echo "Validating Terraform"
                terraform plan --input=false

                az logout
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
                az login --service-principal -u $ARM_CLIENT_ID -p $ARM_CLIENT_SECRET -t $ARM_TENANT_ID --output none
                az account set --subscription $ARM_SUBSCRIPTION_ID --output none

                echo "Validating Terraform"
                terraform apply --input=false --auto-approve

                az logout
                '''
            }
        }
    }
}
