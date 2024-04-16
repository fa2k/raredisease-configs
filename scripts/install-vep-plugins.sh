#!/bin/bash
# Install VEP plugins script

# Requirements:
# ../refData/vep_cache should exist and contain homo_sapiens_merged/
# See notes file for where to get the original vep cache file.

mkdir -p ../refData/vep_cache/Plugins

# Install plugins
singularity run \
    -B `realpath ../refData/vep_cache`:/vepcache \
    --no-home \
    ../singularity/docker.io-ensemblorg-ensembl-vep-release_107.0.img \
    /opt/vep/src/ensembl-vep/INSTALL.pl \
	-r /vepcache/Plugins \
        -n -u /vepcache -a p -g LoFtool,MaxEntScan,SpliceAI,dbNSFP,pLI
