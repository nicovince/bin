#!/bin/bash

SIM=`basename $PWD`
for CORNER in WC WCL LT; do
  TEE_LOG="output.${CORNER}.log"
  /usr/bin/make -f ../../GNUmakefile VERLIB=rel5-2.1p49 USE_64=1 USE_SHIVA_TOP_GATE=1 SDF_${CORNER}=1 NOCUVMPW=1 NOCUVWSI=1 NO_HARDREPAIR=1 USE_TMP_4_DELIVERY=0 NCELAB_OPTIONS='"-messages"' NCSIM_OPTIONS='"-NONTCGLITCH +bus_conflict_off"' AFE_STUB=1 sceclean
  qrsh -V -cwd -l qname=asic_gate_plt.q,gate=1 /usr/bin/make -f ../../GNUmakefile VERLIB=rel5-2.1p49 USE_64=1 USE_SHIVA_TOP_GATE=1 SDF_${CORNER}=1 NOCUVMPW=1 NOCUVWSI=1 NO_HARDREPAIR=1 USE_TMP_4_DELIVERY=0 NCELAB_OPTIONS='"-messages"' NCSIM_OPTIONS='"-NONTCGLITCH +bus_conflict_off"' AFE_STUB=1 all | tee $TEE_LOG
  cp cve.log cve.log.${CORNER}
  find . -name ncsim.log -exec cp {} ncsim.log.${CORNER}
  pwd | mutt -s "[GLS] ${SIM} ${CORNER}" -- ${LOGNAME}@sequans.com
done

