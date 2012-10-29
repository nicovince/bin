#!/bin/bash
# Create sed script that will replace the qasara constant names by the memMapDef names
# This script should be run from ASIC/srcv/common/config_regs/qregisters/ dir

mkdir "scripts.sed"

for file in *_regs_pkg.vhd; do

  module_name=`grep "^component" $file | sed 's/component //'`
  script_name="${module_name}.sed"
  echo "#!/bin/sed -f" > $script_name
  echo "#$module_name" >> $script_name

  while read line
  do
    enum_line=`echo $line | grep "constant e"`
    # handle enum
    if [ -n "$enum_line" ]; then

      new_enum_name=`echo $enum_line | sed 's/constant \([a-zA-Z0-9_]*\)\s*:.*$/\1/'`
      suffix=`echo $new_enum_name | sed 's/e//' | tr '[:upper:]' '[:lower:]'`
      old_enum_name=`echo "c_${suffix}"`
      echo "s/$old_enum_name/$new_enum_name/g" >> $script_name


    fi

    # handle reset
    reset_line=`echo $line | grep "constant c_reset_"`
    if [ -n "$reset_line" ]; then
      new_reset_name=`echo $reset_line | sed 's/constant \([a-zA-Z0-9_]*\)\s*:.*$/\1/'`
      suffix=`echo $new_reset_name | sed "s/c_reset_${module_name}_//"`
      old_reset_name=`echo "c_${module_name}_reset_${suffix}"`
      echo "s/${old_reset_name}/${new_reset_name}/g" >> $script_name

    fi

  done < $file
  chmod +x $script_name

  mv $script_name scripts.sed

  echo "find ASIC/qasara -name \"*.vhd\" -exec `pwd`/scripts.sed/${script_name} {} \;"
done
