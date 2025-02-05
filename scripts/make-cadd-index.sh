#!/bin/bash

CADD="/refData/CADD-v1.6"

# Any bcftools will do
BCFTOOLS_IMAGE=$( ls ../singularity/depot.galaxyproject.org-singularity-bcftools-1.*.img | head -n1 )


singularity exec -B $(realpath ../refData):/refData \
    $BCFTOOLS_IMAGE \
            tabix --csi -b 2 -e 2 $CADD/whole_genome_SNVs.tsv.gz

