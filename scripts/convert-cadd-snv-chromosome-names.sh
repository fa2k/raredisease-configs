#!/bin/bash

CADD="/refData/CADD-v1.6"

singularity exec -B $(realpath ../refData):/refData \
    ../singularity/depot.galaxyproject.org-singularity-bcftools-1.17--haef29d1_0.img \
    bash -c "gunzip -c $CADD/whole_genome_SNVs.tsv.gz | awk '{ if(\$0 !~ /^#/) print \"chr\"\$0; else print \$0 }' | bgzip > $CADD/whole_genome_SNVs_chr.tsv.gz && \
            tabix -p vcf $CADD/whole_genome_SNVs_chr.tsv.gz"
