#!/bin/bash -eu

USER="${DOCKERHUB_USERNAME}"
PASSWORD="${DOCKERHUB_PASSWORD}"
NAMESPACE="${DOCKERHUB_NAMESPACE}"
REPOSITORY="${DOCKERHUB_REPOSITORY}"

GIT_COMMIT=`git log --format="%h" -n 1`
GIT_REF=`git symbolic-ref -q --short HEAD || git describe --tags --exact-match`

echo "Building Docker image from $GIT_REF with commit hash $GIT_COMMIT"

GIT_COMMIT_TAG="${NAMESPACE}/${REPOSITORY}:${GIT_COMMIT}"
docker build -t ${GIT_COMMIT_TAG} .

echo "Docker image created"
echo "Image tagged as ${GIT_COMMIT_TAG}"

echo "Checking github.  Current ref: $GIT_REF"
if [ "$GIT_REF" == "master" ]; then
  echo "This is a build of the master branch.  Setting version tag to latest"
  GIT_REF="latest"
fi
GIT_REF_TAG="${NAMESPACE}/${REPOSITORY}:${GIT_REF}"
docker tag ${GIT_COMMIT_TAG} ${GIT_REF_TAG}

echo "Image tagged as ${GIT_REF_TAG}"

echo "Logging into Docker Hub"
docker login -u ${USER} -p ${PASSWORD}
#docker push ${GIT_COMMIT_TAG}
#docker push ${GIT_REF_TAG}
