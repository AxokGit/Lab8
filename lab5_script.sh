#!/bin/bash

echo ""
echo "Welcome to the pre-requirements lab5 script"
echo "This script is about to run all the necessary commands of lab5 for starting the lab8"
read -p "Do you want to proceed? (yes/no) " yn

case $yn in 
	yes ) echo "[INFO] Creating user iotlab";;
	no ) echo "Exiting...";
		exit;;
	* ) echo invalid response;
		exit 1;;
esac


adduser iotlab --gecos "IoTLab,,," --disabled-password > /dev/null 2>&1
echo "iotlab:iotlab2022" | chpasswd

echo "[INFO] Updating and upgrading packages"
apt update  > /dev/null 2>&1 && apt -y upgrade > /dev/null 2>&1

echo "[INFO] Installing sudo"
apt install sudo > /dev/null 2>&1

echo "[INFO] Adding user iotlab to sudo group"
usermod -aG sudo iotlab

echo "[INFO] Installing nano openssl"
sudo apt -y install nano openssl > /dev/null 2>&1

echo "[INFO] Creation PKI folder under /home/iotlab"
sudo -u iotlab mkdir /home/iotlab/PKI
cd /home/iotlab/PKI

echo "[INFO] Downloading file pki-openssl-sample.conf"
sudo -u iotlab wget https://raw.githubusercontent.com/AxokGit/Lab8/main/pki-openssl-sample.conf > /dev/null 2>&1
sudo -u iotlab cp pki-openssl-sample.conf pki-openssl.conf

echo "[INFO] Applying file pki-openssl.conf"
export OPENSSL_CONF=/home/iotlab/PKI/pki-openssl.conf

echo "[INFO] Creating folder structure for RootCA"
sudo -u iotlab mkdir RootCA
cd RootCA
sudo -u iotlab mkdir certs reqs crl private
chmod 700 private
sudo -u iotlab touch index.txt

echo "[INFO] Generating private key for RootCA"
sudo -u iotlab openssl genpkey -des3 -algorithm RSA -out private/root-ca.key -pass pass:iotlab2022 > /dev/null 2>&1

echo "[INFO] Generating self-signed certificate for RootCA"
sudo -u iotlab openssl req -new -x509 -key private/root-ca.key -out certs/root-ca.crt -passin pass:iotlab2022 \
-subj "/C=DE/ST=Hessen/L=Giessen/O=Global Trust/CN=Global Trust Root CA" > /dev/null 2>&1

echo "[INFO] Creating folder structure for HTBCA"
cd /home/iotlab/PKI
mkdir HTBCA
cd HTBCA
mkdir certs reqs crl private
chmod 700 private
touch index.txt

echo "[INFO] Generating private key for HTBCA"
openssl genpkey -des3 -algorithm RSA -out private/htb-ca.key -pass pass:iotlab2022 > /dev/null 2>&1

echo "[INFO] Generating certificate request for HTBCA"
openssl req -new -key private/htb-ca.key -out htb-ca.csr -passin pass:iotlab2022 \
-subj "/C=DE/ST=Hessen/L=Giessen/O=Hightech-Biz/CN=Hightech-Biz CA" > /dev/null 2>&1

echo "[INFO] Moving certificate request to RootCA reqs folder"
mv htb-ca.csr ../RootCA/reqs
cd ../RootCA

echo "[INFO] Signing certificate request of HTBCA with RootCA"
openssl x509 -req -extensions ca_cert -in reqs/htb-ca.csr -CA certs/root-ca.crt -CAkey private/root-ca.key \
-CAcreateserial -out htb-ca.crt -days 365 -extfile ../pki-openssl.conf -passin pass:iotlab2022 > /dev/null 2>&1

echo "[INFO] Moving certificate back to HTBCA certs folder"
mv htb-ca.crt ../HTBCA/certs/
cd ../HTBCA/certs/

echo "[INFO] Generating certificate chain for HTBCA"
cat htb-ca.crt ../../RootCA/certs/root-ca.crt > htb-ca-chain.crt

echo ""
echo "[INFO] DONE."
echo "[INFO] Go to the directory /home/iotlab/PKI"