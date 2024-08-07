#!/bin/sh
#
# Creates a docker and a singularity image of Ollama for running on LUMI
# with the version specified below (must be a version tag in the Ollama github repo)
#

set -xe

OLLAMA_VERSION=v0.3.2
LUMI_ROCM_VERSION=5.6.1  # this is the last ROCM version compatible with AMD drivers on LUMI
DOCKER_BASE_IMAGE_NAME=csc/lumi/rocm
DOCKER_IMAGE_NAME=csc/lumi/ollama
SINGULARITY_IMAGE_NAME=ollama-lumi-${OLLAMA_VERSION}.sif

# Build LUMI ROCM base image
docker build -t $DOCKER_BASE_IMAGE_NAME:$LUMI_ROCM_VERSION --build-arg ROCM_VERSION=$LUMI_ROCM_VERSION -f LUMI-ROCM-Dockerfile .

# Clone ollama codebase
rm -rf buildtmp
mkdir buildtmp
git clone https://github.com/ollama/ollama.git buildtmp/ollama/

# Enter ollama repository and set up cleanup logic
pushd buildtmp/ollama
trap 'popd; rm -rf buildtmp' EXIT

# Check out desired version
git checkout $OLLAMA_VERSION

# Apply code patches to Ollama that are required to run on LUMI
git apply ../../lumi-patches/*.patch

# Build Ollama ROCM docker image
docker build -t $DOCKER_IMAGE_NAME:$LUMI_ROCM_VERSION --target runtime-rocm --build-arg AMDGPU_TARGETS="gfx90a:sramecc+:xnack-" --build-arg ROCM_VERSION=$LUMI_ROCM_VERSION --build-arg ROCM_BASE_IMAGE=$DOCKER_BASE_IMAGE_NAME:$LUMI_ROCM_VERSION .

# Convert docker to singularity/apptainer image for LUMI
singularity build ../../$SINGULARITY_IMAGE_NAME docker-daemon://$DOCKER_IMAGE_NAME:$LUMI_ROCM_VERSION
