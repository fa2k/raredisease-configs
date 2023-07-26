#!/bin/bash
# Install VEP plugins script

# Requirements:
# ../refData/vep_cache should exist and contain homo_sapiens_merged/
# See notes file for where to get the original vep cache file.

mkdir -p ../refData/vep_cache/Plugins

# Install plugins
singularity run \
    -B `realpath ../refData/vep_cache`:/vepcache \
    -B `realpath ../refData/vep_cache/Plugins`:/.vep/Plugins \
    ../singularity/docker.io-ensemblorg-ensembl-vep-release_107.0.img \
    /opt/vep/src/ensembl-vep/INSTALL.pl \
        -n -u /vepcache -a p -g LoFtool,MaxEntScan,SpliceAI,dbNSFP,pLI

# Download reference files
wget -O ../refData/vep_cache/pLI_values_107.txt https://raw.githubusercontent.com/Ensembl/VEP_plugins/release/107/pLI_values.txt
wget -O ../refData/vep_cache/LoFtool_scores.txt https://raw.githubusercontent.com/Ensembl/VEP_plugins/release/107/LoFtool_scores.txt
wget -O - http://hollywood.mit.edu/burgelab/maxent/download/fordownload.tar.gz | (cd ../refData/vep_cache; tar xz)
