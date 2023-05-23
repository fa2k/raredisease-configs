#!/bin/bash

# Create mandatory bed files and interval_list files, referring to the whole genome.
# Requires the reference genome dict file (iGenomes; see notes.txt)

mkdir -p ../refData/intervals
python dict-to-bed.py ../refData/Homo_sapiens/NCBI/GRCh38/Sequence/WholeGenomeFasta/genome.dict genome.dict > ../refData/intervals/wgs.bed
grep ^chrY ../refData/intervals/wgs.bed > ../refData/intervals/chrY.bed


docker run -ti --rm -v `realpath ../refData`:/data -w /data -u $UID:$GID broadinstitute/gatk:4.4.0.0 gatk BedToIntervalList \
	-I intervals/wgs.bed \
	-O intervals/wgs.interval_list \
	-SD Homo_sapiens/NCBI/GRCh38/Sequence/WholeGenomeFasta/genome.dict

docker run -ti --rm -v `realpath ../refData`:/data -w /data -u $UID:$GID broadinstitute/gatk:4.4.0.0 gatk BedToIntervalList \
	-I intervals/chrY.bed \
	-O intervals/chrY.interval_list \
	-SD Homo_sapiens/NCBI/GRCh38/Sequence/WholeGenomeFasta/genome.dict



