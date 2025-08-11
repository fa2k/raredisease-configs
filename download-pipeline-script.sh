#!/bin/bash

# Run in conda environment nf-core on Linux computer with Singularity installed
#conda activate nf-core

mkdir -p singularity
export NXF_SINGULARITY_CACHEDIR=$PWD/singularity

# conda update nf-core

# Download pipeline
nf-core pipelines download \
    --container-system singularity \
    --compress none \
    --container-cache-utilisation copy \
    raredisease \
    -r 2.6.0
    
