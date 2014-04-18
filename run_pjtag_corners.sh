#!/bin/bash -x
SIM="pjtag"
for CORNER in WC WCL LT; do
  TEE_LOG="output.${CORNER}.log"
  qrsh -V -cwd -l qname=asic_gate.q,gate=1 -now no /usr/bin/make -f ../../GNUmakefile VERLIB=rel5-2.1p49 USE_64=1 USE_SHIVA_TOP_GATE=1 SDF_${CORNER}=1 NOCUVMPW=1 NOCUVWSI=1 NO_HARDREPAIR=1 USE_TMP_4_DELIVERY=0 TB_OPTIONS='"-nbsubframe 1"' NCELAB_OPTIONS='"-messages"' NCSIM_OPTIONS='"-NONTCGLITCH +bus_conflict_off"' AFE_STUB=1  sceclean
  qrsh -V -cwd -l qname=asic_gate.q,gate=1 -now no /usr/bin/make -f ../../GNUmakefile VERLIB=rel5-2.1p49 USE_64=1 USE_SHIVA_TOP_GATE=1 SDF_${CORNER}=1 NOCUVMPW=1 NOCUVWSI=1 NO_HARDREPAIR=1 USE_TMP_4_DELIVERY=0 TB_OPTIONS='"-nbsubframe 1"' NCELAB_OPTIONS='"-messages"' NCSIM_OPTIONS='"-NONTCGLITCH +bus_conflict_off"' AFE_STUB=1  all | tee $TEE_LOG
  cp cve.log cve.log.${CORNER}
  find . -name ncsim.log -exec cp {} ncsim.log.WC
  pwd | mutt -a "cve.log.${CORNER}" -a "$TEE_LOG" -s "[GLS] ${SIM} ${CORNER}" -- nvincent@sequans.com
done
