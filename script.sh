
module load singularity/3.7.3
module load Java/11.0.2

export TMPDIR=/ess/p164/data/no-backup/active-wgs-analyses/tmp

nextflow run \
	/ess/p164/data/durable/raredisease/1.1.1/nf-core-raredisease_1.1.1/1_1_1 \
	-c /ess/p164/data/durable/raredisease/1.1.1/medGenConfigs/process-overrides.conf \
	-c /ess/p164/data/durable/raredisease/1.1.1/medGenConfigs/tsd-settings.conf \
	-params-file /ess/p164/data/durable/raredisease/1.1.1/medGenConfigs/grch38-params.yaml \
	--input samples.csv \
	--outdir output \
	--max_memory '500 GB' \
	--max_cpus 64 \
	-profile singularity \
	-w /ess/p164/data/no-backup/active-wgs-analyses/$( basename $PWD ) \
	-resume

