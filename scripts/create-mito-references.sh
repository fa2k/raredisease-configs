#!/bin/bash

mkdir -p ../refData/mito
docker run -ti --rm -v `realpath ../refData`:/data -w /data broadinstitute/gatk:4.4.0.0 bash -c ' \
	cd mito
	samtools faidx ../Homo_sapiens/NCBI/GRCh38/Sequence/WholeGenomeFasta/genome.fa chrM > chrM.fa
	samtools faidx chrM.fa
	gatk CreateSequenceDictionary R=chrM.fa O=chrM.dict
	gatk ShiftFasta -R chrM.fa -O chrM_shifted.fa --shift-back-output chrM_shifted.shift_back.chain --shift-offset-list 5000
'
cp ../customRefData/chrM*non_control*.intervals ../refData/mito/
