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

        // ✅ BRANCH DETECTION 
        stage('Detect Branch') {
            steps {
                script {
                    echo "Raw GIT_BRANCH: ${env.GIT_BRANCH}"

                    if (env.GIT_BRANCH) {
                        env.ACTUAL_BRANCH = env.GIT_BRANCH.replace("origin/", "")
                    } else {
                        env.ACTUAL_BRANCH = "unknown"
                    }

                    echo "Detected branch: ${env.ACTUAL_BRANCH}"
                }
            }
        }

        // ✅ SHOW WHERE IMAGE WILL GO
        stage('Deployment Info') {
            steps {
                script {
                    if (env.ACTUAL_BRANCH == "dev") {
                        echo "===================================="
                        echo "🚀 PUSHING TO DEV REPOSITORY"
                        echo "Repo: ${DEV_REPO}"
                        echo "===================================="
                    } 
                    else if (env.ACTUAL_BRANCH == "master") {
                        echo "===================================="
                        echo "🚀 PUSHING TO PROD REPOSITORY"
                        echo "Repo: ${PROD_REPO}"
                        echo "===================================="
                    } 
                    else {
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
                    } 
                    else if (env.ACTUAL_BRANCH == "master") {
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

                        echo "✅ SUCCESS: Image pushed to ${repo}:${env.BUILD_NUMBER}"
                    }
                }
            }
        }
    }
}
