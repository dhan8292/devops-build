pipeline {
    agent any

    environment {
        IMAGE_NAME = "trend-app"
        DEV_REPO = "dockerhubusername/dev"
        PROD_REPO = "dockerhubusername/prod"
    }

    stages {

        stage('Checkout Code') {
            steps {
                checkout scm
            }
        }

        stage('Build Docker Image') {
            steps {
                sh 'docker build -t $IMAGE_NAME .'
            }
        }

        stage('Push to DockerHub') {
            steps {
                script {

                    def repo = ""

                    if (env.BRANCH_NAME == "dev") {

                        repo = DEV_REPO

                        echo "===== DEV BRANCH DETECTED ====="
                        echo "Pushing Docker image to DEV repository: ${repo}"

                    } else if (env.BRANCH_NAME == "master") {

                        repo = PROD_REPO

                        echo "===== MASTER BRANCH DETECTED ====="
                        echo "Pushing Docker image to PROD repository: ${repo}"

                    } else {

                        echo "===== NO DEPLOYMENT ====="
                        echo "Branch: ${env.BRANCH_NAME} is not configured for Docker push"
                    }

                    if (repo != "") {

                        withCredentials([usernamePassword(
                            credentialsId: 'dockerhub-cred',
                            usernameVariable: 'USERNAME',
                            passwordVariable: 'PASSWORD'
                        )]) {

                            sh """
                            echo \$PASSWORD | docker login -u \$USERNAME --password-stdin
                            docker tag $IMAGE_NAME ${repo}:\$BUILD_NUMBER
                            docker push ${repo}:\$BUILD_NUMBER
                            """
                        }

                        echo "===== SUCCESS ====="
                        echo "Image pushed to ${repo}:${env.BUILD_NUMBER}"
                    }
                }
            }
        }
    }
}
