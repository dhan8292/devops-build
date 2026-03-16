pipeline {
    agent any

    stages {

        stage('Clone Repo') {
            steps {
                git branch: 'dev', url: 'https://github.com/dhan8292/devops-build.git'
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
            }
        }

    }
}
