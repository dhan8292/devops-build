pipeline {
    agent any

    environment {
        IMAGE_NAME = "react-devops-app"
        DEV_REPO   = "dhanu92/react-devops-dev"
        PROD_REPO  = "dhanu92/react-devops-prod"
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
                    env.ACTUAL_BRANCH = env.BRANCH_NAME ?: "unknown"
                    echo "Detected branch: ${env.ACTUAL_BRANCH}"
                }
            }
        }

        stage('Deployment Info') {
            steps {
                script {

                    if (env.ACTUAL_BRANCH == "dev") {
                        echo "===================================="
                        echo "🟢 DEV BRANCH DETECTED"
                        echo "Repo: ${DEV_REPO}"
                        echo "===================================="
                    } 
                    else if (env.ACTUAL_BRANCH == "master") {
                        echo "===================================="
                        echo "🔴 MASTER BRANCH DETECTED"
                        echo "Repo: ${PROD_REPO}"
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

        stage('Build Docker Image') {
            steps {
                sh "docker build -t ${IMAGE_NAME} ."
            }
        }

        stage('Push to DockerHub') {
            when {
                expression {
                    return env.ACTUAL_BRANCH == "dev" || env.ACTUAL_BRANCH == "master"
                }
            }
            steps {
                script {

                    def repo = ""

                    if (env.ACTUAL_BRANCH == "dev") {
                        repo = DEV_REPO
                    } 
                    else if (env.ACTUAL_BRANCH == "master") {
                        repo = PROD_REPO
                    }

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

                            echo "===== PUSHING IMAGE ====="
                            docker push ${repo}:\$BUILD_NUMBER
                        """
                    }

                    echo "✅ SUCCESS: Image pushed to ${repo}:${env.BUILD_NUMBER}"
                }
            }
        }
    }

    post {
        success {
            echo "🎉 Pipeline SUCCESS"
        }
        failure {
            echo "❌ Pipeline FAILED"
        }
    }
}
