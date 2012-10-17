#!/bin/bash


print_help()
{
  echo "Usage : $0 -netlist <netlist.v> -top <top_level_module>"
  echo "This script will uniquify module names by prefixing all modules with the top_level_module name"
  echo "This is useful for mixed rtl/gate level simulations where common modules are used in the netlist and the rtl"
}

## Parsing command line
while [ $# -gt 0 ] ; do
  case $1 in
    -netlist)
      netlist=$2
      shift;;
    -top)
      top=$2
      shift;;
    -help)
      print_help
      exit 0
      shift;;
    *)
      print_help
      exit 1
      shift;;
  esac
  shift
done

# retrieve list of modules names that we want to uniquify
# reject the top level module name
modules=`grep "\<module\>" $netlist | sed 's/module\s*\([[:alnum:]_]*\)\s*(.*/\1/' | grep -v "\<$top\>"`

# backup of netlist
cp $netlist $netlist.bak

# Search and replace module names
SED_SCRIPT="${netlist}_uniquify.sed"
echo "#!/bin/sed -f" > ${SED_SCRIPT}
chmod +x ${SED_SCRIPT}

for m in $modules; do
  #sed -i "s/\<${m}\>/${top}_${m}/" $netlist
  echo "s/\<${m}\>/${top}_${m}/g" >> ${SED_SCRIPT}
done
${SED_SCRIPT} -i ${netlist}
