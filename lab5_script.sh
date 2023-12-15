#!/bin/bash

echo ""
echo "Welcome to the pre-requirements lab5 script"
echo "This script is about to run all the necessary commands of lab5 for starting the lab8"
read -p "Do you want to proceed? (yes/no) " yn

case $yn in 
	yes ) echo ok, we will proceed;;
	no ) echo exiting...;
		exit;;
	* ) echo invalid response;
		exit 1;;
esac


adduser iotlab --gecos "IoTLab,,," --disabled-password > /dev/null 2>&1
echo "iotlab:iotlab2022" | chpasswd
apt update  > /dev/null 2>&1 && apt -y upgrade > /dev/null 2>&1
apt install sudo > /dev/null 2>&1
usermod -aG sudo iotlab
sudo apt -y install vim nano openssl apache2 curl wget > /dev/null 2>&1
openssl version
apache2 -v
sudo -u iotlab mkdir /home/iotlab/PKI
cd /home/iotlab/PKI
sudo -u iotlab wget https://raw.githubusercontent.com/AxokGit/Lab8/main/pki-openssl-sample.conf > /dev/null 2>&1
sudo -u iotlab cp pki-openssl-sample.conf pki-openssl.conf
export OPENSSL_CONF=/home/iotlab/PKI/pki-openssl.conf
sudo -u iotlab mkdir RootCA
cd RootCA
sudo -u iotlab mkdir certs reqs crl private
chmod 700 private
sudo -u iotlab touch index.txt
sudo -u iotlab openssl genpkey -des3 -algorithm RSA -out private/root-ca.key -pass pass:iotlab2022 > /dev/null 2>&1
sudo -u iotlab openssl req -new -x509 -key private/root-ca.key -out certs/root-ca.crt -passin pass:iotlab2022 \
-subj "/C=DE/ST=Hessen/L=Giessen/O=Global Trust/CN=Global Trust Root CA" > /dev/null 2>&1
cd /home/iotlab/PKI
mkdir HTBCA
cd HTBCA
mkdir certs reqs crl private
chmod 700 private
touch index.txt
openssl genpkey -des3 -algorithm RSA -out private/htb-ca.key -pass pass:iotlab2022 > /dev/null 2>&1
openssl req -new -key private/htb-ca.key -out htb-ca.csr -passin pass:iotlab2022 \
-subj "/C=DE/ST=Hessen/L=Giessen/O=Hightech-Biz/CN=Hightech-Biz CA" > /dev/null 2>&1
mv htb-ca.csr ../RootCA/reqs
cd ../RootCA
openssl x509 -req -extensions ca_cert -in reqs/htb-ca.csr -CA certs/root-ca.crt -CAkey private/root-ca.key \
-CAcreateserial -out htb-ca.crt -days 365 -extfile ../pki-openssl.conf -passin pass:iotlab2022 > /dev/null 2>&1
mv htb-ca.crt ../HTBCA/certs/
cd ../HTBCA/certs/
cat htb-ca.crt ../../RootCA/certs/root-ca.crt > htb-ca-chain.crt