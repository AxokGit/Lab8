#!/bin/bash

# Créer un utilisateur 'iotlab' avec le mot de passe 'iotlab2022'
adduser iotlab --gecos "IoTLab,,," --disabled-password
echo "iotlab:iotlab2022" | chpasswd

# Mettre à jour les paquets
apt update && apt -y upgrade

# Installer sudo
apt install sudo

# Ajouter l'utilisateur 'iotlab' au groupe sudo
usermod -aG sudo iotlab

# Changer d'utilisateur à 'iotlab'
# Note: Cette commande ne peut pas être exécutée dans un script. Vous devez changer manuellement après l'exécution du script
# su iotlab

# Installer des paquets nécessaires
sudo apt -y install vim nano openssl apache2 curl wget

# Vérifier la version d'OpenSSL
openssl version

# Vérifier la version d'Apache2
apache2 -v

# Créer un nouveau dossier 'PKI' dans le répertoire personnel de 'iotlab'
sudo -u iotlab mkdir /home/iotlab/PKI

# Aller dans le dossier 'PKI'
cd /home/iotlab/PKI

# Télécharger le fichier de configuration OpenSSL
sudo -u iotlab wget https://raw.githubusercontent.com/AxokGit/Lab8/main/pki-openssl-sample.conf

# Dupliquer le fichier de configuration
sudo -u iotlab cp pki-openssl-sample.conf pki-openssl.conf

# Définir le fichier de paramètre pour OpenSSL
export OPENSSL_CONF=/home/iotlab/PKI/pki-openssl.conf

# Créer un dossier 'RootCA' et aller dedans
sudo -u iotlab mkdir RootCA
cd RootCA

# Créer la structure de dossiers pour le CA
sudo -u iotlab mkdir certs reqs crl private

# Définir les permissions pour le dossier 'private'
chmod 700 private

# Créer un fichier 'index.txt'
sudo -u iotlab touch index.txt

# Générer une clé privée pour le CA Root
sudo -u iotlab openssl genpkey -des3 -algorithm RSA -out private/root-ca.key -pass pass:iotlab2022

# Générer un certificat self-signed pour le CA Root avec les détails spécifiés
sudo -u iotlab openssl req -new -x509 -key private/root-ca.key -out certs/root-ca.crt -passin pass:iotlab2022 \
-subj "/C=DE/ST=Hessen/L=Giessen/O=Global Trust/CN=Global Trust Root CA"

