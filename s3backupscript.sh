#!/bin/bash 
#Backup script to take backup of files and export to s3
F="my_s3_bucket"
G=`date +%D | tr "/" "-"`

# ================================== #
#Taring the splunk folder
# ================================== #

echo "Taring the splunk folder"
D=`tar -zcvf splunk-$G.tar.gz /opt/splunk`
if [ $? -ne 0 ]; then
    echo "Failed"
else
    echo "Success"
fi

# ================================== #
#Verifing the Taring status
# ================================== #

if [ $D = splunk-$G.tar.gz ]; then
echo "Taring successful"
else 
echo "Taring unsuccessful"

# ================================== #
#Creating a bucket 
# ================================== #

Bucket=`s3cmd mb s3://my-new-bucket-name`

B=`s3cmd ls s3://my-new-bucket-name`
if
[ $B = '$Bucket' ]; then
echo "Bucket successfully created"
else
echo "Bucket is not created"
fi

# ========================================= #
# Encrypting and uploading the tar.gz to S3
# ========================================= #

S=`s3cmd ls s3://my-new-bucket-name | grep splunk-$G.tar.gz`
if [ "$S" == "splunk-$G.tar.gz" ]; then
echo "uploading unsuccessful: File exist"
else
echo "Uploading the tar file to s3bucket"
s3cmd put -e /opt/splunk/splunk-$G.tar.gz s3://my-new-bucket-name/splunk-$G.tar.gz
while : ; do
echo -n ". "
sleep 1s
done &
bgid=$!
sleep 20
trap 'kill -9 "$bgid" ; exit' INT TERM EXIT
fi

# ========================================= #
# Synching the data from folder to S3
# ========================================= #

B=`s3cmd ls s3://my-new-bucket-name | grep splunk-$G.tar.gz`
if
[ $B = 'splunk-$G.tar.gz' ]; then
echo "Bucket with data is available moving on to Synching the files in S3 with the original files. Shall we proceed YES or NO"
read $proceed
if [ $proceed = yes]; then
s3cmd sync /opt/splunk s3://my-new-bucket-name/splunk-$G.tar.gz
while : ; do
echo -n ". "
sleep 1s
done &
bgid=$!
sleep 20
trap 'kill -9 "$bgid" ; exit' INT TERM EXIT
else
echo "Synching the files in S3 with the original file has been aborted"
fi

