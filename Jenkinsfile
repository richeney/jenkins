pipeline{
    agent any

    options {
        ansiColor('xterm')
    }

    tools {
        "org.jenkinsci.plugins.terraform.TerraformInstallation" "terraform"
    }

    parameters {
        string(name: 'Greeting', defaultValue: 'Hello', description: 'How should I greet the world?')
    }

    environment {
        // TF_HOME = tool('terraform')
        TF_IN_AUTOMATION = "true"
        // PATH = "$TF_HOME:$PATH"
        ARM_BACKEND_RESOURCEGROUP = "jenkins"
        ARM_BACKEND_STORAGEACCOUNT = credentials("ARM_BACKEND_STORAGEACCOUNT")
    }

    stages {

        stage('Info') {
            steps {
                echo "${params.Greeting}, running ${env.JOB_NAME} (${env.BUILD_ID}) on ${env.JENKINS_URL}."
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

    }
}