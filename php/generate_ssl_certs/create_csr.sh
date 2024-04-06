#!/bin/bash

#################################################################################
# Created by Roger Nem                                                          #
#                                                                               #
# Generates CSR for SSL certificates                                            #
#                                                                               #
# v0.001 - Roger Nem -  File created - Aug 2017                                 #
#################################################################################

cn=$(echo $1 | sed 's/\s//g')
sed -e 's/###commonName###/'$cn'/' template.cnf > work/$cn.cnf

i=1
for san in "$@"
do
  san=$(echo $san | sed 's/\s//g')
  echo "Adding $san"
  echo "DNS.$i=$san" >> work/$cn.cnf
  (( i++ ))
done

openssl req -new -nodes -config work/$cn.cnf -keyout repo/$cn.key -out repo/$cn.csr

#rm -f $cn.cnf