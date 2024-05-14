
GNOMAD_DIR=$PWD
SINGULARITY_DIR=../../singularity
TMP_DIR=`realpath ~/local/vcf`
mkdir -p $TMP_DIR
FILE_LIST=""
for chrom in `seq 1 22` X Y
do
    THIS_FILE="/data/temp/gnomad.joint.v4.1.sites.chr${chrom}.af.bcf"
    singularity run  \
        -B `realpath $TMP_DIR`:/data/temp \
        -B `realpath $GNOMAD_DIR`:/data/input \
        $SINGULARITY_DIR/depot.galaxyproject.org-singularity-bcftools-1.18--h8b25389_0.img \
        bcftools annotate -Ob -x ^INFO/AF_joint,^INFO/AF_genomes,^INFO/AF_grpmax_joint \
                -o $THIS_FILE \
                /data/input/gnomad.joint.v4.1.sites.chr${chrom}.vcf.bgz &
    FILE_LIST="$FILE_LIST $THIS_FILE"
done

wait

# Merge chromosomes
singularity run \
        -B `realpath $TMP_DIR`:/data/temp \
        $SINGULARITY_DIR/depot.galaxyproject.org-singularity-bcftools-1.18--h8b25389_0.img \
        bcftools concat -Oz $FILE_LIST \
            -o /data/temp/gnomad.joint.v4.1.sites.af.vcf.bgz

singularity run \
        -B `realpath $TMP_DIR`:/data/temp \
        $SINGULARITY_DIR/depot.galaxyproject.org-singularity-bcftools-1.18--h8b25389_0.img \
        tabix -p vcf /data/temp/gnomad.joint.v4.1.sites.af.vcf.bgz
