# ovpn-conf-autogen
bash script to generate openvpn client config automatically

Usage:
./autogen.sh <client_name>
Will generate client config file in /etc/openvpn/<client_name> directory and embed all keys and certificates inside config.  
  
Before using this script you need to place template client config without any keys in /etc/openvpn/client.
