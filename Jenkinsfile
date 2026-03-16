pipeline {
    agent any

    environment {
        DOCKER_USER = "your_dockerhub_username"
        DEV_REPO = "your_dockerhub_username/dev"
        PROD_REPO = "your_dockerhub_username/prod"
    }

    stages {

        stage('Checkout Code') {
            steps {
                checkout scm
            }
        }

        stage('Build Docker Image') {
            steps {
                sh 'docker build -t trend-app .'
            }
        }

        stage('Push to Dev Repository') {
            when {
                branch 'dev'
            }

            steps {
                withCredentials([usernamePassword(
                credentialsId: 'dockerhub-cred',
                usernameVariable: 'USERNAME',
                passwordVariable: 'PASSWORD')]) {

                sh '''
                docker login -u $USERNAME -p $PASSWORD
                docker tag trend-app $DEV_REPO:latest
                docker push $DEV_REPO:latest
                '''
                }
            }
        }

        stage('Push to Prod Repository') {
            when {
                branch 'master'
            }

            steps {
                withCredentials([usernamePassword(
                credentialsId: 'dockerhub-cred',
                usernameVariable: 'USERNAME',
                passwordVariable: 'PASSWORD')]) {

                sh '''
                docker login -u $USERNAME -p $PASSWORD
                docker tag trend-app $PROD_REPO:latest
                docker push $PROD_REPO:latest
                '''
                }
            }
        }

    }
}
