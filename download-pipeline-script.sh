#!/bin/bash

# Alternative: Use docker image
# curl https://raw.githubusercontent.com/fa2k/dockerfiles/main/nfcore-singularity/Dockerfile | docker build -t nfcore -
# docker run -ti --rm -v $PWD:$PWD -w $PWD nfcore nf-core download -r dev -c singularity raredisease

# Run in conda environment nf-core
#conda activate nf-core

mkdir -p singularity
export NXF_SINGULARITY_CACHEDIR=$PWD/singularity

# Download pipeline
nf-core download \
    -c singularity \
    --compress none \
    raredisease \
    -r dev
    

