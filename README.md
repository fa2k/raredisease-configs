# Rare Disease Pipeline configuration files and reference data

RD pipeline, custom config & ref data location in TSD:

/tsd/p164/data/durable/raredisease

This configuration and code is hosted on Github at https://github.com/fa2k/raredisease-configs.
The instructions for assembling all the reference data are given below, but the reference files themselves
are not stored in git (they are listed in .gitignore). Some small reference data or config files
are in `refData`.


## Link to actual nf-core/raredisease pipeline:

Documentation: https://nf-co.re/raredisease

Github: https://github.com/nf-core/raredisease (note: master branch is not relevant. Development is done in `dev` branch.)


# Repository overview

The pipeline and container images are stored under `nf-core-raredisease_<version>`.

The container images are also cached under `singularity`, to make it quicker to download
updates to the pipeline.

The reference datasets are stored under `refData`. Most of the reference data have to
be downloaded or generated (see below). Some small files are tracked in git and don't
need to be downloaded. `refData` contains some configuration files, not just reference
data.

Scripts to download or prepare the reference files are under `scripts`. You can expect
to have to alter the scripts with new versions of the singularity images, as they use
specific versions of the tools to do their job.


# Nextflow version

A nextflow version from 2023-07 or newer is required to support `perMemCpuAllocation`,
which enables it to use the `--mem-per-cpu` option in SLURM, instead of `--mem`.
The full package Nextflow artefacts from github, ending in `-all` are designed for
offline use, but they can't support the necessary plugin `nf-validation` (required
by the pipeline). Unfortunately, this means that we need a per-user nextlfow install
in TSD, based on transferring `$HOME/.nextflow` (see 
https://github.com/nextflow-io/nextflow/discussions/4126#discussioncomment-6539565).


## Procedure to prepare a working nextflow for TSD

1. Download the *online* nextflow binary (not -all) from Github and put it on
   the path: https://github.com/nextflow-io/nextflow/releases. Use a computer
   that's able to run the pipeline (for simplicity).

Example:
```
cd $HOME/bin
wget https://github.com/nextflow-io/nextflow/releases/download/v23.07.0-edge/nextflow
chmod +x nextflow
```

2. Run the raredisease test to make sure all nextflow dependencies are downloaded. There's
   no need to run the full test, just make sure it starts processing and kill it. You also
   need to explicitly install the plugin into nextflow's home directory.

```
nextflow run nf-core/raredisease -r VERSION -profile test,singularity
rm -r results/ work/
nextflow plugin install nf-validation
```

Note that `medGenConfigs/tsd-settings.conf` specifies this plugin version. The version used
there has to match the actual version - see `$HOME/.nextflow/plugins`.


3. Copy the nextflow binary and its files across to TSD:

```
cd
tar cf nextflow.tar .nextflow bin/nextflow
tacl p164 --upload nextflow.tar
```

4. Unpack nextflow in TSD.

```
cd
tar xf PATH_TO_NEXTFLOW.tar
```


# Pipeline and singularity images

The raredisease pipeline is downloaded using the script: `download-pipeline-script.sh`,
which calls `nf-core` tools. The tools can be installed using conda. See:

https://nf-co.re/tools/#installation

...and make sure to follow the instructions to install bioconda. (The temporary `-c bioconda`
doesn't seem to work).
The version should be selected in the script and committed (as of writing 1.1.1, but check the script). Make sure to use a recent version of nf-core tools (summer 2023), as the container system option has changed.

The tool will ask to install the institutional configuration files. This is not applicable for TSD
so say no.

## Pipeline version used

* 2023-07 (newer): Pipeline version 1.1.1.

* 2023-07: The pipeline downloaded on 2023-06-09, dev branch, was used. Commit:
  decbf4389cc3043b18c61002e023db51348e428b. This is used instead of release
  1.0.0, as the new MT-analysis parameters are forward-compatible. This was used
  for testing and configuration


# Sample sheet 

https://nf-co.re/raredisease/1.1.1/usage#samplesheet

* sample: Name for a specific individual
* sex: 1=male, 2=female
* phenotype: 0=missing, 1=unaffected, 2=affected
* case_id: Name for the trio (or singleton) as a whole
* maternal_id, paternal_id: sample name of mother and father or 0 if not present

Create a sample sheet file for a trio or singleton. If there are multiple fastq file pairs for a sample,
they can all be used by adding multiple lines.


# Running the pipeline

Samples are usually grouped into projects, which correspond to a trio or a single sample.

* The fastq files should be in: `/tsd/p164/data/durable/WGS/data_fastq/<project>`.
* The analysis directory should be in: `/tsd/p164/data/durable/WGS/analysis/<project>`. This contains the script,
  the sample sheet and the output directory.
* Nextflow's work folder is directed to the no-backup area: `/tsd/p164/data/no-backup/active-wgs-analyses/<project>`.

Procedure to run the pipeline:

1. Create the sample sheet (`samples.csv`) and a script file in the active analysis dir. The sample sheet should refer directly
to the full fastq file paths under `durable/WGS/data_fastq` (this is available from the cluster nodes).

2. Create a link named `ref` to the reference data directory (this allows us to use relative paths in the parameter file).

```
    ln -s ../../durable/raredisease/refData ref
```

3. Create the script file. 

```
**** TODO -- paste current version of script file here ****

module load singularity/3.7.3
module load Java/11.0.2

export TMPDIR=/tsd/p164/data/no-backup/active-wgs-analyses/tmp

/tsd/p164/data/durable/raredisease/nextflow-23.06.0-edge-all run \
	/tsd/p164/data/durable/raredisease/nf-core-raredisease-dev/workflow \
	-c /tsd/p164/data/durable/raredisease/medGenConfigs/process-overrides.conf \
	-c /tsd/p164/data/durable/raredisease/medGenConfigs/tsd-settings.conf \
	-params-file /tsd/p164/data/durable/raredisease/medGenConfigs/grch38-params.yaml \
	--input samples.csv \
	--outdir results \
	--max_memory '500 GB' \
	--max_cpus 64 \
	-profile singularity \
	-resume

```

4. Log on to `p164-submit`, go to the active analysis directory for the project, and run `bash script.sh`.

5. Wait {5} days on average for it to finish (TODO update time).

6. Delete the `work` directory under `/tsd/p164/data/no-backup/active-wgs-analyses/`.


## Config

General config files for running raredisease pipeline (in /tsd/p164/data/durable/raredisease/medGenConfigs):

* `process-overrides.conf`: Fine-tuning of resource allocations, and customisations/work-arounds that apply for all environments.
* `tsd-settings.conf`: TSD Cluster options
* `xxx-settings.conf`: Options for running on other systems (for development and testing)
* `grch38-params.yaml`: Pipeline configuration and reference data options


# Reference data

Everything below is about reference data!

**The details here should be updated when new reference data are downloaded.** The old reference data may be moved into `archive/`.


### bwamem2 index

bwamem2 index is precomputed to save time (not required to run the pipeline). The script `make-bwamem2.sh` handles this:

    $ cd scripts/
    $ bash make-bwamem2.sh


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

/tsd/p164/data/durable/raredisease/refData/variant_catalog_grch38.json



### VEP cache (v107)

Downloaded from Ensembl website https://www.ensembl.org/info/docs/tools/vep/script/vep_cache.html

https://ftp.ensembl.org/pub/release-107/variation/indexed_vep_cache/homo_sapiens_merged_vep_107_GRCh38.tar.gz

Untarred in /tsd/p164/data/durable//raredisease/refData/vep_cache/

    $ tar xf homo_sapiens_merged_vep_107_GRCh38.tar.gz



### VEP plugins (v107)

Plugin information from VEP here: https://www.ensembl.org/info/docs/tools/vep/script/vep_plugins.html

* Installing VEP plugins and downloading plugins reference data *

The list of active plugins is based on trying to imitate the test file at:

https://raw.githubusercontent.com/nf-core/test-datasets/raredisease/reference/vep_cache_and_plugins.tar.gz

At least the plugin pLI is required in order to run the SNV annotation (ADD_MOST_SEVERE_PLI).
Other plugins are definitely needed to run the ranking steps in `GENMOD` processes.
Plugins are installed into the vep_cache dir using the following script. Internet access and
singularity is required.

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
`<raredisease>/conf/modules/annotate_snvs.config`. The override in
`medGenConfigs/process-overrides.conf` sets the following paths.

    beb5b6e3adbe45abfe3aaf2d9776f932  spliceai_scores.raw.indel.hg38.vcf.gz
    ef01ec815c35ce32adc3d65cab62df67  spliceai_scores.raw.indel.hg38.vcf.gz.tbi
    b3ac9315317e6bea43fb8dd5797fcba4  spliceai_scores.raw.snv.hg38.vcf.gz
    cb7b1b692961fe148aab87dcee823d84  spliceai_scores.raw.snv.hg38.vcf.gz.tbi



### Intervals files

Create bed files and interval_lists from genome dict file using the following script:

    $ cd scripts/
    $ bash create-bed-and-intervals.sh


### Mitochondrial genome

(It used to be necessary to supply MT reference files. This is now integrated in the pipeline.)


### gnomAD

gnomAD data downloaded from: https://gnomad.broadinstitute.org/downloads#v3

Genomes: There are two vcf files per chromosome:

    gnomad.genomes.v3.1.2.hgdp_tgp.chr19.vcf.bgz
    gnomad.genomes.v3.1.2.sites.chr19.vcf.bgz

The sites files are used to create the combined gnomad vcf file:

    gnomad.genomes.v3.1.2.sites.af.vcf.bgz

The script `make-gnomad-af-file.sh` does this job - but don't expect it to work without some hassle.
It's a big processing job, and it's done once and not tested again.


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

gnomAD SV is only available for version 2.1, which is aligned to hg19. We should instead
use a remapped version of gnomAD SV 2.1 (map to GRCh38) from dbVar. These files contain
the allele frequencies of SVs in various populations.

Info here: https://www.ncbi.nlm.nih.gov/sites/dbvarapp/studies/nstd166/

The files are downloaded from here:

* https://ftp.ncbi.nlm.nih.gov/pub/dbVar/data/Homo_sapiens/by_study/vcf/nstd166.GRCh38.variant_call.vcf.gz
* https://ftp.ncbi.nlm.nih.gov/pub/dbVar/data/Homo_sapiens/by_study/vcf/nstd166.GRCh38.variant_call.vcf.gz.tbi


### CADD

(This was changed when CADD was implemented as a tool in the pipeline - which enables CADD for indels.)

CADD installation is described here: https://github.com/kircherlab/CADD-scripts/#manual-installation,
but it's not necessary to install it, as it's included in the pipeline.

Annotation data file can be downloaded from a link from there (CADD 1.6):

* https://krishna.gs.washington.edu/download/CADD/v1.6/GRCh38/annotationsGRCh38_v1.6.tar.gz

This tar file contains a single directory .... so it can be extracted directly in refData
(consider confirming this with tar vtf).
Put it in a directory with the CADD version:
TODO- check what path is expected by pipeline / subdir
```
mkdir -p refData/CADD-v1.6
cd refData/CADD-v1.6
wget https://krishna.gs.washington.edu/download/CADD/v1.6/GRCh38/annotationsGRCh38_v1.6.tar.gz
tar xf annotationsGRCh38_v1.6.tar.gz
```

### vcfanno

vcfanno resources has to be absolute paths. The script `make-absolute-paths.sh` can be run
to produce `vcfanno_resources.txt` based on the path of the repository root directory.

Run from scripts directory (like all the other scripts):

    cd scripts
    bash make-absolute-paths.sh

This also absolutises the path for svdb; see next section.


### svdb

* svdb_query_dbs_template.csv

1. Copied from the test dataset (https://github.com/nf-core/test-datasets/blob/raredisease/reference/svdb_querydb_files.csv) and modified to point to the right vcf.
2. The path in the template file is a placeholder (`PATH`), and it needs to be interpreted by the `make-absolute-paths.sh` script.
3. See the above section on **vcfanno** for running the script.


### ClinVar

ClinVar files are stored in a directory with the download date.

Downloaded from:

https://ftp.ncbi.nlm.nih.gov/pub/clinvar/vcf_GRCh38/

On 2023-06-09.

    9379313cbfdb0abb8ff7b40b0ae8d810  clinvar.vcf.gz
    9b9c76380c565b395fea00bf09681035  clinvar.vcf.gz.tbi



### genmod - rank_model_snv.ini / rank_model_sv.ini

Initially copied from the test datasets and Clinical Genomics's configs (https://github.com/Clinical-Genomics/reference-files/tree/master/rare-disease/annotation).


# DeepVariant - GPU

Using GPU on deepvariant is currently only relevant for dedicated servers where GPU resources are available
anyway (not clusters where you have to request them explicitly). The first step, `make_examples.py`, is not
able to use GPU, and will consume about as much time as the variant calling itself.

nf-core currently uses `nf-core/deepvariant:1.5.0`, but this doesn't seem to work with or without GPU.
The previous `docker.io/google/deepvariant:1.5.0` may be used.


To enable GPU, a separate docker image is used: `docker.io/google/deepvariant:1.5.0-gpu` as per
DeepVariant Quick start guide https://github.com/google/deepvariant/blob/r1.5/docs/deepvariant-quick-start.md.

To enable GPU in singularity, override the image, and sepcify `containerOptions`. See 
`medGenConfigs/nepe-settings.conf`.

```
$ docker pull docker.io/google/deepvariant:1.5.0-gpu
$ singularity build docker.io-google-deepvariant-1.5.0-gpu.img docker://docker.io/google/deepvariant:1.5.0-gpu
```
