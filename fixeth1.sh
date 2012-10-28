#!/bin/bash
ifdown eth1
echo ""
echo "press Wifi button to Off and on then press Enter"
read d
ifup eth1
