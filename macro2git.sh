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
  if [ -f ${src} ]; then
    local deps=`grep 'include' $src | sed '/\/\//d' | sed 's/.*include\s*"\(.*\)".*/\1/' | sort | uniq`
  fi
  if [ -n "$deps" ]; then
    echo "${deps}"
    for d in ${deps}; do
      if [ -f ${d} ]; then
        get_deps $d
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
    -filelist)
      FILELIST=$2
      shift;;
    -dest)
      DEST=$2
      shift;;
    -h|*)
      echo "usage : $0 -macro macro_name -filelist /path/to/macro_filelist"
      exit 1
      ;;
  esac
  shift
done
# default values
MACRO=${MACRO:-scs_meas}
FILELIST=${FILELIST:-./srcv/tops/lte_tops/file_list_scs_meas}
DEST=${DEST:-${HOME}/work/SQN3210_product}/${MACRO}

#cleanup destination folder if it exists already 
rm -Rf $DEST
mkdir -p $DEST

ln -s ./ ASIC

# build filelist with filepp
HDL_FILES=`${FILEPP} -e -kc "//#" ${FILELIST} | sed '/^$/d'`

# sort result of filepp
# Excludes asiclib as it is handled differently 
# (one repository for asiclib shared with all macros)
VHDL_FILES=`echo ${HDL_FILES} | sed 's/ /\n/g' | sort | uniq | grep '.vhdl\?$' | grep -v "asiclib"`
VERILOG_FILES=`echo ${HDL_FILES} | sed 's/ /\n/g' | sort | uniq | grep '.v$' | grep -v "asiclib"`
INCDIRS=`echo ${HDL_FILES} | sed 's/ /\n/g' | sort | uniq | grep incdir | sed 's/+incdir+//' | grep -v "asiclib"`

# Retrieve all filelists recursively
FILELISTS="`retrieve_filelist ${FILELIST}` ${FILELIST}"

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
  deps=`get_deps ${verilog}`
  for d in ${deps}; do
    if [ ! -f ${d} ]; then
      for i in ${INCDIRS}; do
        DEPS="${DEPS} `find ${i} -name ${d}`"
      done 
    else 
      DEPS="${DEPS} ${d}"
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
# and create ASIC link at root
pushd ${DEST} > /dev/null
if [ -d qasara ]; then
  mkdir -p srcv
  mv qasara srcv/
fi
cd ../
ln -s ./ ASIC
popd > /dev/null

# copy filelists
# update them to the new hierarchy : 
# ASIC/... -> ASIC/macro_name/...
# ASIC/qasara -> ASIC/macro_name/srcv
# ASIC/srcv/common/asiclib -> ASIC/asiclib/srcv/common/asiclib
# Create new variable GIT_FILELISTS which contains the list of filelists in the
# new hierarchy starting at ASIC/macro_name
mkdir -p `dirname ${DEST}/${FILELIST}`
#sed "s#ASIC/qasara/#ASIC/srcv/qasara/#" ${FILELIST} | sed "s#ASIC/#ASIC/${MACRO}/#" > ${DEST}/${FILELIST}
#GIT_FILELISTS=${FILELIST}
for fl in ${FILELISTS}; do
  # remove ASIC prefix
  fl_file=`echo $fl | sed 's#ASIC/##'`
  # Update destination filelist to the new hierarchy (ASIC/qasara -> ASIC/srcv/qasara)
  fl_dest_file=`echo ${fl_file} | sed "s#^qasara#srcv/qasara#"`
  GIT_FILELISTS="${GIT_FILELISTS} ${fl_dest_file}"
  # Create the folder of the filelist if it does not exist
  mkdir -p `dirname ${DEST}/${fl_dest_file}`
  # Create new filelist
  sed "s#ASIC/\+qasara/\+#ASIC/srcv/qasara/#" ${fl_file} | \
  sed "s#ASIC/\+#ASIC/${MACRO}/#" | \
  sed "s#ASIC/\+${MACRO}/\+srcv/\+common/\+asiclib/\+#ASIC/asiclib/srcv/common/asiclib/#" > ${DEST}/${fl_dest_file}
done


### Start processing macro files ###
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
  if [ `echo ${cf} | grep -c ".vhd$"` -eq 1 ]; then
    # get entity name
    entities_names=`grep "^\s*\<entity\>" ${cf} | sed 's/^\s*\<entity\>\s\+\(\w\+\)\s*.*$/\1/'`
    for e in ${entities_names}; do
      macro_entity_name="${MACRO}_${e}"
      # record entity renaming
      echo "s/\\<${e}\\>/${macro_entity_name}/" >> ${SED_RENAME_MODULES}
    done

    # get package if any
    packages_names=`grep "^\s*\<package\>" ${cf} | grep -v "body" | sed 's/^\s*\<package\>\s\+\(\w\+\)\s*is.*$/\1/'`
    for p in ${packages_names}; do
      macro_package_name="${MACRO}_${p}"
      # record package renaming
      echo "s/\\<${p}\\>/${macro_package_name}/" >> ${SED_RENAME_MODULES}
    done
  fi

  # do the file renaming
  mv ${cf} ${dest_cf}

  # check if the common file is a file_list
  if [ `echo ${GIT_FILELISTS} | grep -c ${cf}` -ne 0 ]; then
    # then update the GIT_FILELISTS var with the new common file list name
    GIT_FILELISTS=`echo ${GIT_FILELISTS} | sed "s/${cf_file}/${dest_cf_file}/"`
  fi
done

# update filelists with new common files name
for fl in ${GIT_FILELISTS};do
  ${SED_RENAME_FILES} -i.bak ${fl}
  # diff --brief  ${fl} ${fl}.bak
done

# update HDL source with new modules, entities, packages names.
for f in `find . -name "*.v" -o -name "*.vhd" -type f`; do
  ${SED_RENAME_MODULES} -i.bak ${f}
  # also apply the filenames changes script for "include"
  ${SED_RENAME_FILES} -i.bak2 ${f}
  #diff --brief ${f} ${f}.bak
done

# Check that files in the file list parsed exists
cd ../
GIT_HDL_FILES=`${FILEPP} -e -kc "//#" ${MACRO}/${FILELIST} | grep -v "^//" | sed '/^$/d' | grep -v "incdir" | sort | uniq`
for f in ${GIT_HDL_FILES};do
  if [ ! -f ${f} ]; then
    echo "oops, $f does not exist"
  fi
done

MACRO_FILELIST_PARSED=${MACRO}_file_list_parsed
GIT_HDL_FILES=`${FILEPP} -e -kc "//#" ${MACRO}/${FILELIST} | ${PARSE_FILE_LIST}`

mkdir -p INCA_libs/worklib
mkdir -p INCA_libs/ieee_proposed
HDLVAR=INCA_libs/hdl.var
echo "define work worklib" > ${HDLVAR}

CDSLIB=INCA_libs/cds.lib
IUS_HOME=`${GETVERSION}  --iushome`
echo "include ${IUS_HOME}/tools/inca/files/cds.lib" > ${CDSLIB}
echo "define worklib ./worklib" >> ${CDSLIB}
echo "define ieee_proposed ieee_proposed" >> ${CDSLIB}

if [ ${MACRO} = "ieee_proposed" ]; then
  echo ncvhdl -v93 -cdslib ${CDSLIB} -hdlvar ${HDLVAR} -ASSERT  -NOPRAGMAWARN -nowarn IGNPRG -work ieee_proposed ${GIT_HDL_FILES}
fi

echo "${FILEPP} -e -kc \"//#\" ${MACRO}/${FILELIST} > ${MACRO_FILELIST_PARSED} "
echo "irun -f ${MACRO_FILELIST_PARSED} -sv -v93 -cdslib INCA_libs/cds.lib -hdlvar INCA_libs/hdl.var"

