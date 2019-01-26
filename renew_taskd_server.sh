#!/bin/bash

cd /usr/share/taskd/pki
sudo ./generate.ca
sudo ./generate.server
sudo ./generate.crl
