#!/bin/bash

# Create mandatory bed files and interval_list files, referring to the whole genome.
# Requires the reference genome dict file (iGenomes; see notes.txt)

mkdir -p ../refData/intervals
python dict-to-bed.py ../refData/Homo_sapiens/NCBI/GRCh38/Sequence/WholeGenomeFasta/genome.dict genome.dict > ../refData/intervals/wgs.bed
grep ^chrY ../refData/intervals/wgs.bed > ../refData/intervals/chrY.bed


singularity run \
	-B `realpath ../refData`:/data \
	-W /data \
	../singularity/depot.galaxyproject.org-singularity-gatk4-4.4.0.0--py36hdfd78af_0.img gatk BedToIntervalList \
		-I intervals/wgs.bed \
		-O intervals/wgs.interval_list \
		-SD Homo_sapiens/NCBI/GRCh38/Sequence/WholeGenomeFasta/genome.dict

singularity run \
	-B `realpath ../refData`:/data \
	-W /data \
	 ../singularity/depot.galaxyproject.org-singularity-gatk4-4.4.0.0--py36hdfd78af_0.img gatk BedToIntervalList \
		-I intervals/chrY.bed \
		-O intervals/chrY.interval_list \
		-SD Homo_sapiens/NCBI/GRCh38/Sequence/WholeGenomeFasta/genome.dict

