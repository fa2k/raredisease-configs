#!/bin/bash

# Run in conda environment nf-core on Linux computer with Singularity installed
#conda activate nf-core

mkdir -p singularity

# conda update nf-core

# Download pipeline
docker run --rm \
    --volume $PWD:/data \
    --workdir /data \
    -e NXF_SINGULARITY_CACHEDIR=/data/singularity \
        nfcore/gitpod \
        nf-core pipelines download \
        --container-system singularity \
        --compress none \
        --container-cache-utilisation copy \
        raredisease \
        -r 2.6.0
    
