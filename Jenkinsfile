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

        stage('deploy') {
            steps {
                sh '''
                az login --service-principal \
                  --username $ARM_CLIENT_ID --password $ARM_CLIENT_SECRET --tenant $ARM_TENANT_ID
                az account set --subcription $ARM_SUBSCRIPTION_ID
                '''

                sh 'az config set defaults.group=jenkins default.location=uksouth'
                sh 'az group create --name whatever'
                sh 'az logout'
            }
        }
/*

        stage('Example Azure CLI stage with Azure CLI plugin') {
            steps {
                azureCLI principalCredentialId: 'jenkins',
                commands: [
                    [
                        script: 'az account show --output jsonc',
                        exportVariablesString: '/name|ARM_SUBSCRIPTION_NAME'
                    ],
                    [
                        script: 'echo "ARM_SUBSCRIPTION_NAME: $ARM_SUBSCRIPTION_NAME"',
                    ]
                    ]
            }
        }

        stage('Example Azure CLI stage using withCredentials') {
            steps {
                withCredentials([azureServicePrincipal('jenkins')]) {
                    // Default env vars: ARM_CLIENT_ID, ARM_CLIENT_SECRET, ARM_SUBSCRIPTION_ID, ARM_TENANT_ID
                    sh 'az account show --output jsonc'
                    sh 'az storage account list --resource-group $ARM_BACKEND_STORAGEACCOUNT --output jsonc'
                }
            }
        }

        stage('Terraform Init') {
            steps {
                withCredentials([azureServicePrincipal(
                        credentialsId: 'jenkins',
                        subscriptionIdVariable: 'ARM_SUBSCRIPTION_ID',
                        clientIdVariable: 'ARM_CLIENT_ID',
                        tenantIdVariable: 'ARM_TENANT_ID'
                        )]) {
                    sh '''
                    echo "Initialising Terraform"
                    terraform init \
                      --backend-config="resource_group_name=$ARM_BACKEND_RESOURCEGROUP" \
                      --backend-config="storage_account_name=$ARM_BACKEND_STORAGEACCOUNT"
                    '''
                        }
            }
        }

        stage('Terraform Validate') {
            steps {
                withCredentials([azureServicePrincipal('jenkins')]) {
                    sh('echo "Validating Terraform"; terraform validate')
                }
            }
        }

        stage('Terraform Plan') {
            steps {
                sh('terraform plan --input=false')
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
                sh 'terraform apply --auto-approve --input=false'
            }
        }
*/
    }
}
