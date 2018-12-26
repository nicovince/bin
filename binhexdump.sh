#!/bin/bash
# Create hexdump of file and save it with .hex suffix
BINFILE=$1
OUTFILE=${BINFILE}.hex

hexdump -C ${BINFILE} > ${OUTFILE}
