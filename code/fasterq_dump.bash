#!/usr/bin/env bash

# # Install SRA Toolkit

# # Navigate to where you want to install the tools
# curl -LO  https://ftp-trace.ncbi.nlm.nih.gov/sra/sdk/3.0.0/sratoolkit.3.0.0-mac64.tar.gz
# tar -xf sratoolkit.3.0.0-mac64.tar.gz

# # You may soft link the two main executable files we want 
# ln -s sratoolkit.3.0.0-mac64/bin/vdb-config vdb-config
# ln -s sratoolkit.3.0.0-mac64/bin/fasterq-dump fasterq-dump

# # Configure the Cache
# mkdir -p ~/ncbi
# echo '/repository/user/main/public/root = "/Volumes/SeagateTMB/SRA/BUSHMEAT/SRR7450"' > ~/ncbi/user-settings.mkfg

# # Confirm and save the Cache
# ./vdb-config -i

time for i in 08 11 12 15 19 24 36 40 48 06 07 13 16 18 23 25 27 35 49 50;
	do
		time fasterq-dump SRR74507$i \
		-O SRA \
		-t tmpfiles \
		--threads 6 \
		--split-3;
	done