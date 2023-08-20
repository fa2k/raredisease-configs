#!/bin/bash

CADD="/refData/CADD-v1.6"

singularity exec -B $(realpath ../refData):/refData \
    ../singularity/depot.galaxyproject.org-singularity-bcftools-1.17--haef29d1_0.img \
            tabix --csi -b 2 -e 2 -m 9 $CADD/whole_genome_SNVs.tsv.gz
