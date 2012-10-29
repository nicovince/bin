#!/bin/bash
# Convert qasara vhdl reg module instanciation to MemMapDef verilog reg module instanciation

while [ $# -gt 0 ] ; do
  case $1 in 
    -file)
      VHDL_FILE=$2
      shift;;
    -module)
      # module in upper case
      MODULE=`echo $2 | sed 's/\(.*\)/\U\1/'`
      shift;;
    -h|*)
      echo "-file <file.vhd> : <file.vhd> contains only the vhdl port map of the old vhdl register module"
      echo "-module <module> : <module> is the name of the verilog module which will be instanciated"
      exit 1
  esac
  shift
done

while read line
do
  processed=0
  port_name_verilog=""
  # Remove comment lines, trailing comments and blank lines
  line_filtered=`echo $line | sed '/^\s*--.*/d' | sed -e '/^\s*$/d' | sed 's/--.*$//'`

  if [ -n "$line_filtered" ]; then
    #retrieve port name and store it in uppercase for easier regex
    port_name_vhdl=`echo $line_filtered | sed 's/\([a-zA-Z0-9_]*\)\s*=>.*$/\U\1/'`
    sig_name_vhdl=`echo $line_filtered | sed "s/\([a-zA-Z0-9_]*\)\s*=>\s*\([a-zA-Z0-9_.() ']*\)\s*,\?\s*$/\2/"`


    case $port_name_vhdl in
      I_CLK)
        port_name_verilog="CLK";;
      I_RESET_N)
        port_name_verilog="RSTN";;
      I_ENCLK)
        processed=1;;
      I_PSEL)
        psel=$sig_name_vhdl
        processed=1;;
      I_PENABLE)
        processed=1
        penable=$sig_name_vhdl
        port_name_verilog="";;
      I_PWRITE)
        port_name_verilog="WE";;
      I_PADDR)
        port_name_verilog="SMPI_ADDR";;
      I_PWDATA)
        port_name_verilog="SMPI_WDATA";;
      O_PREADY)
        processed=1;;
      O_PRDATA)
        port_name_verilog="SMPI_RDATA";;
      O_ENCLK_*)
        processed=1;;

      *)
        direction=`echo $port_name_vhdl | sed 's/^\([IO]\)_.*/\1/'`
        case $direction in
          O)
            prefix=`echo $port_name_vhdl | sed 's/\(O_REG_\(RE_\)\?\(W[PED]_\)\?\).*/\1/'`
            suffix=`echo $port_name_vhdl | sed "s/$prefix\(.*\)$/\1/"`
            case $prefix in
              O_REG_WP_)
                port_name_verilog="PULSEWRITE_${MODULE}_${suffix}";;
              O_REG_WE_)
                port_name_verilog="PULSEWRITE_${MODULE}_${suffix}";;
              O_REG_RE_)
                port_name_verilog="PULSEREAD_${MODULE}_${suffix}";;
              O_REG_|O_REG_WD_)
                port_name_verilog="CFG_${MODULE}_${suffix}";;
              *)
                echo "$prefix not supported"
                exit 1;;
            esac;;
          I)
            prefix=`echo $port_name_vhdl | sed 's/\(I_REG_\(RDY\?_\)\?\(SET_\)\?\).*/\1/'`
            suffix=`echo $port_name_vhdl | sed "s/$prefix\(.*\)$/\1/"`
            case $prefix in
              I_REG_SET_)
                port_name_verilog="RO_${MODULE}_${suffix}";;
              I_REG_RDY_)
                port_name_verilog="--RM $port_name_vhdl";;
              I_REG_RD_)
                port_name_verilog="RO_${MODULE}_${suffix}";;
              I_REG_)
                port_name_verilog="RO_${MODULE}_${suffix}";;
              *)
                echo "$prefix not supported"
                exit 1;;
            esac
        esac;;
    esac

    if [ $processed -eq 0 ]; then
      echo "$port_name_verilog => $sig_name_vhdl,"
    fi
  fi

done < $VHDL_FILE

