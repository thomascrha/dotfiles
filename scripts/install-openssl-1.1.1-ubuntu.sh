#!/bin/bash

cd /usr/local/src/
sudo git clone https://github.com/openssl/openssl.git -b OpenSSL_1_1_1-stable openssl-1.1.1m
cd openssl-1.1.1m
sudo ./config --prefix=/usr/local/ssl --openssldir=/usr/local/ssl shared zlib
sudo make
sudo make test
sudo make install_sw
