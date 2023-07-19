#!/bin/bash

# Alternative: Use docker image
# curl https://raw.githubusercontent.com/fa2k/dockerfiles/main/nfcore-singularity/Dockerfile | docker build -t nfcore -
# docker run -ti --rm -v $PWD:$PWD -w $PWD -e NXF_SINGULARITY_CACHEDIR=$PWD/singularity \
#	nfcore \
#	nf-core download \
#	    -c singularity \
#	    --compress none \
#	    raredisease \
#	    -r dev

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
    

