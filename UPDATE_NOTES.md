# Updated reference data and config files

# 2024-12-dev to 2.6.0


## Added mobile element reference

See info: scripts/mobile_elements.md





# 1.1.1 to 2024-12-dev

A dev version from not long after 2.2.0 was used for some period, due to problems with the 2.2.0 release.

## Using new version of available resources

### gnomAD 4.1 Short variants

gsutil cp  gs://gcp-public-data--gnomad/release/4.1/vcf/joint/* .

gnomAD scripts updated and ran again:

 * make-gnomad-af-file.sh
 * convert-gnomad-to-csv.sh

The annotations in gnomAD now contain joint allele frequencies with both WES and WGS. The VCF fields added by vcfanno are
now named: gnomadAF_joint, gnomadAF_joint_grpmax, gnomadAF_genomes. The grpmax field is the AF in the genetic ancestry group
with the highest AF. vcfanno_config.toml and vcfanno_resources_template.txt updated with new gnomAD.

New resource files:

- gnomad.joint.v4.1.sites.af.vcf.bgz
- gnomad.joint.v4.1.sites.af.vcf.bgz.tbi
- gnomad.joint.v4.1.af.tab.gz

There is no new gnomAD for chrM.


### gnomAD SV

gnomAD SV has been updated from gnomAD 2 to 4.1. See README file for the dataset used.


### CADD-v1.7 -- NOT USED

I was not able to get it to work. Staying on version 1.6.post1.

	- Downloaded pre-scored SNP vcf files https://kircherlab.bihealth.org/download/CADD/v1.7/GRCh38/whole_genome_SNVs.tsv.gz
	- Updated vcfanno_resources.txt to point to CADD 1.7 SNP files
	- vcfanno config is changed to report the "max" CADD score for a site instead of "mean". It probably won't make a difference because there will only be one CADD score per variant.
	- Downloaded annotation data for off-line use: https://kircherlab.bihealth.org/download/CADD/v1.7/GRCh38/GRCh38_v1.7.tar.gz
	- (TODO= Updating CADD itself)


### variant_catalog_grch38.json

Downloaded https://raw.githubusercontent.com/Clinical-Genomics/reference-files/master/rare-disease/disease_loci/ExpansionHunter-v5.0.0/variant_catalog_grch38.json
on 2024-04-15, commit 648e527.


### VEP cache updated from 107 to 110

See also below about how the files were restructured due to pipeline changes.
New VEP cache is downloaded. See README file.


### ClinVar

ClinVar was updated on 2024-09-19, by downloading the current clinvar files.


### spliceAI

The same SpiceAI files are used.


## Updating or adding files due to pipeline changes

* variant_consequences_v2.txt (new required file)

https://github.com/nf-core/test-datasets/blob/raredisease/reference/variant_consequences_v2.txt


* mobile_element_svdb_annotations: No ref data were downloaded for this yet,
  the gnomad SV files were used instead.

* vep plugin files moved from vep_cache to vep_files:

    LoFtool_scores.txt, pLI_values.txt, spliceai*.

    New file vep_files_template.csv created (instanciable with make-absolute-paths.sh)

* nextflow updated to 24.04.4 (TODO confirm version in prod)
