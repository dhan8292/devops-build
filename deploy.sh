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

