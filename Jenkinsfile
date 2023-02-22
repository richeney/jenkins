pipeline{
    agent any
    tools {
        "org.jenkinsci.plugins.terraform.TerraformInstallation" "terraform"
    }
    environment {
        // TF_HOME = tool('terraform')
        TF_IN_AUTOMATION = "true"
        // PATH = "$TF_HOME:$PATH"
        ARM_BACKEND_RESOURCEGROUP = "jenkins"
        ARM_BACKEND_STORAGEACCOUNT = credentials("ARM_BACKEND_STORAGEACCOUNT")
    }
    stages {
        stage('Test'){
            steps {
                ansiColor('xterm') {
                  sh """
                  az login --identity --output jsonc
                  echo "ARM_BACKEND_RESOURCEGROUP: ${env.ARM_BACKEND_RESOURCEGROUP}"
                  echo "ARM_BACKEND_STORAGEACCOUNT: ${env.ARM_BACKEND_STORAGEACCOUNT}"
                  """
                }
            }
        }
    }
}