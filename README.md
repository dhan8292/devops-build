# Getting Started with Create React App

This project was bootstrapped with [Create React App](https://github.com/facebook/create-react-app).

## Available Scripts

In the project directory, you can run:

### `npm start`

Runs the app in the development mode.\
Open [http://localhost:3000](http://localhost:3000) to view it in your browser.

The page will reload when you make changes.\
You may also see any lint errors in the console.

### `npm test`

Launches the test runner in the interactive watch mode.\
See the section about [running tests](https://facebook.github.io/create-react-app/docs/running-tests) for more information.

### `npm run build`

Builds the app for production to the `build` folder.\
It correctly bundles React in production mode and optimizes the build for the best performance.

The build is minified and the filenames include the hashes.\
Your app is ready to be deployed!

See the section about [deployment](https://facebook.github.io/create-react-app/docs/deployment) for more information.

### `npm run eject`

**Note: this is a one-way operation. Once you `eject`, you can't go back!**

If you aren't satisfied with the build tool and configuration choices, you can `eject` at any time. This command will remove the single build dependency from your project.

Instead, it will copy all the configuration files and the transitive dependencies (webpack, Babel, ESLint, etc) right into your project so you have full control over them. All of the commands except `eject` will still work, but they will point to the copied scripts so you can tweak them. At this point you're on your own.

You don't have to ever use `eject`. The curated feature set is suitable for small and middle deployments, and you shouldn't feel obligated to use this feature. However we understand that this tool wouldn't be useful if you couldn't customize it when you are ready for it.

## Learn More

You can learn more in the [Create React App documentation](https://facebook.github.io/create-react-app/docs/getting-started).

To learn React, check out the [React documentation](https://reactjs.org/).

### Code Splitting

This section has moved here: [https://facebook.github.io/create-react-app/docs/code-splitting](https://facebook.github.io/create-react-app/docs/code-splitting)

### Analyzing the Bundle Size

This section has moved here: [https://facebook.github.io/create-react-app/docs/analyzing-the-bundle-size](https://facebook.github.io/create-react-app/docs/analyzing-the-bundle-size)

### Making a Progressive Web App

This section has moved here: [https://facebook.github.io/create-react-app/docs/making-a-progressive-web-app](https://facebook.github.io/create-react-app/docs/making-a-progressive-web-app)

### Advanced Configuration

This section has moved here: [https://facebook.github.io/create-react-app/docs/advanced-configuration](https://facebook.github.io/create-react-app/docs/advanced-configuration)

### Deployment

This section has moved here: [https://facebook.github.io/create-react-app/docs/deployment](https://facebook.github.io/create-react-app/docs/deployment)

### `npm run build` fails to minify


React Application Deployment using Docker, Jenkins & AWS EC2
Project Overview:
This document describes a complete DevOps CI/CD pipeline for deploying a React application using Docker,
Jenkins, and AWS EC2.
Tools Used:
- Git
- Docker
- Docker Compose
- Jenkins
- AWS EC2
- Uptime Kuma
System Requirements:
Ubuntu 22.04 / Amazon Linux 2
Open Ports: 22, 80, 8080, 3001
Dockerfile:
# Use lightweight nginx image
FROM nginx:alpine
# Remove default nginx files
RUN rm -rf /usr/share/nginx/html/*
# Copy build files into nginx folder
COPY build/ /usr/share/nginx/html/
# Expose nginx port
EXPOSE 80
# Start nginx
CMD ["nginx", "-g", "daemon off;"]

docker-compose.yml
services:
react-app:
build: .
container_name: react-devops
ports:
- "80:80"
- 
build.sh:
 #!/bin/bash
 echo "Building Docker Image ..."
 docker build -t react-devops-app .
 echo "Build Completed"

deploy.sh:
#!/bin/bash
set -e
# ===== CONFIG =====
IMAGE_NAME="react-devops-app"
DEV_REPO="dhanu92/react-devops-dev"
PROD_REPO="dhanu92/react-devops-prod"
# ===== DETECT BRANCH =====
BRANCH=$(git rev-parse --abbrev-ref HEAD)
echo "Detected branch: $BRANCH"
# ===== SIMULATE BUILD NUMBER =====
# Jenkins sets BUILD_NUMBER automatically; here we simulate with timestamp
export BUILD_NUMBER=$(date +%s)
# ===== BUILD IMAGE =====
echo "Building Docker image..."
docker build -t $IMAGE_NAME .
# ===== LOGIN TO DOCKERHUB =====
echo "Logging in to DockerHub..."
docker login -u "$DOCKERHUB_USERNAME" -p "$DOCKERHUB_PASSWORD"
# ===== TAG & PUSH =====
if [ "$BRANCH" = "dev" ]; then
    echo "🟢 Pushing to DEV repo: $DEV_REPO"
    docker tag $IMAGE_NAME $DEV_REPO:$BUILD_NUMBER
    docker push $DEV_REPO:$BUILD_NUMBER

elif [ "$BRANCH" = "master" ]; then
    echo "🔴 Pushing to PROD repo (private): $PROD_REPO"
    docker tag $IMAGE_NAME $PROD_REPO:$BUILD_NUMBER
    docker push $PROD_REPO:$BUILD_NUMBER

else
    echo "⚠️ No deployment configured for branch: $BRANCH"
    exit 0
fi
# ===== DEPLOY CONTAINER =====
echo "Stopping old container ..."
docker stop react-container || true
docker rm react-container || true
echo "Running new container ..."
docker run -d -p 80:80 --name react-container $IMAGE_NAME
echo "✅ Deployment completed"

Jenkinsfile:
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

Jenkins:
Access at http://EC2_PUBLIC_IP:8080
Create Freestyle job and add execute shell:
docker compose down
docker compose up -d --build
Monitoring:
docker run -d -p 3001:3001 --name uptime-kuma louislam/uptime-kuma
Access:
http://EC2_PUBLIC_IP :http://13.233.51.80/
http://EC2_PUBLIC_IP:8080
http://EC2_PUBLIC_IP:3001
This section has moved here: [https://facebook.github.io/create-react-app/docs/troubleshooting#npm-run-build-fails-to-minify](https://facebook.github.io/create-react-app/docs/troubleshooting#npm-run-build-fails-to-minify)
