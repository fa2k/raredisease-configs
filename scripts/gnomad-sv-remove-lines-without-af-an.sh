
# Remove variants that don't have the AC lin

gunzip -c ../refData/gnomad.v4.1.sv.sites.vcf.gz | \
           grep -E '^#|;AC=' | \
           singularity run ../singularity/depot.galaxyproject.org-singularity-bcftools-1.18--h8b25389_0.img \
                bgzip \
                > ../refData/gnomad.v4.1.sv.sites.acOnly.vcf.gz
