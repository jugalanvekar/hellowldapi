#!/bin/bash

#####
# Script to be used when changes are applied to the app
# once a change to the app has been pushed to git
# a trigger should start this script with image name,
# version and deployment config file as parameters
# this script will update the deployment config file
# with the new version and apply the changes to the
# kubernetes cluster.
# Kubernetes deployment will handle the rollout without 
# any downtime.
# Example of use:
# $ ./autodeploy.sh jugalanvekar/hellowldapi 07 autodply/deployment.yaml
# Sending build context to Docker daemon  41.45MB
# Step 1/6 : FROM python:2
#  ---> 43c5f3ee0928
# Step 2/6 : WORKDIR /usr/src/app
#  ---> Using cache
#  ---> 23ca0863ba75
# Step 3/6 : COPY requirements.txt ./
#  ---> Using cache
#  ---> e158c0c0f81c
# Step 4/6 : RUN pip install --no-cache-dir -r requirements.txt
#  ---> Using cache
#  ---> 44fb8d92849c
# Step 5/6 : COPY hellowldapi.py .
#  ---> Using cache
#  ---> 7bc4081b0643
# Step 6/6 : CMD [ "python", "./hellowldapi.py" ]
#  ---> Using cache
#  ---> 9f66d97ba0c9
# Successfully built 9f66d97ba0c9
# Successfully tagged jugalanvekar/hellowldapi:07
# The push refers to repository [docker.io/jugalanvekar/hellowldapi]
# 53c3dc24ac26: Layer already exists
# 0694cfdbe7aa: Layer already exists
# 7383ba8fc3cb: Layer already exists
# e84442d34e45: Layer already exists
# 21ba4974bb9d: Layer already exists
# a9e447d5b990: Layer already exists
# 6aa3ea570091: Layer already exists
# 6587292df0d5: Layer already exists
# 23044129c2ac: Layer already exists
# 8b229ec78121: Layer already exists
# 3b65755e1220: Layer already exists
# 2c833f307fd8: Layer already exists
# 07: digest: sha256:ea5f853ca7447a394cdacbf1b5a872c0ef9de616529350985faed4fc9e8b6ccd size: 2844
# deployment "hellowldapi" configured
# $
#####

if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ]
  then
    echo "USAGE: $0 ImageName Version DeploymentFile"
    echo "Example: $0 jugalanvekar/hellowldapi 04 autodply/deployment.yaml"
    exit 1
fi


IMAGE=$1
VERSION=$2
DEPLOYMENTFILE=$3

docker build -t $IMAGE:$VERSION .
docker push $IMAGE:$VERSION


sed -i "s@image: ${IMAGE}:..@image: ${IMAGE}:${VERSION}@g" $DEPLOYMENTFILE

kubectl apply -f $DEPLOYMENTFILE

