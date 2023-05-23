# Notes - Rare Disease Pipeline

RD pipeline, custom config & ref data location:

/cluster/projects/p164/raredisease/




# Pipeline & Container images

The raredisease pipeline was downloaded using nf-core tools on 22 May 2023.


    docker run -ti --rm -v $PWD:$PWD -w $PWD nfcore nf-core download -r dev -c singularity raredisease

Current commit on `dev` branch in github downloaded:

TODO this will be updated - not use for production load


(nfcore docker image created from Dockerfile: https://github.com/fa2k/dockerfiles/tree/main/nfcore-singularity)

Location of actual raredisease pipeline in TSD is:
/cluster/projects/p164/raredisease




# Sample sheet 

* sample: Name for a specific individual
* sex: 1=male, 2=female
* phenotype: 0=missing, 1=unaffected, 2=affected
* case_id: Name for the trio (or singleton) as a whole
* maternal_id, paternal_id: sample name of mother and father or 0 if not present



# Pipeline execution procedure (TODO)

module load Nextflow/22.10.6

TODO


## Config

General config files for running raredisease pipeline (in /cluster/projects/p164/raredisease/medGenConfigs):

* tsd-settings.conf: TSD Cluster options
* grch38-params.yaml: Pipeline configuration and reference data options





# Reference data

Everything below is about reference data!


### iGenomes NCBI GRCh38 reference sequence and index files

Downloaded from https://support.illumina.com/sequencing/sequencing_software/igenome.html
Date: 22 May 2023
Into: /cluster/projects/p164/raredisease/refData
Unpacked in refdata: tar xf Homo_sapiens_NCBI_GRCh38.tar.gz

    $ md5sum Homo_sapiens_NCBI_GRCh38.tar.gz
    61d263698f0283075f63b1514a16045d  Homo_sapiens_NCBI_GRCh38.tar.gz



### ExpansionHunter / Stranger catalogue file

Downloaded from Stranger github repo (github.com/Clinical-Genomics/stranger)
https://raw.githubusercontent.com/Clinical-Genomics/stranger/master/stranger/resources/variant_catalog_grch38.json
Commit of Nov 15 2021 / 9fa3652

/cluster/projects/p164/raredisease/refData/variant_catalog_grch38.json



### VEP cache (v107)

Downloaded from Ensembl website https://www.ensembl.org/info/docs/tools/vep/script/vep_cache.html
https://ftp.ensembl.org/pub/release-107/variation/indexed_vep_cache/homo_sapiens_merged_vep_107_GRCh38.tar.gz

Untarred in /cluster/projects/p164/raredisease/refData/vep_cache/

    $ tar xf homo_sapiens_merged_vep_107_GRCh38.tar.gz



### VEP plugins (v107)

Plugin information from VEP here:
https://www.ensembl.org/info/docs/tools/vep/script/vep_plugins.html

* Installing VEP plugins and downloading plugins reference data *

At least the plugin pLI is required in order to run the pipeline. The list of active plugins is based on
trying to imitate the test file @
https://raw.githubusercontent.com/nf-core/test-datasets/raredisease/reference/vep_cache_and_plugins.tar.gz


Plugins are installed into the vep_cache dir using the following script. Internet access and
Docker is required.

    $ cd scripts
    $ bash install-vep-plugins.sh


* Additional reference data for SpliceAI from Illumina (only available after BaseSpace login) *

Download link here:
https://basespace.illumina.com/s/otSPW8hnhaZR


Download from basespace folder: Analysis: genome_scores_v1.3
Place these in vep_cache dir (? TODO checking).

    beb5b6e3adbe45abfe3aaf2d9776f932  spliceai_scores.raw.indel.hg38.vcf.gz
    ef01ec815c35ce32adc3d65cab62df67  spliceai_scores.raw.indel.hg38.vcf.gz.tbi
    b3ac9315317e6bea43fb8dd5797fcba4  spliceai_scores.raw.snv.hg38.vcf.gz
    cb7b1b692961fe148aab87dcee823d84  spliceai_scores.raw.snv.hg38.vcf.gz.tbi



### Intervals files

Create bed files and interval_lists from genome dict file using the following script:

    $ cd scripts/
    $ bash create-bed-and-intervals.sh

As it stands, this script requires docker. It could be rewritten to use singularity.



### Mitochondrial genome

Mitochondrial-only reference, and shifted mitochondrial reference is created using the
gatk docker image - running the following script:

    $ cd scripts/
    $ bash create-mito-references.sh

The GATK intervals files with coordinates of the control region are crafted manually.
These are stored in scripts directory.

    ==> chrM_non_control.intervals <==
    chrM:577-16023

    ==> chrM_shifted_non_control.intervals <==
    chrM:1-4454
    chrM:5577-16569



### vcfanno


