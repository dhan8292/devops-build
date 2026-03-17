pipeline {
    agent any

    environment {
        IMAGE_NAME = "react-devops-app"
        DEV_REPO = "dockerhubusername/dev"
        PROD_REPO = "dockerhubusername/prod"
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

                    echo "Detected branch: ${env.ACTUAL_BRANCH}"
                }
            }
        }

        stage('Deployment Info') {
            steps {
                script {
                    if (env.ACTUAL_BRANCH == "dev") {
                        echo "===================================="
                        echo "🚀 IMAGE WILL BE PUSHED TO DEV REPO"
                        echo "Repo: ${DEV_REPO}"
                        echo "===================================="
                    } else if (env.ACTUAL_BRANCH == "master") {
                        echo "===================================="
                        echo "🚀 IMAGE WILL BE PUSHED TO PROD REPO"
                        echo "Repo: ${PROD_REPO}"
                        echo "===================================="
                    } else {
                        echo "===================================="
                        echo "⚠️ NO DEPLOYMENT FOR THIS BRANCH"
                        echo "Branch: ${env.ACTUAL_BRANCH}"
                        echo "===================================="
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

                        echo "✅ Image successfully pushed to ${repo}:${env.BUILD_NUMBER}"
                    }
                }
            }
        }
    }
}
