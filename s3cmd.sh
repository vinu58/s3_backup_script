#!/bin/bash
#Backup script to take backup of files of splunk and export to s3
BUCKET="New_bucket_name"

CREATE_BUCKET() {  
CHECK_BUCKET=`s3cmd ls s3://$BUCKET 2>&1 | grep 'does not exist'`

if [ $? -eq 0 ] ; then
s3cmd mb s3://$BUCKET
if [ $? -eq 0 ] ; then
echo "bucket created successfully"
else
echo "bucket creation failed"
fi

else
echo "Bucket already exit"
fi

}

ENCRYPT_CONTENT() {
ENCRYPT_CONTENT=`s3cmd sync --server-side-encryption x-amz-server-side-encryption:AES256 x-amz-server-side-encryption-customer-key KEYLOCATION x-amz-server-side-encryption-customer-key-MD5 MDFCHECKSUM FOLDERTOBEUPLOADED s3://$BUCKET/LOCATION 2>&1`
if [ $? -eq 0  ]; then

echo "encryption successful"
 
else
echo "encryption failed"
fi
}

main () {
CREATE_BUCKET
ENCRYPT_CONTENT
}

main
