#!/bin/bash
VERLIB="latest5-2"
FILEPP=/delivery/lib/${VERLIB}/make/filepp
PARSE_FILE_LIST=/delivery/lib/${VERLIB}/make/parse_file_list.pl
GETVERSION=/delivery/lib/${VERLIB}/labo/getVersion.py

to_lower()
{
  arg=$1
  echo $1 | tr '[A-Z]' '[a-z]'
}

to_upper()
{
  arg=$1
  echo $1 | tr '[a-z]' '[A-Z]'
}

# recursive function
# return the filelists incuded with -f in a filelist passed as first arg
retrieve_filelist()
{
  local fl=$1
  # remove comment and empty lines
  local filelists=`cat $fl | sed '/^\/\//d' | sed '/^$/d' | grep '^\s*-f' | awk '{print $2}'`
  if [ -n "$filelists" ]; then
    echo $filelists | sed 's/ /\n/g'
  fi
  for f in $filelists; do
    retrieve_filelist $f
  done
}

# recursive function
# return list of files included
get_deps()
{
  local src=${1}
  local incdirs=${2}
  if [ -f ${src} ]; then
    local deps=`grep '^\s*.include' $src | sed '/\/\//d' | sed 's/.*include\s*"\(.*\)".*/\1/' | sort | uniq`
  fi
  if [ -n "$deps" ]; then
    echo "${deps}"
    for d in ${deps}; do
      # check if included file is directly accessible from where we are
      if [ -f ${d} ]; then
        get_deps ${d} ${incdirs}
      else
        # looks for incdir
        local deps_inc=""
        for i in ${INCDIRS}; do
          deps_inc="${deps_inc} `find ${i} -maxdepth 1 -name ${d}`"
        done
        for di in ${deps_inc}; do
          get_deps ${di} ${incdirs}
        done
      fi
    done
  fi
}

# parse args
while [ $# -gt 0 ] ; do
  case $1 in
    -macro)
      MACRO=$2
      shift;;
    -top)
      TOP=$2
      shift;;
    -filelist)
      FILELIST=$2
      shift;;
    -dest)
      DEST=$2
      shift;;
    -h|*)
      echo "usage : $0 -macro macro_name -filelist /path/to/macro_filelist"
      echo " -dest /path/to/copy/files/to"
      exit 1
      ;;
  esac
  shift
done
# default values
MACRO=${MACRO:-scs_meas}
TOP=${TOP:-${MACRO}}
FILELIST=${FILELIST:-./srcv/tops/lte_tops/file_list_scs_meas}
DEST=${DEST:-${HOME}/work/SQN3210_product/importFrom3210}/${MACRO}

#cleanup destination folder if it exists already
rm -Rf ${DEST}
mkdir -p ${DEST}

# remove ASIC link to avoid ln complains that it exists already
rm -f ASIC
ln -s ./ ASIC

# build filelist with filepp
HDL_FILES=`${FILEPP} -e -kc "//#" ${FILELIST} | sed '/^$/d'`

# sort result of filepp
# Excludes asiclib as it is handled differently
# (one repository for asiclib shared with all macros)
VHDL_FILES=`echo ${HDL_FILES} | sed 's/ /\n/g' | sort | uniq | grep '.vhdl\?$' | grep -v "asiclib"`
VERILOG_FILES=`echo ${HDL_FILES} | sed 's/ /\n/g' | sort | uniq | grep '.v$' | grep -v "asiclib" | grep -v "memories"`
INCDIRS=`echo ${HDL_FILES} | sed 's/ /\n/g' | sort | uniq | grep incdir | sed 's/+incdir+//' | grep -v "asiclib"`

# Retrieve all filelists recursively
FILELISTS="`retrieve_filelist ${FILELIST}` ${FILELIST}"

###
echo "${MACRO}: Copy hdl files"

# copy vhdl files
for vhdl in ${VHDL_FILES}; do
  vhdl_file=`echo ${vhdl} | sed 's#ASIC/##'`
  cp --parents ${vhdl_file} ${DEST}
done


# copy verilog files
DEPS=""
for verilog in ${VERILOG_FILES}; do
  verilog_file=`echo ${verilog} | sed 's#ASIC/##'`
  cp --parents ${verilog_file} ${DEST}
  deps=`get_deps ${verilog} "${INCDIRS}"`
  for d in ${deps}; do
    # look if current deps has already been processed
    has_been_processed=0
    has_been_processed=`echo ${DEPS} | grep "\<${d}\>" -c`
    if [ ${has_been_processed} -eq 0 ]; then
      #echo "  search ${d} included in ${verilog}"
      if [ ! -f ${d} ]; then
        # Inlude is not absolute path from ASIC/ but rely on incdirs
        # loop through incdirs to search it
        for i in ${INCDIRS}; do
          DEPS="${DEPS} `find ${i} -maxdepth 1 -name ${d}`"
        done
      else
        DEPS="${DEPS} ${d}"
      fi
    fi
    # Check that current included files has been found
    dep_found=`echo ${DEPS} | grep ${d} -c`
    if [ $dep_found -eq 0 ]; then
      echo "[Warning] ${MACRO}: ${d} included in ${verilog} (or through its included files) not found to be copied for import"
    fi
  done
done

# Copy included files
DEPS=`echo ${DEPS} | sed 's/ /\n/g' | sort | uniq `
for d in ${DEPS}; do
  d_file=`echo ${d} | sed 's#ASIC/##'`
  cp --parents ${d_file} ${DEST}
done

# move ASIC/qasara to ASIC/srcv/qasara
# move ASIC/qasara/IP/ic/shared to ASIC/srcv/common/qasara
pushd ${DEST} > /dev/null
if [ -d qasara ]; then
  mkdir -p srcv
  mv qasara srcv/
  if [ -d srcv/qasara/IP/ic/shared ] && [ ${MACRO} != "ieee_proposed" ]; then
    mv srcv/qasara/IP/ic/shared srcv/common/qasara
  fi
fi
cd ../
# remove ASIC link to avoid ln complains that it exists already
rm -f ASIC
ln -s ./ ASIC
popd > /dev/null

# copy filelists
# update them to the new hierarchy :
# ASIC/... -> ASIC/macro_name/...
# ASIC/qasara -> ASIC/macro_name/srcv/qasara
# ASIC/qasara/IP/ic/shared -> ASIC/macro_name/srcv/common/qasara
# ASIC/srcv/common/asiclib -> ASIC/asiclib/srcv/common/asiclib
# ASIC/memories -> ASIC/asiclib/memories
# Create new variable GIT_FILELISTS which contains the list of filelists in the
# new hierarchy starting at ASIC/macro_name
mkdir -p `dirname ${DEST}/${FILELIST}`
# Create sed script to apply changes to filelists
SED_UPDATE_FILELISTS=${DEST}/${MACRO}_update_filelists.sed
echo "#!/bin/sed -f" > ${SED_UPDATE_FILELISTS}
echo "s@ASIC/\+qasara/\+@ASIC/srcv/qasara/@" >> ${SED_UPDATE_FILELISTS}
if [ ${MACRO} != "ieee_proposed" ]; then
  echo "s@ASIC/\+srcv/\+qasara/\+IP/\+ic/\+shared/@ASIC/srcv/common/qasara/@" >> ${SED_UPDATE_FILELISTS}
fi
echo "s@ASIC/\+@ASIC/${MACRO}/@" >> ${SED_UPDATE_FILELISTS}
echo "s@ASIC/\+${MACRO}/\+srcv/\+common/\+asiclib/\+@ASIC/asiclib/srcv/common/asiclib/@" >> ${SED_UPDATE_FILELISTS}
echo "s@ASIC/\+${MACRO}/\+memories@ASIC/asiclib/memories@" >> ${SED_UPDATE_FILELISTS}
chmod +x ${SED_UPDATE_FILELISTS}
for fl in ${FILELISTS}; do
  # remove ASIC prefix
  fl_file=`echo $fl | sed 's#ASIC/##'`
  # Update destination filelist to the new hierarchy 
  # ASIC/qasara -> ASIC/srcv/qasara
  # ASIC/qasara/IP/ic/shared -> ASIC/srcv/common/qasara
  fl_dest_file=`echo ${fl_file} | \
  sed "s#^qasara#srcv/qasara#" | \
  sed "s#^srcv/qasara/IP/ic/shared#srcv/common/qasara#"`
  GIT_FILELISTS="${GIT_FILELISTS} ${fl_dest_file}"
  # Create the folder of the filelist if it does not exist
  mkdir -p `dirname ${DEST}/${fl_dest_file}`
  #copy filelist and apply sed script
  cp ${fl_file} ${DEST}/${fl_dest_file}
  ${SED_UPDATE_FILELISTS} -i ${DEST}/${fl_dest_file}
  # Create new filelist
  #sed "s#ASIC/\+qasara/\+#ASIC/srcv/qasara/#" ${fl_file} | \
  #sed "s#ASIC/\+srcv/\+qasara/\+IP/\+ic/\+shared/#ASIC/srcv/common/qasara/#" |\
  #sed "s#ASIC/\+#ASIC/${MACRO}/#" | \
  #sed "s#ASIC/\+${MACRO}/\+srcv/\+common/\+asiclib/\+#ASIC/asiclib/srcv/common/asiclib/#" | \
  #sed "s#ASIC/\+${MACRO}/\+memories#ASIC/asiclib/memories#" \
  #> ${DEST}/${fl_dest_file}
done


### Start processing macro files ###
echo "${MACRO}: Patch hdl files"
pushd ${DEST} > /dev/null

# Creates sed script which will remember the files names changes
SED_RENAME_FILES=${DEST}/${MACRO}_rename_common_files.sed
# and modules names changes
SED_RENAME_MODULES=${DEST}/${MACRO}_rename_common_modules.sed

# sed header
touch ${SED_RENAME_FILES}
chmod +x ${SED_RENAME_FILES}
echo "#!/bin/sed -f" > ${SED_RENAME_FILES}

touch ${SED_RENAME_MODULES}
chmod +x ${SED_RENAME_MODULES}
echo "#!/bin/sed -f" > ${SED_RENAME_MODULES}


# for each common file rename it with the macro name prefix
# Remember the changes in the sed script
if [ -d srcv/common ]; then
  COMMON_FILES=`find srcv/common -type f`
fi
for cf in ${COMMON_FILES}; do
  cf_file=`basename ${cf}`
  dest_cf="`dirname ${cf}`/${MACRO}_${cf_file}"
  dest_cf_file=`basename ${dest_cf}`
  # record the renaming (for filelist update)
  echo "s/\\<${cf_file}\\>/${dest_cf_file}/" >> ${SED_RENAME_FILES}

  # process for verilog files
  if [ `echo ${cf} | grep -c ".v$"` -eq 1 ]; then
    # get module name and build macro module name
    modules_names=`grep "^\s*\<module\>" ${cf} | sed 's/^\s*\<module\>\s\+\(\w\+\)\s*.*$/\1/'`
    for m in ${modules_names}; do
      macro_module_name="${MACRO}_${m}"
      # record the module renaming
      echo "s/\\<${m}\\>/${macro_module_name}/" >> ${SED_RENAME_MODULES}
    done
  fi

  # process for vhdl files
  # Search & replace is insensitive ( i flag on sed : s/toto/titi/i)
  if [ `echo ${cf} | grep -c ".vhd$"` -eq 1 ]; then
    # get entity name
    entities_names=`grep "^\s*\<entity\>" ${cf} | sed 's/^\s*\<entity\>\s\+\(\w\+\)\s*.*$/\1/'`
    for e in ${entities_names}; do
      macro_entity_name="${MACRO}_${e}"
      # record entity renaming
      echo "s/\\<${e}\\>/${macro_entity_name}/i" >> ${SED_RENAME_MODULES}
    done

    # get package if any
    packages_names=`grep "^\s*\<package\>" ${cf} | grep -v "body" | sed 's/^\s*\<package\>\s\+\(\w\+\)\s*is.*$/\1/'`
    for p in ${packages_names}; do
      macro_package_name="${MACRO}_${p}"
      # record package renaming
      echo "s/\\<${p}\\>/${macro_package_name}/i" >> ${SED_RENAME_MODULES}
    done
  fi

  # do the file renaming
  mv ${cf} ${dest_cf}

  # check if the common file is a file_list
  if [ `echo ${GIT_FILELISTS} | grep -c ${cf}` -ne 0 ]; then
    # then update the GIT_FILELISTS var with the new common file list name
    GIT_FILELISTS=`echo ${GIT_FILELISTS} | sed "s/${cf_file}/${dest_cf_file}/g"`
  fi
done

# update filelists with new common files name
for fl in ${GIT_FILELISTS};do
  ${SED_RENAME_FILES} ${fl} -i #-i.bak
  # diff --brief  ${fl} ${fl}.bak
done

# update HDL source with new modules, entities, packages names.
for f in `find . -name "*.v" -o -name "*.vhd" -type f`; do
  ${SED_RENAME_MODULES} ${f} -i #-i.bak
  # also apply the filenames changes script for "include"
  ${SED_RENAME_FILES} ${f} -i #-i.bak2
  #diff --brief ${f} ${f}.bak
done

# Check that files in the file list parsed exists
cd ../
GIT_HDL_FILES=`${FILEPP} -e -kc "//#" ${MACRO}/${FILELIST} | grep -v "^//" | sed '/^$/d' | grep -v "incdir" | sort | uniq`
for f in ${GIT_HDL_FILES};do
  if [ ! -f ${f} ]; then
    echo "[Warning] ${MACRO} $f is in filelist but does not exist or has not been copied"
  fi
done

MACRO_FILELIST_PARSED=${MACRO}_file_list_parsed
GIT_HDL_FILES=`${FILEPP} -e -kc "//#" ${MACRO}/${FILELIST} | ${PARSE_FILE_LIST}`

COMPILE_SCRIPT="${MACRO}/simv/${MACRO}_compile.sh"
mkdir -p `dirname ${COMPILE_SCRIPT}`
echo "#!/bin/bash -e" > ${COMPILE_SCRIPT}
echo "if [ ! -h ASIC ]; then" >> ${COMPILE_SCRIPT}
echo "  ln -s ../.. ASIC" >> ${COMPILE_SCRIPT}
echo "fi" >> ${COMPILE_SCRIPT}

# INCA_libs
echo "mkdir -p ASIC/${MACRO}/simv/INCA_libs/worklib" >> ${COMPILE_SCRIPT}

# hdl.var
HDLVAR=ASIC/${MACRO}/simv/INCA_libs/hdl.var
echo "echo define work worklib > ${HDLVAR}" >> ${COMPILE_SCRIPT}

#cds.lib
CDSLIB=ASIC/${MACRO}/simv/INCA_libs/cds.lib
IUS_HOME=`${GETVERSION}  --iushome`
echo "echo include ${IUS_HOME}/tools/inca/files/cds.lib > ${CDSLIB}" >> ${COMPILE_SCRIPT}
echo "echo define worklib ./worklib >> ${CDSLIB}" >> ${COMPILE_SCRIPT}
echo "echo define ieee_proposed ieee_proposed >> ${CDSLIB}" >> ${COMPILE_SCRIPT}

if [ ${MACRO} = "ieee_proposed" ]; then
  echo "mkdir -p ASIC/${MACRO}/simv/INCA_libs/ieee_proposed" >> ${COMPILE_SCRIPT}
  echo "ncvhdl -v93 -cdslib ${CDSLIB} -hdlvar ${HDLVAR} -ASSERT  -NOPRAGMAWARN -nowarn IGNPRG -work ieee_proposed ${GIT_HDL_FILES}" >> ${COMPILE_SCRIPT}
else

  echo "if [ ! -h INCA_libs/ieee_proposed ]; then" >> ${COMPILE_SCRIPT}
  echo "  ln -s ../ASIC/ieee_proposed/simv/INCA_libs/ieee_proposed INCA_libs/ieee_proposed" >> ${COMPILE_SCRIPT}
  echo "fi" >> ${COMPILE_SCRIPT}

  echo "ASIC/ieee_proposed/simv/ieee_proposed_compile.sh" >> ${COMPILE_SCRIPT}
  echo "${FILEPP} -e -kc \"//#\" ASIC/${MACRO}/${FILELIST} > ${MACRO_FILELIST_PARSED} " >> ${COMPILE_SCRIPT}
  echo "irun -f ${MACRO_FILELIST_PARSED} -sv -v93 -cdslib INCA_libs/cds.lib -hdlvar INCA_libs/hdl.var -define NEWCOMPIL -top ${TOP} -timescale 1ns/1ps" >> ${COMPILE_SCRIPT}
fi

chmod +x ${COMPILE_SCRIPT}
