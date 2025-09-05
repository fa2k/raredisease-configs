#!/bin/bash

INPUT="$1"

if [ -z "$1" ]
then
	echo "usage: postprocess-script.sh FILE_NAME"
	exit 1
fi

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
RAREDISEASE_DIR=$( dirname $SCRIPT_DIR )

basenameinput=$( basename $INPUT )
# Supports either the annotated VCF or the ranked VCF
output=${basenameinput%_vep_csq_pli.vcf.gz}_postProc.vcf.gz
output=${basenameinput%_ranked_research.vcf.gz}_postProc.vcf.gz


singularity exec \
    -B $PWD \
    -B $SCRIPT_DIR/postprocessing-v3.py:/postprocessing-v3.py \
    -B $PWD/ref/variant_consequences_v2.txt:/variant_consequences_v2.txt \
    -W $PWD \
    $RAREDISEASE_DIR/nf-core-raredisease_*/singularity-images/depot.galaxyproject.org-singularity-python-3.8.3.img \
    python /postprocessing-v3.py \
        --severity-file /variant_consequences_v2.txt \
        --tempfile tempfile.vcf.temp \
        $INPUT \
        | \
    singularity exec \
        $RAREDISEASE_DIR/nf-core-raredisease_*/singularity-images/depot.galaxyproject.org-singularity-bcftools-1.20--h8b25389_0.img \
        bgzip > $output

