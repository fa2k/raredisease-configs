#!/bin/bash

# Run in conda environment nf-core on Linux computer with Singularity installed
#conda activate nf-core

mkdir -p singularity
export NXF_SINGULARITY_CACHEDIR=$PWD/singularity

# conda update nf-core

# Download pipeline
nf-core download \
    --container-system singularity \
    --compress none \
    --container-cache-utilisation amend \
    raredisease \
    -r 2.0.1
    