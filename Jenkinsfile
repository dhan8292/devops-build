pipeline {
    agent any

    environment {
        DEV_REPO = "dockerhubusername/dev"
        PROD_REPO = "dockerhubusername/prod"
    }

    stages {

        stage('Checkout') {
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
            when { branch 'dev' }

            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'dockerhub-cred',
                    usernameVariable: 'USERNAME',
                    passwordVariable: 'PASSWORD'
                )]) {

                    sh '''
                    docker login -u $USERNAME -p $PASSWORD
                    docker tag trend-app $DEV_REPO:latest
                    docker push $DEV_REPO:latest
                    '''
                }
            }
        }

        stage('Push to Prod Repository') {
            when { branch 'master' }

            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'dockerhub-cred',
                    usernameVariable: 'USERNAME',
                    passwordVariable: 'PASSWORD'
                )]) {

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
