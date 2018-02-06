#!/bin/bash

ORG=juco

# Extract username and email from command line
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
mail_content=${GEN_DIR}/${NAME}.txt
uuid=$(cat $GEN_DIR/$NAME.uuid)
ip=$(ifconfig wlan0 | grep -w inet | sed 's/.*inet //' | sed 's/\s*netmask.*//')
echo "# Configure task warrior:" > ${mail_content}
echo "task config taskd.credentials -- ${ORG}/${NAME}/${uuid}" >> ${mail_content}
echo "task config taskd.ca -- ~/.task/ca.cert.pem" >> ${mail_content}
echo "task config taskd.certificate -- ~/.task/${NAME}.cert.pem" >> ${mail_content}
echo "task config taskd.key -- ~/.task/${NAME}.key.pem" >> ${mail_content}
echo "task config taskd.server -- ${ip}:53589" >> ${mail_content}
echo "task config taskd.trust -- ignore hostname" >> ${mail_content}

echo "" >> ${mail_content}
echo "# Delete user" >> ${mail_content}
echo "sudo -u Debian-taskd taskd remove --data /var/lib/taskd  user juco $uuid" >> ${mail_content}

cd ../
tar czvf $NAME.tar.gz $NAME
sendemail.py "taskwarrior server config" ${mail_content} ${EMAIL} ${EMAIL} --attach ${NAME}.tar.gz
