#!/env qiime

DATE=`date +%Y-%m-%d`
TIME=`date +%H:%M`
DT=`date +%Y%m%d-%H%M`
STARTDT=$(date +"%Y-%m-%d-%H:%M:%S")

mkdir -p LOG
mkdir -p qiime2_bushmeat

LOG_FILE=qiime2_workflow_$DT.logfile
exec 1>>LOG/${LOG_FILE}
exec 2>>LOG/${LOG_FILE}

START=`date +%s`


echo ""
echo "QIIME2 analysis started at: $STARTDT"
echo ""

echo ""
echo "Check the status of this task in a logfile named $LOG_FILE"
echo ""
#-------------------------

## Prerequisites
# A simple demo for installing qiime2 on Mac OS.
wget https://data.qiime2.org/distro/core/qiime2-2022.2-py38-osx-conda.yml
conda env create -n qiime2-2022.2 --file qiime2-2022.2-py38-osx-conda.yml
rm qiime2-2022.2-py39-osx-conda.yml

# # Activate qiime environment
conda activate qiime2-2022.2

# # Confirm installation
qiime info

echo ""
echo "Metadata validation "
echo ""

## Inspect metadata
qiime tools inspect-metadata \
  $PWD/q2-metadata.tsv

## Tabulate metadata in QIIME2 format
qiime metadata tabulate \
  --m-input-file $PWD/q2-metadata.tsv \
  --o-visualization $PWD/qiime2_bushmeat/sample-metadata.qzv

## Visualizing tabulated metadata
# qiime tools view $PWD/qiime2_bushmeat/sample-metadata.qzv


echo "Importing fastq files to qiime2 environment..."

qiime tools import \
  --type 'SampleData[PairedEndSequencesWithQuality]' \
  --input-path $PWD/pe-33-manifest.tsv \
  --output-path $PWD/qiime2_bushmeat/demux.qza \
  --input-format PairedEndFastqManifestPhred33V2

echo "Summarizing preliminary analysis"
time qiime demux summarize \
  --i-data $PWD/qiime2_bushmeat/demux.qza \
  --o-visualization $PWD/qiime2_bushmeat/demux.qzv


## Visualizing preliminary analysis
qiime tools view $PWD/qiime2_bushmeat/demux.qzv

# > Review and pick truncation parameters if needed

echo ""
echo "Quality control with DADA2 in progress, please be patient, it may take a while... "
echo ""

time qiime dada2 denoise-paired \
  --i-demultiplexed-seqs $PWD/qiime2_bushmeat/demux.qza \
  --p-trim-left-f 0 \
  --p-trunc-len-f 0 \
  --p-trim-left-r 0 \
  --p-trunc-len-r 0 \
  --o-representative-sequences $PWD/qiime2_bushmeat/rep-seqs.qza \
  --o-table $PWD/qiime2_bushmeat/feature-table.qza \
  --o-denoising-stats $PWD/qiime2_bushmeat/stats.qza

echo "Summarizing denoise statistics"
qiime metadata tabulate \
  --m-input-file $PWD/qiime2_bushmeat/stats.qza \
  --o-visualization $PWD/qiime2_bushmeat/stats.qzv

## Visualizing denoise statistics
qiime tools view $PWD/qiime2_bushmeat/stats.qzv


echo ""
echo "Visualizing denoise statistics"
echo ""
qiime metadata tabulate \
  --m-input-file $PWD/qiime2_bushmeat/stats.qza \
  --o-visualization $PWD/qiime2_bushmeat/stats.qzv


echo ""
echo "Visualizing feature (sample & seqs) table"
echo ""
qiime feature-table summarize \
  --i-table $PWD/qiime2_bushmeat/feature-table.qza \
  --o-visualization $PWD/qiime2_bushmeat/feature-table.qzv \
  --m-sample-metadata-file $PWD/q2-metadata.tsv

echo ""
echo "Visualizing representative sequences"
echo ""
qiime feature-table tabulate-seqs \
  --i-data $PWD/qiime2_bushmeat/rep-seqs.qza \
  --o-visualization $PWD/qiime2_bushmeat/rep-seqs.qzv

echo ""
echo "Clustering sequences into OTUs"
echo ""


echo "De novo clustering"
# Sequences are clustered against one another. Here the clustering is performed at 99% to create 99% OTUs.
qiime vsearch cluster-features-de-novo \
  --i-table $PWD/qiime2_bushmeat/feature-table.qza \
  --i-sequences $PWD/qiime2_bushmeat/rep-seqs.qza \
  --p-perc-identity 0.99 \
  --o-clustered-table $PWD/qiime2_bushmeat/feature-table-dn-99.qza \
  --o-clustered-sequences $PWD/qiime2_bushmeat/rep-seqs-dn-99.qza

echo ""
echo "Visualizing denovo 99%"
echo ""
qiime feature-table tabulate-seqs \
  --i-data $PWD/qiime2_bushmeat/rep-seqs-dn-99.qza \
  --o-visualization $PWD/qiime2_bushmeat/rep-seqs-dn-99.qzv

echo ""
echo "Closed-reference clustering"
# Here the clustering is performed at 99% identity against the Greengenes 13_8 99% OTUs reference database.
qiime vsearch cluster-features-closed-reference \
  --i-table $PWD/qiime2_bushmeat/feature-table.qza \
  --i-sequences $PWD/qiime2_bushmeat/rep-seqs.qza \
  --i-reference-sequences $PWD/qiime2_bushmeat/rep-seqs-dn-99.qza \
  --p-perc-identity 0.99 \
  --o-clustered-table $PWD/qiime2_bushmeat/feature-table-cr-99.qza \
  --o-clustered-sequences $PWD/qiime2_bushmeat/rep-seqs-cr-99.qza \
  --o-unmatched-sequences $PWD/qiime2_bushmeat/unmatched-cr-99.qza

echo ""
echo "Open-reference clustering"
# Here the clustering is performed at 99% identity against the Greengenes 13_8 99% OTUs reference database.
qiime vsearch cluster-features-open-reference \
  --i-table $PWD/qiime2_bushmeat/feature-table.qza \
  --i-sequences $PWD/qiime2_bushmeat/rep-seqs.qza \
  --i-reference-sequences $PWD/qiime2_bushmeat/rep-seqs-dn-99.qza \
  --p-perc-identity 0.99 \
  --o-clustered-table $PWD/qiime2_bushmeat/feature-table-or-99.qza \
  --o-clustered-sequences $PWD/qiime2_bushmeat/rep-seqs-or-99.qza \
  --o-new-reference-sequences $PWD/qiime2_bushmeat/new-ref-seqs-or-99.qza


echo ""
echo "Performing de novo multiple sequence alignment of representative sequences using MAFFT " 
echo ""

qiime alignment mafft \
  --i-sequences $PWD/qiime2_bushmeat/rep-seqs.qza \
  --o-alignment $PWD/qiime2_bushmeat/aligned-rep-seqs.qza

echo ""
echo "Removing poor alignment" 
echo ""

qiime alignment mask \
  --i-alignment $PWD/qiime2_bushmeat/aligned-rep-seqs.qza \
  --o-masked-alignment $PWD/qiime2_bushmeat/masked-aligned-rep-seqs.qza

echo ""
echo "Visualizing masked alignments"
echo ""
qiime feature-table tabulate-seqs \
  --i-data $PWD/qiime2_bushmeat/masked-aligned-rep-seqs.qza \
  --o-visualization $PWD/qiime2_bushmeat/masked-aligned-rep-seqs.qzv


echo ""
echo "Phylogenetic sequence clustering" 
echo ""

echo "Unrooted tree"
echo ""
qiime phylogeny fasttree \
  --i-alignment $PWD/qiime2_bushmeat/masked-aligned-rep-seqs.qza \
  --o-tree $PWD/qiime2_bushmeat/unrooted-tree.qza

echo ""
echo "Rooted tree"
echo ""
qiime phylogeny midpoint-root \
  --i-tree $PWD/qiime2_bushmeat/unrooted-tree.qza \
  --o-rooted-tree $PWD/qiime2_bushmeat/rooted-tree.qza


echo ""
echo "Taxonomic assignment to masked aligned representative sequences"
echo ""

## Using Greengenes 2013-8-99-515-806-nb

time qiime feature-classifier classify-sklearn \
  --i-classifier $PWD/gg-13-8-99-515-806-nb-classifier.qza \
  --i-reads $PWD/qiime2_bushmeat/rep-seqs-dn-99.qza \
  --o-classification $PWD/qiime2_bushmeat/taxonomy.qza


### Visualizing taxonomy classification
qiime metadata tabulate \
  --m-input-file $PWD/qiime2_bushmeat/taxonomy.qza \
  --o-visualization $PWD/qiime2_bushmeat/taxonomy.qzv

echo ""
echo "QIIME2 data transformation"
echo ""

qiime tools export \
  --input-path $PWD/qiime2_bushmeat/feature-table.qza \
  --output-path $PWD/qiime2_bushmeat/q2-transformed-tables # Output feature-table.biom 


echo ""
echo "Converting BIOM table into Tab-Separated-Values (TSV)"
echo ""

biom convert \
  -i $PWD/qiime2_bushmeat/q2-transformed-tables/feature-table.biom \
  -o $PWD/qiime2_bushmeat/q2-transformed-tables/feature-table.tsv --to-tsv
  
qiime tools export \
  --input-path $PWD/qiime2_bushmeat/taxonomy.qza \
  --output-path $PWD/qiime2_bushmeat/q2-transformed-tables # Output taxonomy.tsv


echo ""
echo "Combining fetature table with taxonomy"
echo ""

qiime metadata tabulate \
  --m-input-file $PWD/qiime2_bushmeat/q2-transformed-tables/feature-table.tsv \
  --m-input-file $PWD/qiime2_bushmeat/q2-transformed-tables/taxonomy.tsv \
  --o-visualization $PWD/qiime2_bushmeat/q2-transformed-tables/feature-taxonomy-table.qzv


## Newick tree
qiime tools export \
  --input-path $PWD/qiime2_bushmeat/rooted-tree.qza \
  --output-path $PWD/qiime2_bushmeat/q2-transformed-tables/rooted-tree

qiime tools export \
  --input-path $PWD/qiime2_bushmeat/unrooted-tree.qza \
  --output-path $PWD/qiime2_bushmeat/q2-transformed-tables/unrooted-tree

#-------------------------
END=`date +%s`
RUNTIME=$(( END - START ))
RUNTIME_minutes=$((RUNTIME/60))
RUNTIME_hour=$((RUNTIME/3600))
echo "Summary report"


echo ""
echo "Time taken to complete this task"
echo "$RUNTIME seconds"
echo "$RUNTIME_minutes minutes"
echo "$RUNTIME_hour hours"

echo ""
echo "DONE!"

