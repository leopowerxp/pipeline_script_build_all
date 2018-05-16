#!/bin/bash
PARENT_WORKSPACE=$1/$2
PARENT_JOB_NAME=$2
PARENT_GIT_BRANCH=$3

whoami
cd $PARENT_WORKSPACE
c=`sed -n -e '/^.*VERSION=/p' application.properties`
a=`echo $c | cut -d"'" -f 2`
major=${a%%.*}  
minor=`echo $a | cut -d"." -f 2`
TAG_VERSION="$major.$minor.$PARENT_BUILD_NUMBER"
echo $'\n' >> application.properties
source /var/lib/jenkins/python/global.properties
if [ $PARENT_GIT_BRANCH == $PRODUCTION_GIT_BRANCH ]; then
    echo "REGION_NAME=$PRODUCTION_REGION" >> application.properties
else
    echo "REGION_NAME=$STAGING_REGION" >> application.properties
fi 
echo "PARENT_GIT_BRANCH=$PARENT_GIT_BRANCH" >> application.properties
# update serverless.yml according to PARENT_GIT_BRANCH
python /var/lib/jenkins/python/ymlUpdater.py serverless.yml application.properties /var/lib/jenkins/python/global.properties
# write serviceName functionName to application.properties from serverless.yml
python /var/lib/jenkins/python/ymlParser.py serverless.yml application.properties
echo "TAG_VERSION=$TAG_VERSION" >> application.properties
mkdir -p /tmp/$PARENT_JOB_NAME
cat application.properties > /tmp/$PARENT_JOB_NAME/application.properties
cat application.properties > /tmp/$PARENT_JOB_NAME/application_source.properties
sed -i '/PARAMS=/d' /tmp/$PARENT_JOB_NAME/application_source.properties
sed -i '/RESULTS=/d' /tmp/$PARENT_JOB_NAME/application_source.properties
source /tmp/$PARENT_JOB_NAME/application_source.properties
if [ $LANGUAGE == 'nodejs' ]; then
    echo "LANGUAGE == nodejs"
    echo "$WORKSPACE/build_nodejs.sh"
    sh $WORKSPACE/build_nodejs.sh
elif [ $LANGUAGE == 'python' ]; then
    echo "LANGUAGE == python"
    npm install serverless-python-requirements
else
    echo "neither nodejs nor python error"
fi 

echo "PARENT_WORKSPACE=$PARENT_WORKSPACE"
echo "PARENT_JOB_NAME=$PARENT_JOB_NAME"
echo "PARENT_NODE_LABEL=$PARENT_NODE_LABEL"
echo "TAG_VERSION=$TAG_VERSION"
echo "PRODUCTION_GIT_BRANCH=$PRODUCTION_GIT_BRANCH"
echo "STAGING_GIT_BRANCH=$STAGING_GIT_BRANCH"
echo "PRODUCTION_REGION=$PRODUCTION_REGION"
echo "STAGING_REGION=$STAGING_REGION"
echo "PARENT_GIT_BRANCH=$PARENT_GIT_BRANCH"
echo "LANGUAGE=$LANGUAGE"

sls deploy
