#!/bin/bash

mkdir -p ../refData/bwamem2

singularity run  \
	-B `realpath ../refData`:/refData \
	../nf-core-raredisease-*/singularity-images/depot.galaxyproject.org-singularity-bwa-mem2-2.2.1--he513fc3_0.img \
		bwa-mem2 index /refData/Homo_sapiens/NCBI/GRCh38/Sequence/WholeGenomeFasta/genome.fa -p /refData/bwamem2/genome.fa
 
