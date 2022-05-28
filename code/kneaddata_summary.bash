#!/usr/bin/env bash

# echo "Getting summary of kneaddata bowtie2 & bmtagger contaminants"
mkdir -p kneaddata_out_bowtie2
kneaddata_read_count_table \
	--input kneaddata_out_bowtie2 \
	--output kneaddata_out_bowtie2/kneaddata_read_counts_bowtie2.txt

echo ""

mkdir -p kneaddata_out_bmtagger
kneaddata_read_count_table \
	--input kneaddata_out_bmtagger \
	--output kneaddata_out_bmtagger/kneaddata_read_counts_bmtagger.txt



mkdir -p /Volumes/SeagateTMB/knead_data
mkdir -p /Volumes/SeagateTMB/knead_data/bowtie2_clean
cp kneaddata_out_bowtie2/*_kneaddata.fastq /Volumes/SeagateTMB/knead_data/bowtie2_clean
for fname in /Volumes/SeagateTMB/knead_data/bowtie2_clean/*_kneaddata.fastq ; do mv "$fname" "$(echo "$fname" | sed -r 's/_kneaddata//')" ; done
for i in /Volumes/SeagateTMB/knead_data/bowtie2_clean/*fastq; do gzip -f  $i; done



mkdir -p /Volumes/SeagateTMB/knead_data
mkdir -p /Volumes/SeagateTMB/knead_data/bmtagger_clean
cp kneaddata_out_bowtie2/*_kneaddata.fastq /Volumes/SeagateTMB/knead_data/bmtagger_clean
for fname in /Volumes/SeagateTMB/knead_data/bmtagger_clean/*_kneaddata.fastq ; do mv "$fname" "$(echo "$fname" | sed -r 's/_kneaddata//')" ; done
for i in /Volumes/SeagateTMB/knead_data/bmtagger_clean/*fastq; do gzip -f  $i; done

# In case of error exit
if [ "$?" != "0" ]; then
  echo ""
    echo "[Error] Sorry! Kneaddata summary failed. Please review the parameters and try again, exiting...!"
    exit 1
fi
