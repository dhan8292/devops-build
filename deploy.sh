  #!/bin/bash

  echo "Stopping old container ..."

  docker stop react-container || true

  docker rm react-container  || true
  
  echo "Running new container ..."

  docker run -d -p 80:80 --name react-container react-devops-app

  echo "Deployment completed"

