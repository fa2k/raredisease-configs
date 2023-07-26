
GNOMAD_DIR=/data/nobackup/nsc/gnomad/genomes

TMP_DIR=/local/vcf
mkdir -p $TMP_DIR
FILE_LIST=""
for chrom in `seq 1 22` X Y
do
    THIS_FILE="/data/temp/gnomad.genomes.v3.1.2.sites.chr${chrom}.af.bcf"
    singularity run  \
        -B `realpath $TMP_DIR`:/data/temp \
        -B `realpath $GNOMAD_DIR`:/data/input \
        ../singularity/depot.galaxyproject.org-singularity-bcftools-1.16--hfe4b78e_1.img \
        bcftools annotate -Ob -x ^INFO/AF,^INFO/AF_popmax \
                -o $THIS_FILE \
                /data/input/gnomad.genomes.v3.1.2.sites.chr${chrom}.vcf.bgz &
    FILE_LIST="$FILE_LIST $THIS_FILE"
done

wait

# Merge chromosomes
singularity run \
        -B `realpath $TMP_DIR`:/data/temp \
        ../singularity/depot.galaxyproject.org-singularity-bcftools-1.16--hfe4b78e_1.img \
        bcftools concat -Oz $FILE_LIST \
            -o /data/temp/gnomad.genomes.v3.1.2.sites.af.vcf.bgz

singularity run \
        -B `realpath $TMP_DIR`:/data/temp \
        ../singularity/depot.galaxyproject.org-singularity-bcftools-1.16--hfe4b78e_1.img \
        tabix -p vcf /data/temp/gnomad.genomes.v3.1.2.sites.af.vcf.bgz
