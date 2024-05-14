
# Convert gnomAD VCF to the format required by the `--gnomad_af` option.
# The output file is tab-delimited with the following columns:
# - Chromosome
# - Position
# - Reference and alternate alleles (comma-separated)
# - Allele frequency (uses AF_joint, which is the allele frequency in the combined exome and genome dataset)

gunzip -c ../refData/gnomad.joint.v4.1.sites.af.vcf.bgz | \
           awk -F "\t" -v OFS='\t' \
                '!/^#/ {split($8,a,";"); for(i in a) if(a[i] ~ /^AF_joint=/) {split(a[i],b,"="); print $1, $2, $4 "," $5, b[2]}}' \
                | \
            singularity run ../singularity/depot.galaxyproject.org-singularity-bcftools-1.18--h8b25389_0.img \
                bgzip \
                > ../refData/gnomad.joint.v4.1.af.tab.gz
