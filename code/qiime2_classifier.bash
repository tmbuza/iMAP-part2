wget \
-O "silva.seed_v138_1.tgz" \
"https://mothur.s3.us-east-2.amazonaws.com/wiki/silva.seed_v138_1.tgz"
tar xvzf "silva.seed_v138_1.tgz"
rm *.tgz

# QIIME2 Greengenes classifier
wget \
  -O "gg-13-8-99-515-806-nb-classifier.qza" \
  "https://data.qiime2.org/2022.2/common/gg-13-8-99-515-806-nb-classifier.qza"

if [ "$?" != "0" ]; then
    echo "[Error] Sorry, download failed, exiting...,!" 1>&2
    exit 1
fi