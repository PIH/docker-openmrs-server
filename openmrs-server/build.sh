#!/bin/bash -eu

USER="${DOCKERHUB_USERNAME}"
PASSWORD="${DOCKERHUB_PASSWORD}"
NAMESPACE="${DOCKERHUB_NAMESPACE}"
REPOSITORY="${DOCKERHUB_REPOSITORY}"

GIT_COMMIT=`git log --format="%h" -n 1`
GIT_BRANCH_OR_TAG=`git symbolic-ref -q --short HEAD || git describe --tags --exact-match`

echo "Building Docker image for branch/tag $GIT_BRANCH_OR_TAG with commit hash $GIT_COMMIT"

GIT_COMMIT_TAG="${NAMESPACE}/${REPOSITORY}:${GIT_COMMIT}"
docker build -t ${GIT_COMMIT_TAG} .

echo "Docker image created"
echo "Image tagged as ${GIT_COMMIT_TAG}"

echo "Checking github.  Current branch/tag: $GIT_BRANCH_OR_TAG"
if [ "$GIT_BRANCH_OR_TAG" == "master" ]; then
  echo "This is a build of the master branch.  Setting version tag to latest"
  GIT_BRANCH_OR_TAG="latest"
fi
docker tag ${GIT_COMMIT_TAG} ${GIT_BRANCH_OR_TAG}

echo "Image tagged as ${GIT_BRANCH_OR_TAG}"

echo "Logging into Docker Hub"
docker login -u ${USER} -p ${PASSWORD}
#docker push ${GIT_COMMIT_TAG}
#docker push ${GIT_BRANCH_OR_TAG}
