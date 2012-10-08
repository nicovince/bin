#!/bin/bash

# repo/git path
REPO_DEST="${HOME}/work/SQN3210_product/git/SQN3210_PRODUCT"
# import in a temporary location 
DEST="${HOME}/work/SQN3210_product/importFrom3210"

copy_to_repo()
{
  local module=${1}
  pushd ${DEST} > /dev/null
  pushd ${module} > /dev/null
  if [ ${module} = "asiclib" ]; then
    cp -r memories srcv ${REPO_DEST}/${MODULE}
  else
    cp -r simv srcv ${REPO_DEST}/${module}
  fi
  popd > /dev/null
  popd > /dev/null
}

# asiclib
MODULE=asiclib
echo "Import ${MODULE}"
importasiclib.sh -dest ${DEST}
copy_to_repo ${MODULE}

# ieee_proposed
MODULE=ieee_proposed
echo "Import ${MODULE}"
macro2git.sh -macro ${MODULE} -filelist simv/tops/shiva_top/testbench/file_list_ieee -dest ${DEST}
copy_to_repo ${MODULE}

# scs_meas
MODULE=scs_meas
echo "Import ${MODULE}"
macro2git.sh -macro ${MODULE} -filelist srcv/tops/lte_tops/file_list_scs_meas -dest ${DEST} -top scs_meas_macro
copy_to_repo ${MODULE}

# ulp
MODULE=ulp
echo "Import ${MODULE}"
macro2git.sh -macro ${MODULE} -filelist ./srcv/tops/ulp_macro/ulp_macro_file_list -dest ${DEST} -top ulp_macro
copy_to_repo ${MODULE}

# mips_client
MODULE=mips_client
echo "Import ${MODULE}"
macro2git.sh -macro ${MODULE} -filelist ./srcv/platform/mips24kc_macro/mips24kc_client_macro/file_list -dest ${DEST} -top mips24kc_client_top
copy_to_repo ${MODULE}

# mips_cpu
MODULE=mips_cpu
echo "Import ${MODULE}"
macro2git.sh -macro ${MODULE} -filelist ./srcv/platform/mips24kc_macro/mips24kc_cpu_macro/file_list -dest ${DEST} -top mips24kc_cpu_top.v
copy_to_repo ${MODULE}

# mac_tdc
MODULE=mac_tdc
echo "Import ${MODULE}"
macro2git.sh -macro ${MODULE} -filelist srcv/tops/lte_tops/file_list_mac_tdc -dest ${DEST} -top mac_tdc
copy_to_repo ${MODULE}
