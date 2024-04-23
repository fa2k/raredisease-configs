#!/bin/bash

INPUT=$1
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
RAREDISEASE_DIR=$( dirname $SCRIPT_DIR )

basename=$( basename $INPUT )
output=${basename%_vep_csq_pli.vcf.gz}_postProc_forFiltus.vcf.gz

singularity exec \
    -B $PWD \
    -B $SCRIPT_DIR/postprocess-vcf.py:/postprocess-vcf.py \
    -B $PWD/ref/variant_consequences_v2.txt:/variant_consequences_v2.txt \
    -W $PWD \
    $RAREDISEASE_DIR/singularity/depot.galaxyproject.org-singularity-python-3.8.3.img \
    python /postprocess-vcf.py \
        --severity-file /variant_consequences_v2.txt \
        $INPUT \
        | \
    singularity exec \
        $RAREDISEASE_DIR/singularity/depot.galaxyproject.org-singularity-bcftools-1.18--h8b25389_0.img \
        bgzip > $output

