#!/bin/bash

CLINVAR="/refData/clinvar-2023-06-09"

singularity run -B `realpath ../refData`:/refData \
    ../singularity/depot.galaxyproject.org-singularity-bcftools-1.17--haef29d1_0.img \
        bash -c "gunzip -c $CLINVAR/clinvar.vcf.gz | iconv -f ISO-8859-1 -t UTF-8 | bgzip > $CLINVAR/clinvar_utf8.vcf.gz && \
        tabix -p vcf $CLINVAR/clinvar_utf8.vcf.gz"

