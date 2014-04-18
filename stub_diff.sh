#!/bin/bash
for i in *stub.v; do
  echo $i
  diff -q $i ASIC/common/gls_stubs/$i
done
