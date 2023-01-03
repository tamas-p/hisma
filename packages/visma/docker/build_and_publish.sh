#!/usr/bin/env bash
source ../../../scripts/utilities.sh

message "This script will publish into the tamasp/visma Docker repository the\n\
latest tag."

TMP_DIR=tmp

PLANTUML_JAR_URL=https://sourceforge.net/projects/plantuml/files/1.2022.1/plantuml-jar-mit-1.2022.1.zip

GITHUB_TAG=$(git tag | grep visma | tail -1)
GITHUB_DOWNLOAD_TAG=$(echo $GITHUB_TAG | sed 's/+/-/')
DOCKER_TAG=$(echo $GITHUB_TAG | sed 's/visma-v//' | sed 's/+/_/' )

IMAGE=tamasp/visma
IMAGE_WITH_TAG=$IMAGE:$DOCKER_TAG

cecho "Last visma tag on GitHub is $GITHUB_TAG"
cecho "The Docker tag created from $GITHUB_TAG is $DOCKER_TAG (to be compliant with docker naming rules)."
cecho "Trying to pull image $IMAGE_WITH_TAG ..."
separator
docker pull $IMAGE_WITH_TAG
if [ $? -eq 0 ]; then
    message "Tag $DOCKER_TAG already exists in the repository: ${IMAGE_WITH_TAG}. Exiting."
    exit 1
fi
cecho "Good, $IMAGE_WITH_TAG is not in $IMAGE repository. We can progress."

HISMA_URL=https://github.com/tamas-p/hisma/archive/refs/tags/${GITHUB_TAG}.tar.gz

cecho
cecho "GITHUB_TAG=$GITHUB_TAG"
cecho "GITHUB_DOWNLOAD_TAG=$GITHUB_DOWNLOAD_TAG"
cecho "DOCKER_TAG=$DOCKER_TAG"
cecho "IMAGE=$IMAGE"
cecho "IMAGE_WITH_TAG=$IMAGE_WITH_TAG"
cecho "HISMA_URL=$HISMA_URL"
cecho "PLANTUML_JAR_URL=$PLANTUML_JAR_URL"
cecho
cecho "Next steps are getting dependencies and building the docker image."
proceed "Note: ./${TMP_DIR} directory will be cleaned."

echo rm -fr ${TMP_DIR}
rm -fr ${TMP_DIR}
echo mkdir ${TMP_DIR}
mkdir ${TMP_DIR}

message "Getting Hisma by tag ${GITHUB_TAG}"
HISMA_TARGZ=visma.tar.gz
wget $HISMA_URL -O ${TMP_DIR}/$HISMA_TARGZ
tar xvfz ${TMP_DIR}/$HISMA_TARGZ -C ${TMP_DIR}/ > /dev/null
mv ${TMP_DIR}/hisma-${GITHUB_DOWNLOAD_TAG} ${TMP_DIR}/hisma

VISMA_DIR=${TMP_DIR}/hisma/packages/visma
echo $VISMA_DIR

message "Building visma executable:"
dart compile exe ${VISMA_DIR}/bin/visma.dart -o ${TMP_DIR}/visma

message "Fetching PlantUML:"
wget $PLANTUML_JAR_URL -O ${TMP_DIR}/plantuml.zip
unzip -o ${TMP_DIR}/plantuml.zip -d ${TMP_DIR}/

message "Building docker image ${IMAGE_WITH_TAG}:"
docker build -t $IMAGE:latest -t $IMAGE_WITH_TAG .
echeck "Docker build of $IMAGE_WITH_TAG failed. Exiting."

separator
cecho "Docker image $IMAGE_WITH_TAG is successfully built."
cecho "Next step is pushing $IMAGE_WITH_TAG to Docker Hub."
proceed

docker push $IMAGE_WITH_TAG
docker push $IMAGE:latest

message "Docker build & push of $IMAGE_WITH_TAG is completed."
