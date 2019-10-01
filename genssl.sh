#!/usr/bin/env bash

# Copyright 2019, Thornbury Organization, Bryan Thornbury
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ "$SOURCE" != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"

set -e
set -u

CERT_HOSTNAME=gitlab.local
OUT_DIR="$DIR/data/ssl"

mkdir -p "$OUT_DIR"

CA_KEY_FILE="$OUT_DIR/$CERT_HOSTNAME-CA.key"
CA_CRT_FILE="$OUT_DIR/$CERT_HOSTNAME-CA.crt"

SERVER_KEY_FILE="$OUT_DIR/$CERT_HOSTNAME.key"
SERVER_CRT_FILE="$OUT_DIR/$CERT_HOSTNAME.crt"
SERVER_CSR_FILE="$OUT_DIR/$CERT_HOSTNAME.req"

CA_SERIAL_FILE="$OUT_DIR/$CERT_HOSTNAME-CA.serial"


# Create CA Key
openssl genrsa -out $CA_KEY_FILE 2048

# CREATE CA Cert
openssl req \
  -x509 \
  -nodes \
  -new \
  -key $CA_KEY_FILE \
  -out $CA_CRT_FILE \
  -subj /CN=$CERT_HOSTNAME-ROOT-CA \
  -sha256 \
  -days 3650

# Create Server Key
openssl genrsa -out $SERVER_KEY_FILE 4096

# assure subject alternative name is set to hostname, Chrome >= v58 requires this
(cat /etc/ssl/openssl.cnf; printf "[SAN]\nsubjectAltName=DNS:$CERT_HOSTNAME") > /tmp/$CERT_HOSTNAME-openssl.cnf

# Create CSR
openssl req \
  -new \
  -key $SERVER_KEY_FILE \
  -out $SERVER_CSR_FILE \
  -subj /CN=$CERT_HOSTNAME \
  -reqexts SAN \
  -extensions SAN \
  -config /tmp/$CERT_HOSTNAME-openssl.cnf

# Create Webserver Cert, Valid for 10 years
openssl x509 \
  -req \
  -in $SERVER_CSR_FILE \
  -out $SERVER_CRT_FILE \
  -CA $CA_CRT_FILE \
  -CAkey $CA_KEY_FILE \
  -CAcreateserial \
  -CAserial $CA_SERIAL_FILE \
  -extensions SAN \
  -extfile /tmp/$CERT_HOSTNAME-openssl.cnf \
  -sha256 \
  -days 3650
