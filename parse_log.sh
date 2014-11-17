#!/bin/bash

LOG="cve.log"

K_FILE="tfcpOutCmd_k.log"
PATTERN_K="TfcpOutCmd_k"
grep "$PATTERN_K" -A 5 $LOG > $K_FILE
TFCP_K=`grep -c "$PATTERN_K" $K_FILE`


PAYLOAD_FILE="tfcpMonitorPayload.log"
PATTERN_PAYLOAD="Received TfcpMonitor"
grep "$PATTERN_PAYLOAD" -A 4 $LOG > $PAYLOAD_FILE
TFCP_PAYLOAD=`grep -c "$PATTERN_PAYLOAD" $PAYLOAD_FILE`

NHY_FILE="nhy_fifoId.log"
PATTERN_NHY="Use fifo id"
grep "$PATTERN_NHY" $LOG > $NHY_FILE
TFCP_NHY=`grep -c "$PATTERN_NHY" $NHY_FILE`

ERR_FILE="errors.log"
PATTERN_ERR="^Error"
grep "$PATTERN_ERR" -A 2 $LOG > $ERR_FILE
ERR_CNT=`grep -c "$PATTERN_ERR" $ERR_FILE`

echo "TfcpOutCmd_k : $TFCP_K -- $K_FILE"
echo "TfcpMonitorPayload : $TFCP_PAYLOAD -- $PAYLOAD_FILE"
echo "TfcpOutCmd_nhy : $TFCP_NHY -- $NHY_FILE"
CARRIERS=`grep carriers $K_FILE | sed 's/carriers//' | sed ':a;N;$!ba;s/\n/ + /g' | bc`
echo "Cmodel passed $CARRIERS in $PATTERN_K"
echo "$ERR_CNT errors -- $ERR_FILE"
