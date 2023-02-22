pipeline{
    agent any
    tools {
        "org.jenkinsci.plugins.terraform.TerraformInstallation" "terraform"
    }
    environment {
        TF_HOME = tool('terraform')
        TF_IN_AUTOMATION = "true"
        PATH = "$TF_HOME:$PATH"

        ARM_BACKEND_RESOURCEGROUP = "jenkins"
        ARM_BACKEND_STORAGEACCOUNT = credentials("ARM_BACKEND_STORAGEACCOUNT")
        ARM_TENANT_ID = credentials("ARM_TENANT_ID")
    }
    stages {

        stage('Test'){

            steps {
                    ansiColor('xterm') {
                    withCredentials([azureManagedIdentity(
                    credentialsId: 'Jenkins',
                    subscriptionIdVariable: 'ARM_SUBSCRIPTION_ID',
                    clientIdVariable: 'ARM_CLIENT_ID'
                )]) {

                        sh """

                        echo "Initialising Terraform"
                        echo "ARM_SUBSCRIPTION_ID: $ARM_SUBSCRIPTION_ID"
                        """
                           }
                    }
             }
        }
    }
}