pipeline{
    agent any
    tools {
        "org.jenkinsci.plugins.terraform.TerraformInstallation" "terraform"
    }
    environment {
        // TF_HOME = tool('terraform')
        TF_IN_AUTOMATION = "true"
        // PATH = "$TF_HOME:$PATH"
        ARM_TENANT_ID = credentials("ARM_TENANT_ID")
        ARM_IDENTITY = credentials("Jenkins")
        ARM_BACKEND_RESOURCEGROUP = "jenkins"
        ARM_BACKEND_STORAGEACCOUNT = credentials("ARM_BACKEND_STORAGEACCOUNT")
    }
    stages {
        stage('Test'){
            steps {
                sh 'az login --identity'
                sh 'az account set --subscription ARM_IDENTITY_SUBSCRIPTION_ID --output jsonc'
                echo "ARM_TENANT_ID: ${env.ARM_TENANT_ID}"
                echo "ARM_IDENTITY: ${env.ARM_IDENTITY}"
                echo "ARM_BACKEND_RESOURCEGROUP: ${env.ARM_BACKEND_RESOURCEGROUP}"
                echo "ARM_BACKEND_STORAGEACCOUNT: ${env.ARM_BACKEND_STORAGEACCOUNT}"
            }
    }
}