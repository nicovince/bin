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
    cp -r memories srcv ${REPO_DEST}/${module}
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
macro2git.sh -macro ${MODULE} -filelist ./srcv/platform/mips24kc_macro/mips24kc_cpu_macro/file_list -dest ${DEST} -top mips24kc_cpu_top
copy_to_repo ${MODULE}

# mac_tdc
MODULE=mac_tdc
echo "Import ${MODULE}"
macro2git.sh -macro ${MODULE} -filelist srcv/tops/lte_tops/file_list_mac_tdc -dest ${DEST} -top mac_tdc
copy_to_repo ${MODULE}

# downlink
MODULE=downlink
echo "Import ${MODULE}"
macro2git.sh -macro ${MODULE} -filelist srcv/tops/lte_tops/file_list_downlink -dest ${DEST} -top downlink_top
copy_to_repo ${MODULE}

# lte_top_dsproc
MODULE=lte_top_dsproc
echo "Import ${MODULE}"
macro2git.sh -macro ${MODULE} -filelist srcv/phy/dsproc/file_list -dest ${DEST} -top lte_top_dsproc
copy_to_repo ${MODULE}

# digrf_macro
MODULE=digrf
echo "Import ${MODULE}"
macro2git.sh -macro ${MODULE} -filelist srcv/phy/digrf_v4/digrf_macro/file_list -dest ${DEST} -top digrf_macro
copy_to_repo ${MODULE}


# shiva_top
MODULE=shiva_top
echo "Import ${MODULE}"
macro2git.sh -macro ${MODULE} -filelist srcv/tops/shiva_top/file_list -dest ${DEST} -top shiva_top \
  -flag USE_SCS_MEAS_MACRO_STUB \
  -flag USE_SCS_MEAS_MACRO_0_STUB \
  -flag USE_SCS_MEAS_MACRO_1_STUB \
  -flag ULP_CORE_STUB \
  -flag MIPS_CPU_STUB \
  -flag MIPS_CLIENT_STUB \
  -flag MAC_TDC_TOP_STUB \
  -flag USE_DOWNLINK_TOP_STUB \
  -flag USE_DOWNLINK_TOP_0_STUB \
  -flag USE_DOWNLINK_TOP_1_STUB \
  -flag LTE_TOP_DSPROC_STUB \
  -flag LTE_TOP_DSPROC_0_STUB \
  -flag LTE_TOP_DSPROC_1_STUB \
  -flag USE_DIGRF_MACRO_STUB \
  -flag USE_DIGRF_MACRO_0_STUB \
  -flag USE_DIGRF_MACRO_1_STUB
copy_to_repo ${MODULE}

svn info > svn_info.txt
cp svn_info.txt ${DEST}
