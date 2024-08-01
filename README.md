# LUMI Container for Ollama

This repository contains patches and a script to build a container for running Ollama on LUMI.

The build script can be executed by calling `bash build.sh` and performs the following steps

1. clone the Ollama repository
2. check out the desired version tag (edit build.sh to adjust the version number)
3. apply a number of patches required to make Ollama compatible with LUMI
4. build a docker image using the Dockerfile provided by Ollama
5. convert the docker image into a singularity/apptainer image

The build script assumes that all required software is present on the system, most importantly
- git
- docker
- singularity/apptainer

The build process was tested with Ollama v0.3.2. For drastically newer versions, problems might occur.