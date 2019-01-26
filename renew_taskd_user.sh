#!/bin/bash
# Extract username and email from command line
if [ $# -gt 1 ]; then
  NAME=$1
  EMAIL=$2
else
  echo "Usage: $0 <username> <email>"
  exit 1
fi

# Generation directory
GEN_DIR=$PWD/${NAME}_certificates
mkdir $GEN_DIR

# Generate client certificates
cd /usr/share/taskd/pki
sudo ./generate.client $NAME

# copy certificates to generation directory
sudo cp $NAME.key.pem ${GEN_DIR}
sudo cp $NAME.cert.pem ${GEN_DIR}
sudo cp ca.cert.pem ${GEN_DIR}
sudo chown $USER:$USER ${GEN_DIR}/${NAME}.key.pem
sudo chown $USER:$USER ${GEN_DIR}/${NAME}.cert.pem
sudo chown $USER:$USER ${GEN_DIR}/ca.cert.pem

cd ${GEN_DIR}/..

mail_content=${GEN_DIR}/${NAME}.txt

echo "Your certificate for taskwarrior server has been updated, see attach file" > ${mail_content}

tar czvf ${NAME}_certificates.tar.gz ${NAME}_certificates/*.pem
sendemail.py "taskwarrior certificates renewal" ${mail_content} ${EMAIL} ${EMAIL} --attach ${NAME}_certificates.tar.gz
