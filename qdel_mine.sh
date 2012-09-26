#!/bin/bash
ids=`qstat -u "nvincent" | grep nvincent | awk '{print $1}'`
qdel $ids
