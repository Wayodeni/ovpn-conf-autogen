#!/bin/bash

CLIENT_CERTS_DIR="/etc/openvpn/client/$1"
TEMPLATE_CLIENT_CONFIG="/etc/openvpn/client/client.conf"
mkdir $CLIENT_CERTS_DIR

# Create client certificate (pubkey) request for CA and client private key
./easyrsa gen-req $1 nopass

# Copy client private key to client certs dir
cp ./pki/private/$1.key $CLIENT_CERTS_DIR

# Import request for certificate into CA. (Assuming that your CA is on the same machine)
./easyrsa import-req ./pki/reqs/$1.req $1

# Create client certificate (pubkey) from imported request
./easyrsa sign-req client $1

# Copy client pubkey to client certs dir
cp ./pki/issued/$1.crt $CLIENT_CERTS_DIR

# Copy openvpn ssl key and CA pubkey into client certs dir
cp ./pki/ta.key $CLIENT_CERTS_DIR
cp ./pki/ca.crt $CLIENT_CERTS_DIR

# Save key contents inside variables
client_privkey=$(cat $CLIENT_CERTS_DIR/$1.key)
client_pubkey=$(tac $CLIENT_CERTS_DIR/$1.crt | sed '/BEGIN CERT/q' | tac)
ca_pubkey=$(cat $CLIENT_CERTS_DIR/ca.crt)
openvpn_ssl_key=$(cat $CLIENT_CERTS_DIR/ta.key)

# Copy empty config file to client directory
cp $TEMPLATE_CLIENT_CONFIG $CLIENT_CERTS_DIR

# Rename client certificate
mv $CLIENT_CERTS_DIR/client.conf $CLIENT_CERTS_DIR/$1.conf

client_certificate_path=$CLIENT_CERTS_DIR/$1.conf

# Embed keys and certificates into client config file
echo -e "\n<key>\n$client_privkey\n</key>" >> $client_certificate_path
echo -e "\n<cert>\n$client_pubkey\n</cert>" >> $client_certificate_path
echo -e "\n<ca>\n$ca_pubkey\n</ca>" >> $client_certificate_path
echo -e "\n<tls-auth>\n$openvpn_ssl_key\n</tls-auth>" >> $client_certificate_path