pipeline {
    agent any

    environment {
        IMAGE_NAME = "react-devops-app"
        DEV_REPO   = "dhanu92/react-devops-dev"
        PROD_REPO  = "dhanu92/react-devops-prod"
    }

    stages {

        // ✅ Checkout code
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        // ✅ Detect branch reliably (works for Multibranch Pipeline)
        stage('Detect Branch') {
            steps {
                script {
                    // Multibranch Pipeline automatically sets BRANCH_NAME
                    env.ACTUAL_BRANCH = env.BRANCH_NAME ?: sh(
                        script: 'git rev-parse --abbrev-ref HEAD',
                        returnStdout: true
                    ).trim()
                    echo "Detected branch: ${env.ACTUAL_BRANCH}"
                }
            }
        }

        // ✅ Show deployment info
        stage('Deployment Info') {
            steps {
                script {
                    if (env.ACTUAL_BRANCH == "dev") {
                        echo "===================================="
                        echo "🚀 PUSHING TO DEV REPOSITORY"
                        echo "Repo: ${DEV_REPO}"
                        echo "===================================="
                    } else if (env.ACTUAL_BRANCH == "master") {
                        echo "===================================="
                        echo "🚀 PUSHING TO PROD REPOSITORY"
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

        // ✅ Build Docker image
        stage('Build Docker Image') {
            steps {
                sh "docker build -t $IMAGE_NAME ."
            }
        }

        // ✅ Push to DockerHub (only for dev or master)
        stage('Push to DockerHub') {
            when {
                expression {
                    return env.ACTUAL_BRANCH == "dev" || env.ACTUAL_BRANCH == "master"
                }
            }
            steps {
                script {
                    def repo = env.ACTUAL_BRANCH == "dev" ? DEV_REPO : PROD_REPO

                    withCredentials([usernamePassword(
                        credentialsId: 'dockerhub-creds',
                        usernameVariable: 'USERNAME',
                        passwordVariable: 'PASSWORD'
                    )]) {
                        sh """
                            echo \$PASSWORD | docker login -u \$USERNAME --password-stdin
                            docker tag $IMAGE_NAME ${repo}:\$BUILD_NUMBER
                            docker tag $IMAGE_NAME ${repo}:latest
                            docker push ${repo}:\$BUILD_NUMBER
                            docker push ${repo}:latest
                        """
                    }
                    echo "✅ SUCCESS: Image pushed to ${repo}:${env.BUILD_NUMBER} and ${repo}:latest"
                }
            }
        }
    }
}
