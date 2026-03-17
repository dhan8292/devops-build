pipeline {
    agent any

    environment {
        DEV_REPO = "dockerhubusername/dev"
        PROD_REPO = "dockerhubusername/prod"
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build Docker Image') {
            steps {
                sh 'docker build -t trend-app .'
            }
        }

        stage('Push Image') {
            steps {
                script {
                    def repo = ""

                    if (env.BRANCH_NAME == "dev") {
                        repo = DEV_REPO
                    } else if (env.BRANCH_NAME == "master") {
                        repo = PROD_REPO
                    }

                    if (repo != "") {
                        withCredentials([usernamePassword(
                            credentialsId: 'dockerhub-cred',
                            usernameVariable: 'USERNAME',
                            passwordVariable: 'PASSWORD'
                        )]) {

                            sh """
                            echo \$PASSWORD | docker login -u \$USERNAME --password-stdin
                            docker tag trend-app \$repo:\$BUILD_NUMBER
                            docker push \$repo:\$BUILD_NUMBER
                            """
                        }
                    } else {
                        echo "Branch not configured for deployment"
                    }
                }
            }
        }
    }
}
