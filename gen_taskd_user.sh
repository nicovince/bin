#!/bin/bash

ORG=juco

# Extract username from command line
if [ $# -gt 1 ]; then
  NAME=$1
  EMAIL=$2
else
  echo "Usage: $0 <username> <email>"
  exit 1
fi

# Generation directory
GEN_DIR=$PWD/$NAME
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

# Create task warrior user on server
cd ${GEN_DIR}
sudo -u Debian-taskd taskd add --data /var/lib/taskd user $ORG $NAME | grep "New user key" | sed 's/^.*: //' > $GEN_DIR/$NAME.uuid


# 
config=${GEN_DIR}/${NAME}.txt
uuid=$(cat $GEN_DIR/$NAME.uuid)
ip=$(ifconfig wlan0 | grep -w inet | sed 's/.*inet //' | sed 's/\s*netmask.*//')
echo "# Configure task warrior:" >> ${config}
echo "task config taskd.credentials -- ${ORG}/${NAME}/${uuid}" >> ${config}
echo "task config taskd.ca -- ~/.task/ca.cert.pem" >> ${config}
echo "task config taskd.certificate -- ~/.task/${NAME}.cert.pem" >> ${config}
echo "task config taskd.key -- ~/.task/${NAME}.key.pem" >> ${config}
echo "task config taskd.server -- ${ip}:53589" >> ${config}
echo "task config taskd.trust -- ignore hostname" >> ${config}

echo "" >> ${config}
echo "# Delete user" >> ${config}
echo "sudo -u Debian-taskd taskd remove --data /var/lib/taskd  user juco $uuid" >> ${config}

cd ../
tar czvf $NAME.tar.gz $NAME
sendemail.py "taskwarrior server config" ${config} ${EMAIL} ${EMAIL} --attach ${NAME}.tar.gz
