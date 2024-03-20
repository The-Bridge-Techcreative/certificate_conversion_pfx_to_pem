#!/bin/bash

# Password for your PFX file
export PFX_PASSWORD="!!Certificate!!"

# Name of the PFX file to process
export PFX_FILE_IN="./vps.minara.co.tz.pfx"

export FRONT_MATTER="./celebration.txt"






# Define the name of the output key file
export KEY_FILE_OUT="${PFX_FILE_IN/.pfx/.nopassword.key}"
export PEM_FILE_UNENCRYPTED_OUT="${PFX_FILE_IN/.pfx/.pem}"

# Define the name of the output PFX file
export PFX_FILE_OUT="${PFX_FILE_IN/.pfx/.nopassword.pfx}"


echo Extracting certificate...
openssl pkcs12 -clcerts -nokeys -in "$PFX_FILE_IN" -out certificate.crt -password pass:"$PFX_PASSWORD" -passin pass:"$PFX_PASSWORD"

echo Extracting certificate authority key...
openssl pkcs12 -cacerts -nokeys -in "$PFX_FILE_IN" -out ca-cert.ca -password pass:"$PFX_PASSWORD" -passin pass:"$PFX_PASSWORD"

echo Extracting private key...
openssl pkcs12 -nocerts -in "$PFX_FILE_IN" -out private.key -password pass:"$PFX_PASSWORD" -passin pass:"$PFX_PASSWORD" -passout pass:TemporaryPassword

echo Removing passphrase from private key in file $KEY_FILE_OUT...
openssl rsa -in private.key -out "$KEY_FILE_OUT" -passin pass:TemporaryPassword

echo Building new PEM input file...
cat $FRONT_MATTER $KEY_FILE_OUT certificate.crt ca-cert.ca > $PEM_FILE_UNENCRYPTED_OUT

#echo Creating new PFX file $PFX_FILE_OUT...
#openssl pkcs12 -export -nodes -CAfile ca-cert.ca -in pfx-in.pem -passin pass:TemporaryPassword -passout pass:"" -out "$PFX_FILE_OUT"

echo Cleaning up...
rm certificate.crt ca-cert.ca private.key $KEY_FILE_OUT
