#!/bin/bash
# Install VEP plugins script

# Requirements:
# ../refData/vep_cache should exist and contain homo_sapiens_merged/
# See README file for where to get the original vep cache file.

# This script uses a different singularity image than the one used by the raredisease
# pipeline, because it needs the INSTALL.pl script.
# NOTE: It is important to update the image version when the VEP version is updated.

mkdir -p ../refData/vep_cache/Plugins

# Install plugins
singularity run \
    -B `realpath ../refData/vep_cache`:/vepcache \
    --no-home \
    docker://ensemblorg/ensembl-vep:release_110.1 \
    INSTALL.pl \
	-r /vepcache/Plugins \
        -n -u /vepcache -a p -g LoFtool,MaxEntScan,SpliceAI,dbNSFP,pLI
