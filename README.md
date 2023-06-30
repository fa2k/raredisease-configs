# Rare Disease Pipeline configuration files and reference data

RD pipeline, custom config & ref data location in TSD:

/tsd/p164/data/durable/raredisease

This configuration and code is hosted on Github at https://github.com/fa2k/raredisease-configs.
The instructions for assembling all the reference data are given below, but the reference files themselves
are not stored in git (they are listed in .gitignore).


## Link to actual nf-core/raredisease pipeline:

Documentation: https://nf-co.re/raredisease

Github: https://github.com/nf-core/raredisease


# Repository overview

The pipeline and container images are stored under `nf-core-raredisease-dev`.

The container images are also cached under `singularity`, to make it quicker to download
updates to the pipeline.

The reference datasets are stored under `refData`. Most of the reference data have to
be downloaded or generated (see below). Scripts to download or prepare the reference
files are under `scripts`.


# Nextflow version

At the moment we have to use a patched Nextflow that supports the `memPerCpu` option.
This is in the Nexflow development repository, and will be added to Nextflow some time in 2023.

Nextflow: `/tsd/p164/data/durable/raredisease/nextflow-23.06.0-edge-all`.


# Downloading the pipeline and singularity images

The raredisease pipeline is downloaded using the script: `download-pipeline-script.sh`,
which calls `nf-core` tools. The tools can be installed using conda. See:

https://nf-co.re/tools/#installation

...and make sure to follow the instructions to install bioconda. (The temporary `-c bioconda`
doesn't seem to work).
The version should be selected in the script, but currently `dev` is used for testing.


# Sample sheet 

https://nf-co.re/raredisease/1.0.0/usage#samplesheet

* sample: Name for a specific individual
* sex: 1=male, 2=female
* phenotype: 0=missing, 1=unaffected, 2=affected
* case_id: Name for the trio (or singleton) as a whole
* maternal_id, paternal_id: sample name of mother and father or 0 if not present

Create a sample sheet file for a trio or singleton. If there are multiple fastq file pairs for a sample,
they can all be used by adding multiple lines.


# Running the pipeline


The fastq files should be in: `/tsd/p164/data/durable/WGS/data_fastq/<project>`.

The finsihed analyses should be in: `/tsd/p164/data/durable/WGS/analysis/<project>`.

The analysis can be started and run under: `/tsd/p164/data/no-backup/active-wgs-analyses/<project>`.

1. Create the sample sheet (`samples.csv`) and a script file in the active analysis dir. The sample sheet should refer directly
to the fastq file locations under `durable/WGS/data_fastq` (this is available from the cluster nodes).

2. Create a link named `ref` to the reference data directory (this allows us to use relative paths in the parameter file).

    ln -s ../../durable/raredisease/refData ref

3. Create the script file. 

    module load singularity/3.7.3
    
    /tsd/p164/data/durable/raredisease/nextflow-23.06.0-edge-all run \
        /tsd/p164/data/durable/raredisease/nf-core-raredisease-dev/workflow \
        -c ../raredisease/medGenConfigs/process-overrides.conf \
        -c ../raredisease/medGenConfigs/tsd-settings.conf \
        -params-file ../raredisease/medGenConfigs/grch38-params.yaml \
        --input samples.csv \
        --outdir results \
        --max_memory '500 GB' \
        --max_cpus 64 \
        -profile singularity \
        -resume

4. Check kerberos ticket lifetime is renewable for a week or more `klist`. (TODO TBC it never is though)

5. Log on to `p164-submit`, go to the active analysis directory for the project, and run `bash script.sh`.



## Config

General config files for running raredisease pipeline (in /tsd/p164/data/durable/raredisease/medGenConfigs):

* process-overrides.conf: Fine-tuning of resource allocations, and customisations/work-arounds that apply for all environments.
* tsd-settings.conf: TSD Cluster options
* *xxx*-settings.conf: Options for running on other systems (for development and testing)
* grch38-params.yaml: Pipeline configuration and reference data options


# Reference data

Everything below is about reference data!

**The details here should be updated when new reference data are downloaded.** The old reference data may be moved into `archive/`.


### iGenomes NCBI GRCh38 reference sequence and index files

Downloaded from https://support.illumina.com/sequencing/sequencing_software/igenome.html
Date: 22 May 2023
Into: /tsd/p164/data/durable/raredisease/refData
Unpacked in refdata: tar xf Homo_sapiens_NCBI_GRCh38.tar.gz

    $ md5sum Homo_sapiens_NCBI_GRCh38.tar.gz
    61d263698f0283075f63b1514a16045d  Homo_sapiens_NCBI_GRCh38.tar.gz



### ExpansionHunter / Stranger catalogue file

Downloaded from Stranger github repo (github.com/Clinical-Genomics/stranger): https://raw.githubusercontent.com/Clinical-Genomics/stranger/master/stranger/resources/variant_catalog_grch38.json

Commit of Nov 15 2021 / 9fa3652

/tsd/p164/data/durable//raredisease/refData/variant_catalog_grch38.json



### VEP cache (v107)

Downloaded from Ensembl website https://www.ensembl.org/info/docs/tools/vep/script/vep_cache.html

https://ftp.ensembl.org/pub/release-107/variation/indexed_vep_cache/homo_sapiens_merged_vep_107_GRCh38.tar.gz

Untarred in /tsd/p164/data/durable//raredisease/refData/vep_cache/

    $ tar xf homo_sapiens_merged_vep_107_GRCh38.tar.gz



### VEP plugins (v107)

Plugin information from VEP here: https://www.ensembl.org/info/docs/tools/vep/script/vep_plugins.html

* Installing VEP plugins and downloading plugins reference data *

At least the plugin pLI is required in order to run the pipeline. The list of active plugins is based on
trying to imitate the test file @

https://raw.githubusercontent.com/nf-core/test-datasets/raredisease/reference/vep_cache_and_plugins.tar.gz


Plugins are installed into the vep_cache dir using the following script. Internet access and
Docker is required.

    $ cd scripts
    $ bash install-vep-plugins.sh

Script executed & downloads performed 2023-05-26. Accessed:

- https://raw.githubusercontent.com/Ensembl/VEP_plugins/release/107/pLI_values.txt
- https://raw.githubusercontent.com/Ensembl/VEP_plugins/release/107/LoFtool_scores.txt
- http://hollywood.mit.edu/burgelab/maxent/download/fordownload.tar.gz


* Additional reference data for SpliceAI from Illumina (only available after BaseSpace login) *

Download link here:
https://basespace.illumina.com/s/otSPW8hnhaZR


Download from basespace folder: Analysis: **genome_scores_v1.3**. Downloaded: **2023-05-25**.

Place these in vep_cache dir. The vep config `ext.args` is defined in the workflow repo
`nf-core-raredisease-dev/workflow/conf/modules/annotate_snvs.config`. The override in
`medGenConfigs/process-overrides.conf` sets the following paths.

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

(It used to be necessary to supply MT reference files. This is now integrated in the pipeline.)


### gnomAD

gnomAD data downloaded from: https://gnomad.broadinstitute.org/downloads#v3

Genomes: There are two vcf files per chromosome:

    gnomad.genomes.v3.1.2.hgdp_tgp.chr19.vcf.bgz
    gnomad.genomes.v3.1.2.sites.chr19.vcf.bgz

The sites files are used to create the combined gnomad vcf file:

    gnomad.genomes.v3.1.2.sites.af.vcf.bgz

Gnomad mitochondrial data file is tiny and doesn't need to be reformatted.
It is used by vcfanno. Downloaded from:

https://storage.googleapis.com/gcp-public-data--gnomad/release/3.1/vcf/genomes/gnomad.genomes.v3.1.sites.chrM.vcf.bgz

and

https://storage.googleapis.com/gcp-public-data--gnomad/release/3.1/vcf/genomes/gnomad.genomes.v3.1.sites.chrM.vcf.bgz.tbi


### gnomAD tab file

The `gnomad_af` argument expects a tab.gz file, not a VCF. Run:

    cd scripts/
    bash convert-gnomad-to-tsv.sh


### gnomAD SV

Gnomad SV is only available for version 2.1.

Downloaded from the gnomAD servers:

* https:////storage.googleapis.com/gcp-public-data--gnomad/papers/2019-sv/gnomad_v2.1_sv.sites.vcf.gz



### CADD

Files containing only CADD scores, not all annotations, are downloaded for
use in vcfanno.

* https://kircherlab.bihealth.org/download/CADD/v1.6/GRCh38/whole_genome_SNVs.tsv.gz
* https://kircherlab.bihealth.org/download/CADD/v1.6/GRCh38/whole_genome_SNVs.tsv.gz.tbi



### vcfanno

vcfanno resources has to be absolute paths. The script `make-vcfanno-resources.sh` can be run
to produce `vcfanno_resources.txt` based on the current working directory.

Run from repo root, i.e.: `bash scripts/make-vcfanno-resources.sh`.


### svdb

* svdb_query_dbs.csv

1. Copied from the test dataset (https://github.com/nf-core/test-datasets/blob/raredisease/reference/svdb_querydb_files.csv)
2. Modified the path.


### ClinVar

Downloaded from:

https://ftp.ncbi.nlm.nih.gov/pub/clinvar/vcf_GRCh38/

On 2023-06-09.

    9379313cbfdb0abb8ff7b40b0ae8d810  clinvar.vcf.gz
    9b9c76380c565b395fea00bf09681035  clinvar.vcf.gz.tbi



### genmod - rank_model_snv.ini / rank_model_sv.ini

Initially copied from the test datasets and Clinical Genomics's configs (https://github.com/Clinical-Genomics/reference-files/tree/master/rare-disease/annotation).

