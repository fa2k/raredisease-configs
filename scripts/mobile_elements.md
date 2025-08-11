# Mobile elements procedure - GRCh38

1. Download the RepeatMasker table (includes patches, e.g., GRCh38.p13)

wget https://hgdownload.soe.ucsc.edu/goldenPath/hg38/database/rmsk.txt.gz
gunzip -c rmsk.txt.gz > rmsk.txt


2. Filter into separate BEDs for the TE types RetroSeq expects. Ensure sorting and dedupe (but we expect it's already sorted).

# ALU (subfamilies contain "Alu" in repName or repFamily)
awk 'BEGIN{OFS="\t"} ($13 ~ /Alu/ || $11 ~ /Alu/) {print $6, $7, $8, $13}' rmsk.txt | sort -k1,1 -k2,2n | uniq > grch38_ALU.bed

# L1 (e.g., names starting with L1, including active human L1HS)
awk 'BEGIN{OFS="\t"} $13 ~ /^L1/ {print $6, $7, $8, $13}' rmsk.txt | sort -k1,1 -k2,2n | uniq > grch38_L1.bed

# SVA
awk 'BEGIN{OFS="\t"} $13 ~ /SVA/ {print $6, $7, $8, $13}' rmsk.txt | sort -k1,1 -k2,2n | uniq > grch38_SVA.bed

# HERV: endogenous retroviruses—often annotated under ERV/HERV names
awk 'BEGIN{OFS="\t"} ($13 ~ /HERV/ || $11 ~ /ERV/ || $13 ~ /ERV/) {print $6, $7, $8, $13}' rmsk.txt | sort -k1,1 -k2,2n | uniq > grch38_HERV.bed


3. Move these files into ../../refData/mobile-elements
