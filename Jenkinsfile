pipeline {
    agent any

    environment {
        IMAGE_NAME = "react-devops-app"
        DEV_REPO   = "dhanu92/react-devops-dev"
        PROD_REPO  = "dhanu92/react-devops-prod"
    }

    stages {

        // ✅ Checkout
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        // ✅ Detect Branch (Multibranch compatible)
        stage('Detect Branch') {
            steps {
                script {
                    env.ACTUAL_BRANCH = env.BRANCH_NAME ?: "unknown"
                    echo "Detected branch: ${env.ACTUAL_BRANCH}"
                }
            }
        }

        // ✅ Show where image will be pushed
        stage('Deployment Info') {
            steps {
                script {
                    if (env.ACTUAL_BRANCH == "dev") {
                        echo "===================================="
                        echo "🟢 DEV BRANCH DETECTED"
                        echo "Pushing to: ${DEV_REPO}"
                        echo "===================================="
                    } 
                    else if (env.ACTUAL_BRANCH == "master") {
                        echo "===================================="
                        echo "🔴 MASTER BRANCH DETECTED"
                        echo "Pushing to: ${PROD_REPO}"
                        echo "===================================="
                    } 
                    else {
                        echo "===================================="
                        echo "⚠️ NO DEPLOYMENT"
                        echo "Branch: ${env.ACTUAL_BRANCH}"
                        echo "===================================="
                    }
                }
            }
        }

        // ✅ Build Docker Image
        stage('Build Docker Image') {
            steps {
                sh "docker build -t ${IMAGE_NAME} ."
            }
        }

        // ✅ Push to DockerHub
        stage('Push to DockerHub') {
            when {
                expression {
                    return env.ACTUAL_BRANCH == "dev" || env.ACTUAL_BRANCH == "master"
                }
            }
            steps {
                script {

                    def repo = (env.ACTUAL_BRANCH == "dev") ? DEV_REPO : PROD_REPO

                    withCredentials([usernamePassword(
                        credentialsId: 'dockerhub-creds',
                        usernameVariable: 'USERNAME',
                        passwordVariable: 'PASSWORD'
                    )]) {

                        sh """
                            docker logout || true
                            echo \$PASSWORD | docker login -u \$USERNAME --password-stdin

                            echo "===== TAGGING IMAGE ====="
                            docker tag ${IMAGE_NAME} ${repo}:\$BUILD_NUMBER
                            docker tag ${IMAGE_NAME} ${repo}:latest

                            echo "===== PUSH BUILD TAG ====="
                            docker push ${repo}:\$BUILD_NUMBER

                            echo "===== PUSH LATEST TAG ====="
                            docker push ${repo}:latest
                        """
                    }

                    echo "===== SUCCESS ====="
                    echo "Image pushed to ${repo}:${env.BUILD_NUMBER}"
                    echo "Image pushed to ${repo}:latest"
                }
            }
        }
    }

    post {
        success {
            echo "🎉 Pipeline completed successfully!"
        }
        failure {
            echo "❌ Pipeline failed. Check logs above."
        }
    }
}
