pipeline{
    agent any

    options {
        ansiColor('xterm')
    }

    tools {
        "org.jenkinsci.plugins.terraform.TerraformInstallation" "terraform"
    }

    parameters {
        string(name: 'greeting', defaultValue: 'Hello', description: 'How should I greet the world?')
        string(name: 'resource_group', defaultValue: 'jenkins', description: 'Azure Resource Group Name')
    }

    environment {
        TF_IN_AUTOMATION = "true"
        ARM_BACKEND_RESOURCEGROUP = "${params.resource_group}"
        ARM_BACKEND_STORAGEACCOUNT = credentials("ARM_BACKEND_STORAGEACCOUNT")
    }

    stages {

        stage('Info') {
            steps {
                echo "${params.greeting}, running ${env.JOB_NAME} (${env.BUILD_ID}) on ${env.JENKINS_URL}."
            }
        }

        stage('Authenticate'){
            steps {
                sh '''
                az login --identity --output jsonc
                echo "ARM_BACKEND_RESOURCEGROUP: $ARM_BACKEND_RESOURCEGROUP"
                echo "ARM_BACKEND_STORAGEACCOUNT: $ARM_BACKEND_STORAGEACCOUNT"
                '''
            }
        }

        stage('Terraform Init'){
            steps {
                sh '''
                az login --identity --output yaml
                terraform init \
                  --backend-config="resource_group_name=$ARM_BACKEND_RESOURCEGROUP" \
                  --backend-config="storage_account_name=$ARM_BACKEND_STORAGEACCOUNT"
                '''
            }
        }

        stage('Terraform Validate'){
            steps {
                sh 'az login --identity --output table; terraform validate'
            }
        }

        stage('Terraform Format'){
            steps {
                sh 'az login --identity --output none && terraform fmt -check'
            }
        }

        stage('Terraform Plan'){
            steps {
                sh 'az login --identity --output none && terraform plan --input=false'
            }
        }

        stage('Terraform Apply'){
            steps {
                sh 'az login --identity --output none && terraform apply --auto-approve --input=false'
            }
        }
    }
}