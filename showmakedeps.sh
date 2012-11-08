#!/bin/bash
make -pqs | sed -n 's/.$/& /;/\# Not a target:/N;/^[^\t#=%][^#=%]*:[^=]/p'
