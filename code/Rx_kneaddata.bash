cat Rx_kneaddata.bash 
#!/usr/bin/env bash

DATE=`date +%Y-%m-%d`
TIME=`date +%H:%M`
DT=`date +%Y%m%d-%H%M`
STARTDT=$(date +"%Y-%m-%d-%H:%M:%S")

mkdir -p LOG
mkdir -p kneaddata_summary_tables

LOG_FILE=QC_w_Kneaddata_$DT.log
# LOG_FILE=QC_w_Kneaddata_20210903-1003.log
exec 1>>LOG/${LOG_FILE}
exec 2>>LOG/${LOG_FILE}

START=`date +%s`

echo ""
echo "This Task Started at: $STARTDT" 
echo "########################"
echo ""

echo ""
echo "Check the status of this task in a logfile named $LOG_FILE"
echo ""
#-------------------------

echo "Loading rawdata Data"
aws s3 sync s3://alphabiomics-rxselex-development-data/repeatability_AUG2021/DNA_standard_D6311/ RxSelex_temp/standard_Sept2021/

# echo "Resizing the test dataset...please wait..."
# mkdir standard_Sept2021

# for i in {101..110}
#   do
#     gzcat rawdata/S$i\_R1.fastq.gz \
#     | seqkit sample -p 0.1 \
#     | seqkit shuffle -o subsamples/S$i\_R1_sub.fastq.gz \
#     | gzcat rawdata/S$i\_R2.fastq.gz \
#     | seqkit sample -p 0.1 \
#     | seqkit shuffle -o subsamples/S$i\_R2_sub.fastq.gz
#   done


echo ""
echo ""
echo "Checking quality of rawreads in progress...please wait!" 1>&2
echo ""

# Run the bmtagger.bash from where the fastq files are place
echo ""
echo ""
#-------------------------
echo "FastQC 1: FastQC only"
-------------------------


for i in RxSelex_temp/standard_Sept2021/*_R1_001.fastq.gz; 
  do 
    time kneaddata \
    --i $i \
    -o RxSelex_temp/kneaddata_FastQC1 \
    --run-fastqc-start \
    --bypass-trim \
    --bypass-trf \
    --sequencer-source "none" \
    -t 4; 
    aws s3 sync RxSelex_temp/kneaddata_FastQC1  s3://alphabiomics-rxselex-development-data/repeatability_AUG2021/DNA_standard_D6311/standard_Sept2021/kneaddata_FastQC1;
    cp RxSelex_temp/kneaddata_FastQC1/*_kneaddata.log LOG;
    rm -rf RxSelex_temp/kneaddata_FastQC1;
  done

# # mrdir -p Troubleshooting
# # echo "client_loop: send disconnect: Broken pipe" >Troubleshooring/errors_encoutered.log
# # echo "Failed to retrieve Elastic IP addresses" >>eTroubleshooring/rrors_encoutered.log

# In case of error exit
if [ "$?" != "0" ]; then
  echo ""
    echo "[Error] Sorry! FastQC 1 failed. Please review the parameters and try again, exiting...!"  1>&2
    exit 1
fi



# # # MultiQC
# # mkdir -p kneaddata_FastQC1/MultiQC1
# # for i in kneaddata_FastQC1/fastqc
# #     do  
# #         multiqc -f --data-dir $i -o RxSelex_temp/kneaddata_FastQC1/MultiQC1 --export
# #     done

# # In case of error exit
# if [ "$?" != "0" ]; then
#   echo ""
#     echo "[Error] Sorry! FastQC 1 failed. Please review the parameters and try again, exiting...!"  1>&2
#     exit 1
# fi

# echo ""
# echo ""
# echo "Summary of FastQ1" 1>&2
# echo ""
# echo ""
# kneaddata_read_count_table \
#   --input kneaddata_FastQC1 \
#   --output kneaddata_summary_tables/kneaddata_read_counts_FastQC1.txt



# # In case of error exit
# if [ "$?" != "0" ]; then
#   echo ""
#     echo "[Error] Sorry! FastQC 1 summary failed. Please review the parameters and try again, exiting...!"  1>&2
#     exit 1
# fi

echo ""
echo ""
#-------------------------
echo "FastQC 2: Trimming only"
#-------------------------

echo ""
echo ""
echo "Read trimming with Trimmomatic in progress...please wait!" 1>&2
echo ""


# for i in rawdata/S*R1*.fastq.gz

for i in RxSelex_temp/standard_Sept2021/*_R1_001.fastq.gz; 
  do 
    time kneaddata \
    --i $i \
    -o RxSelex_temp/kneaddata_FastQC2 \
    --trimmomatic /home/ec2-user/miniconda3/envs/biobakery3/bin/ \
    --trimmomatic-options "ILLUMINACLIP:/Volumes/SeagateTMB/trimmomatic-0.36/adapters/NexteraPE-PE.fa:2:30:10 LEADING:3 TRAILING:3 SLIDINGWINDOW:4:20 MINLEN:60" \
    --sequencer-source "NexteraPE" \
    --run-fastqc-end \
    --bypass-trf \
    -t 4; 
    aws s3 sync RxSelex_temp/kneaddata_FastQC2  s3://alphabiomics-rxselex-development-data/repeatability_AUG2021/DNA_standard_D6311/standard_Sept2021/kneaddata_FastQC2;
    cp RxSelex_temp/kneaddata_FastQC2/*_kneaddata.log LOG;
    rm -rf RxSelex_temp/kneaddata_FastQC2;
  done


# aws s3 sync RxSelex_temp/standard_Sept2021/kneaddata_FastQC2  s3://alphabiomics-rxselex-development-data/repeatability_AUG2021/DNA_standard_D6311/standard_Sept2021/kneaddata_FastQC2

# In case of error exit
if [ "$?" != "0" ]; then
  echo ""
    echo "[Error] Sorry! FastQC 2. Please review the parameters and try again, exiting...!"  1>&2
    exit 1
fi


# rm -rf RxSelex_temp/standard_Sept2021/kneaddata_FastQC2

# # In case of error exit
# if [ "$?" != "0" ]; then
#   echo ""
#     echo "[Error] Sorry! emptying the folder failed. Please review and try again, exiting...!"  1>&2
#     exit 1
# fi




# # # MultiQC
# # mkdir -p kneaddata_FastQC2/MultiQC2
# # for i in kneaddata_FastQC2/fastqc
# #     do  
# #         multiqc -f --data-dir $i -o RxSelex_temp/standard_Sept2021/kneaddata_FastQC2/MultiQC2 --export
# #     done


# # In case of error exit
# if [ "$?" != "0" ]; then
#   echo ""
#     echo "[Error] Sorry! FastQC 2 failed. Please review the parameters and try again, exiting...!"  1>&2
#     exit 1
# fi

# # echo ""
# # echo ""
# # echo "Summary of FastQC2" 1>&2
# # echo ""
# # echo ""
# # kneaddata_read_count_table \
# #   --input kneaddata_FastQC2 \
# #   --output kneaddata_summary_tables/kneaddata_read_counts_FastQC2.txt


# # # In case of error exit
# # if [ "$?" != "0" ]; then
# #   echo ""
# #     echo "[Error] Sorry! FastQC 2 summary failed. Please review the parameters and try again, exiting...!"  1>&2
# #     exit 1
# # fi


# # echo ""
# # echo ""
# # #-------------------------
# # echo "FastQC 3: Combo QC using bowtie2 reference database"
# # #-------------------------

# # echo ""
# # echo ""
# # echo "Removing contaminants using bmtagger in progress...please wait!" 1>&2
# # echo ""


# # # for i in rawdata/S*R1*.fastq.gz
# # for i in {*_R1_001.fastq.gz}
# # do
# # time kneaddata --i RxSelex_temp/standard_Sept2021/$i \
# # -o RxSelex_temp/standard_Sept2021/kneaddata_FastQC3 \
# #     --reference-db /Volumes/SeagateTMB/kneaddata_database/ \
# #     --trimmomatic /Users/tmbuza/opt/anaconda3/envs/biobakery3/bin/ \
# #     --trimmomatic-options "ILLUMINACLIP:/Volumes/SeagateTMB/trimmomatic-0.36/adapters/NexteraPE-PE.fa:2:30:10 LEADING:3 TRAILING:3 SLIDINGWINDOW:4:20 MINLEN:60" \
# #     --sequencer-source "NexteraPE" \
# #     --run-trf \
# #     --run-fastqc-end \
# #     -t 4 
# # done


# # # MultiQC
# # mkdir -p kneaddata_FastQC3/MultiQC3
# # for i in kneaddata_FastQC3/fastqc
# #     do  
# #         multiqc -f --data-dir $i -o RxSelex_temp/standard_Sept2021/kneaddata_FastQC3/MultiQC3 --export
# #     done



# # # In case of error exit
# # if [ "$?" != "0" ]; then
# #   echo ""
# #     echo "[Error] Sorry! FastQC 3 failed. Please review the parameters and try again, exiting...!"  1>&2
# #     exit 1
# # fi


# # echo ""
# # echo ""
# # echo "Summary of FastQC3" 1>&2
# # echo ""
# # echo ""
# # kneaddata_read_count_table \
# #   --input kneaddata_FastQC3 \
# #   --output kneaddata_summary_tables/kneaddata_read_counts_FastQC3.txt


# # # In case of error exit
# # if [ "$?" != "0" ]; then
# #   echo ""
# #     echo "[Error] Sorry! FastQC 3 summary failed. Please review the parameters and try again, exiting...!"  1>&2
# #     exit 1
# # fi

# echo ""
# echo ""
#-------------------------
echo "FastQC 4: Combo QC using BMTagger reference database" 
#-------------------------

echo ""
echo ""
echo "Combo QC in progress...please wait!" 1>&2
echo ""


for i in RxSelex_temp/standard_Sept2021/*_R1_001.fastq.gz; 
  do 
    time kneaddata \
    --i $i \
    -o RxSelex_temp/kneaddata_FastQC3 \
    --reference-db /home/ec2-user/RxSelex/BMTagger/ \
    --trimmomatic /home/ec2-user/miniconda3/envs/biobakery3/bin/ \
    --trimmomatic-options "ILLUMINACLIP:/Volumes/SeagateTMB/trimmomatic-0.36/adapters/NexteraPE-PE.fa:2:30:10 LEADING:3 TRAILING:3 SLIDINGWINDOW:4:20 MINLEN:60" \
    --sequencer-source "NexteraPE" \
    --bypass-trf \
    --run-bmtagger \
    --bmtagger /home/ec2-user/miniconda3/envs/biobakery3/bin/ \
    --run-fastqc-end \
    -t 4; 
    aws s3 sync RxSelex_temp/kneaddata_FastQC3  s3://alphabiomics-rxselex-development-data/repeatability_AUG2021/DNA_standard_D6311/standard_Sept2021/kneaddata_FastQC3;
    cp RxSelex_temp/kneaddata_FastQC3/*_kneaddata.log LOG;
    rm -rf RxSelex_temp/kneaddata_FastQC3;
  done


# aws s3 sync RxSelex_temp/standard_Sept2021/kneaddata_FastQC4  s3://alphabiomics-rxselex-development-data/repeatability_AUG2021/DNA_standard_D6311/standard_Sept2021/kneaddata_FastQC4

# In case of error exit
if [ "$?" != "0" ]; then
  echo ""
    echo "[Error] Sorry! FastQC 3 failed. Please review the parameters and try again, exiting...!"  1>&2
    exit 1
fi


# rm -rf RxSelex_temp/standard_Sept2021/kneaddata_FastQC4

# # # MultiQC
# # mkdir -p kneaddata_FastQC4/MultiQC4
# # for i in kneaddata_FastQC4/fastqc
# #     do  
# #         multiqc -f --data-dir $i -o RxSelex_temp/standard_Sept2021/kneaddata_FastQC4/MultiQC4 --export
# #     done



# # In case of error exit
# if [ "$?" != "0" ]; then
#   echo ""
#     echo "[Error] Sorry! FastQC 4 failed. Please review the parameters and try again, exiting...!"  1>&2
#     exit 1
# fi



# # echo ""
# # echo ""
# # echo "Summary of FastQC4" 1>&2
# # echo ""
# # echo ""
# # kneaddata_read_count_table \
# #   --input kneaddata_FastQC4 \
# #   --output kneaddata_summary_tables/kneaddata_read_counts_FastQC4.txt


# # # In case of error exit
# # if [ "$?" != "0" ]; then
# #   echo ""
# #     echo "[Error] Sorry! FastQC 4 summary failed. Please review the parameters and try again, exiting...!"  1>&2
# #     exit 1
# # fi


# # #-------------------------
# # echo ""
# # echo ""
# # echo "Summarizing everything in python...please wait"

# # python code/kneaddata_csv_summary_tables.py

# # #-------------------------
# # #-------------------------
# # echo ""
# # echo ""

# # python code/fastqc_csv_status.py

# #-------------------------
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

