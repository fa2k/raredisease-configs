
# Convert gnomAD VCF to the format required by the `--gnomad_af` option.
# The output file is tab-delimited with the following columns:
# - Chromosome
# - Position
# - Reference and alternate alleles (comma-separated)
# - Allele frequency

gunzip -c ../refData/gnomad.genomes.v3.1.2.sites.af.vcf.bgz | \
           awk -F "\t" -v OFS='\t' \
                '!/^#/ {split($8,a,";"); for(i in a) if(a[i] ~ /^AF=/) {split(a[i],b,"="); print $1, $2, $4 "," $5, b[2]}}' \
                | \
            singularity run ../singularity/depot.galaxyproject.org-singularity-bcftools-1.17--haef29d1_0.img \
                bgzip \
                > ../refData/gnomad.genomes.v3.1.2.af.tab.gz
