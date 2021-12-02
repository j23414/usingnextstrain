#! /usr/bin/env bash

exit   # Early exit ;)

# This script requires clade files, reference, and S gene. Not uploading the data, just the processing steps.

ARR=(alpha beta gamma delta mu lambda omicron)
#GH)

cat references_sequences.fasta > all.fa
#cat EPI_ISL_402124-S.fasta >> all.fa     # for S gene

# Rough sampling
for CLADE in "${ARR[@]}"
do
    echo "$CLADE"
    smof head -n 50 gisaid_${CLADE}.fasta | sed "s:>:>$CLADE|:g" >> all.fa
    smof tail -n 50 gisaid_${CLADE}.fasta | sed "s:>:>$CLADE|:g" >> all.fa
done

# Rough metadata
grep ">" all.fa |sed 's/>//g' | awk -F'|' 'OFS="\t" {print $0,$4,"ncov","Oceania"}' > all_metadata.tsv

#mafft --auto all.fa > all_aln.fa
#fasttree -nt all_aln.fa > all.tre
