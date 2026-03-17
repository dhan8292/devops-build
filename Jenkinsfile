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

        // ✅ Detect branch reliably (fallback for detached HEAD)
        stage('Detect Branch') {
            steps {
                script {
                    if (env.GIT_BRANCH) {
                        // Use GIT_BRANCH if set
                        env.ACTUAL_BRANCH = env.GIT_BRANCH.replace("origin/", "")
                    } else {
                        // Fallback to git command
                        env.ACTUAL_BRANCH = sh(
                            script: 'git rev-parse --abbrev-ref HEAD',
                            returnStdout: true
                        ).trim()
                    }
                    echo "Detected branch: ${env.ACTUAL_BRANCH}"
                }
            }
        }

        // ✅ Deployment info
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
}
