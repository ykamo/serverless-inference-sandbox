#!/bin/bash -x

image_name=demo-sagemaker-inference

account=$(aws sts get-caller-identity --query Account --output text)
region=${AWS_DEFAULT_REGION:-ap-northeast-1}

# upload model file
rm -rf artifacts
mkdir -p artifacts
for i in 1 2
do
    tar -C model${i} -cvzf artifacts/model${i}.tar.gz model.json
done
aws s3 cp --recursive artifacts/ s3://sagemaker-${region}-${account}/${image_name}/

fullname="${account}.dkr.ecr.${region}.amazonaws.com/${image_name}:latest"

# If the repository doesn't exist in ECR, create it.
aws ecr describe-repositories --repository-names "${image_name}" > /dev/null 2>&1

if [ $? -ne 0 ]
then
    aws ecr create-repository --repository-name "${image_name}" > /dev/null
fi


# Build locally
docker buildx build --platform linux/amd64 -t ${image_name} .
docker tag ${image_name} ${fullname}

# Push to ECR
aws ecr get-login-password | docker login --username AWS --password-stdin ${fullname}
docker push ${fullname}

