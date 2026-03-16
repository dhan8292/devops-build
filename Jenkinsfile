pipeline {
    agent any

    stages {

        stage('Clone Repo') {
            steps {
                git branch: 'dev', url: 'https://github.com/dhan8292/devops-build.git'

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

                sh 'bash build.sh'
            }
        }

        stage('Tag Image') {
            steps {
                sh 'docker tag react-devops-app dhanu92/react-devops-dev:latest'
            }
        }

        stage('Push Image to DockerHub') {
            steps {
                sh 'docker push dhanu92/react-devops-dev:latest'
            }
        }

        stage('Deploy Container') {
            steps {
                sh 'bash deploy.sh'

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
