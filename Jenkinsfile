pipeline {
    agent any

    environment {
        IMAGE_NAME = "react-devops-app"
        DEV_REPO = "dhanu92/react-devops-dev"
        PROD_REPO = "dhanu92/react-devops-prod"
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Detect Branch') {
            steps {
                script {
                    env.ACTUAL_BRANCH = sh(
                        script: "git rev-parse --abbrev-ref HEAD",
                        returnStdout: true
                    ).trim()
                    echo "Raw GIT_BRANCH: ${env.ACTUAL_BRANCH}"
                }
            }
        }

        stage('Deployment Info') {
            steps {
                script {
                    if (env.ACTUAL_BRANCH == "dev") {
                        echo "===== DEV BRANCH DETECTED ====="
                        echo "Pushing Docker image to DEV repository: ${DEV_REPO}"
                    }
                    else if (env.ACTUAL_BRANCH == "master") {
                        echo "===== MASTER BRANCH DETECTED ====="
                        echo "Pushing Docker image to PROD repository: ${PROD_REPO}"
                    }
                    else {
                        echo "===== NO DEPLOYMENT ====="
                        echo "Branch: ${env.ACTUAL_BRANCH} is not configured for Docker push"
                    }
                }
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
                    if (env.ACTUAL_BRANCH == "dev") {
                        repo = DEV_REPO
                    } else if (env.ACTUAL_BRANCH == "master") {
                        repo = PROD_REPO
                    }

                    if (repo != "") {
                        withCredentials([usernamePassword(
                            credentialsId: 'dockerhub-creds',
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
