#!/bin/tcsh -f

#############################################################################
#         This program is the Confidential and Proprietary product of       #
#                   'SEQUANS COMMUNICATIONS'                                #
#        Any unauthorized use, reproduction or transfer of this program     #
#                            is strictly prohibited.                        #
#  Copyright(c) 2004 by Sequans Communications. All Rights Reserved.        #
#                                                                           #
#############################################################################
#                                                                           #
# File        : deliver_palladium.csh                                       #
# Author      : Nicolas Vincent                                             #
# Creation    : July 02, 2012                                               #
#                                                                           #
# Description : delivery script for palladium                               #
#                                                                           #
#############################################################################

if (! -d ASIC) then
    echo "\033[31mError : ASIC link does not exist \033[0m"
    exit 1
endif

## Srcv
set SRCV_TOP="ASIC/srcv"
set REG_DIR="$SRCV_TOP/common/config_regs"
set FILELIST_ASIC="$SRCV_TOP/tops/shiva_top/file_list"
set SVNID_PALLADIUM_DELIVERY_FILE="ASIC/simv/tops/palladium/svnid_palladium_delivery"
set PALLADIUM_SVNID_FILE="palladiumSvnId.txt"

## Tools
set MAKEPP="/usr/bin/make"
set FILEPP="/opt/tools/filepp/filepp"
set PLACEBO_DIR="/delivery/PLACEBO"
set PLACEBO_VER="itf"

## Config
setenv HELP 0
setenv SAIL 0
setenv DELIV 0
setenv SEND_MAIL 0
#setenv CPU "MIPS MIPS_CLIENT MICO32-PPU MICO32-SPU MICO32-RPU LTEDSP"
setenv CPU "MIPS MIPS_CLIENT MICO32-PPU MICO32-SPU MICO32-RPU"
setenv FAMILY "sqn3210"
#setenv CPU "MIPS MIPS_CLIENT"

## Environment variable
setenv FILE_VERSION "$SRCV_TOP/common/sequans_library/version_number.v"


setenv PROBLEM 0


## Parsing command line
@ i = 1
while ( $i <= $#argv )
    switch ( $argv[$i] )
        case '-help':
            setenv HELP 1
            breaksw
        case '-sail':
            setenv SAIL 1
            breaksw
        case '-deliv':
            setenv DELIV 1
            breaksw
        case '-send_mail':
            setenv SEND_MAIL 1
            breaksw
        case '-svn_range_start'
            @ i ++
            set svn_range_start = $argv[$i]
            breaksw
        case '-regression_id'
            @ i ++
            set regression_id = $argv[$i]
            breaksw
        case '-message'
            @ i ++
            if ( $?message ) then
                set message = "$message\n </>$argv[$i]</>"
            else
                set message = "</>$argv[$i]</>"
            endif
            breaksw
        default:
            echo "\033[31mError : Unknown option $argv[$i]\033[0m"
            setenv HELP 1
            setenv PROBLEM 1
            breaksw
    endsw
    @ i ++
end

## Help message
if ( $HELP ) then
    echo "Valid options are :"
    echo "   -sail : generate sail registers"
    echo "   -deliv : deliver palladium design files and sail registers to /delivery"
    echo "   -send_mail : send mail for delivery to all concerned lists"
    echo "   -svn_range_start <svn_id> : force the revision start number for delivery"
    echo "   -regression_id 'id' : specify id(s) of regression for delivery mail"
    echo "   -message 'message' : Adds message to the delivery mail, (this option can be repeated"
    echo "   -help : display this message and exit"
    exit $PROBLEM
endif


## svn revision
echo "Retrieve svn information"
set svn_number=`svn info | grep Revision: | sed 's/Revision: //'`
set svn_range_end=${svn_number}
if (! $?svn_range_start ) then
    set svn_range_start=`cat ${SVNID_PALLADIUM_DELIVERY_FILE}`
endif


## file list passed to svnDelivery
echo "creating file list"
set MONITOR_FILE_LIST="file_list_parsed"
$FILEPP -o ${MONITOR_FILE_LIST} $FILELIST_ASIC
find ${REG_DIR}/tnc -type f >> ${MONITOR_FILE_LIST}



# Retrieve version
set MAJOR=`cat $FILE_VERSION | grep " MAJOR_VERSION_ASIC" | awk -F "'d" '{print $NF}'`
set MINOR=`cat $FILE_VERSION | grep " MINOR_VERSION_ASIC" | awk -F "'d" '{print $NF}'`
set ITERATION=${svn_number}

# Delivery directory
setenv DEL_DIR "/delivery/labo/OFDMA_${MAJOR}/${svn_number}/"

# Check svn revision coherency
if ( $SAIL ) then
    if ( ! -e ${PALLADIUM_SVNID_FILE} ) then
        echo "${PALLADIUM_SVNID_FILE} is not present, it is created when launching palladium compilation"
        echo "this file contains the svn id passed to verilog through SVN_VERSION define"
        echo "this file is used to check coherency between palladium compilation and palladium delivery"
        exit 1
    else
        set palladium_svn_id=`cat ${PALLADIUM_SVNID_FILE}`
        if ( ${palladium_svn_id} != $svn_range_end ) then
            echo "\033[31mError : palladium svn id (${palladium_svn_id}) and current svn version id (${svn_range_end}) are different\033[0m"
            exit 1
        endif
    endif
endif

#####################################################################
########## GENERATE SAIL FILES
#####################################################################

set cpu_word=`echo $CPU | wc -w`
if ( ( ($SAIL) ) && ($cpu_word != 0) ) then
    if (-d $REG_DIR/sail) then
        echo "\033[36m Generated the SAIL files\033[0m"
        pushd $REG_DIR/sail >& /dev/null

        # version
        set pl_ver=1.0
        set placebo_vers=`ls $PLACEBO_DIR`
        foreach placebo_ver ($placebo_vers)
            echo $placebo_ver | grep "${PLACEBO_VER}" > /dev/null
            if ($status == "0") then
                set ver=`echo $placebo_ver | awk -F "$PLACEBO_VER" '{print $NF}'`
                set diff=`expr $ver '>' $pl_ver`
                if ($diff) then
                    set pl_ver=$ver
                endif
            endif
        end

        # svn
        set pl_svn=0
        set placebo_svns=`ls $PLACEBO_DIR/${PLACEBO_VER}${pl_ver}`
        foreach placebo_svn ($placebo_svns)
            echo $placebo_svn | grep "${pl_ver}-r" > /dev/null
            if ($status == "0") then
                set svn=`echo $placebo_svn | awk -F "${pl_ver}-r" '{print $NF}'`
                if ($svn > $pl_svn) then
                    set pl_svn=$svn
                endif
            endif
        end

        # makefile
        foreach cpu_list ($CPU)
            echo $cpu_list | grep "MICO32-" > /dev/null
            if ($status == "0") then
                set sail_proc_param=`echo $cpu_list | awk -F "-" '{print $1}'`
                set accessor_param=`echo $cpu_list | awk -F "-" '{print $NF}'`
                set cmd="SAIL_PROC=$sail_proc_param ACCESSOR=$accessor_param"
            else
                set cmd="SAIL_PROC=$cpu_list"
            endif
            echo "\033[33m    $MAKEPP -s PL_VER=$pl_ver PL_SVN=$pl_svn $cmd\033[0m"
            #$MAKEPP -s PL_VER=$pl_ver PL_SVN=$pl_svn $cmd
            $MAKEPP -s PL_VER=$pl_ver PL_TMP_RELEASE=jmc $cmd
            set make_status=$status
            if ($make_status != "0") then
                echo "\033[31m#####################################"
                echo "##  ERROR : PROBLEM DURING SAIL FILES GENERATION"
                echo "#####################################\033[33m"
                set PROBLEM="1"
                exit -1
            endif
        end

        popd >& /dev/null
    endif
endif

#####################################################################
########## DELIVERY
#####################################################################

if ( ($PROBLEM == "0") ) then

    set CUR_DATE=`date +%x`
    set CUR_HOUR=`date +%T`

    echo "\n\n\033[36m########################################################"
    echo "########################################################"
    echo "##### BEGIN DELIVERY at $CUR_HOUR the $CUR_DATE"
    echo "########################################################"
    echo "########################################################\033[0m"

    set PALLA_DIRS=(QTDB PDB dbFiles cellList)
    foreach dir ($PALLA_DIRS)
        if !(-d $dir) then
            echo ""
            echo "\033[31m########################################################################"
            echo "#####                          ERROR"
            echo "##### Your palladium directory : '$dir'"
            echo "##### doesn't exist ..."
            echo "#####"
            echo "########################################################################\033[36m"
            echo ""
            exit -1
        endif
    end

    set tmp_delivery="`pwd`/tmp_delivery"
    echo "Create and fill temporary delivery folder: ${tmp_delivery}"
    mkdir -p ${tmp_delivery}

    set register_dir="${tmp_delivery}/Register"
    mkdir -p ${register_dir}
    ## sail
    mkdir -p ${register_dir}/sail
    # do not copy .svn and tmp folder
    set sail_files=`ls ${REG_DIR}/sail`
    foreach f (${sail_files})
        # take only folder created during sail generation (ie everything except tmp, gmake and Makefile)
        if ($f != "tmp" && $f != "Makefile" && $f != "gmake" ) then
            # create subfolder delivery dir (ie CLIENT, CPU, ...)
            mkdir -p ${register_dir}/sail/$f
            # copy only .h, .inc and .a
            find ${REG_DIR}/sail/$f -type f \( -name "*.a" -o -name "*.inc" -o -name "*.h" \) \
            -exec cp {} ${register_dir}/sail/$f \;
        endif
    end

    ## html
    mkdir -p ${register_dir}/html
    cp -r ${REG_DIR}/htm/* ${register_dir}/html
    cp $REG_DIR/qregisters/D0053_LTE_HW_SW_Interface.html ${register_dir}/html

    ## qregisters
    mkdir -p ${register_dir}/qregisters
    cp -r ${REG_DIR}/h/* ${register_dir}/qregisters
    cp -r ${REG_DIR}/qregisters/*.h ${register_dir}/qregisters

    ## common
    mkdir -p ${register_dir}/common
    # asic version
    echo "#define version_asic ${MAJOR}.${MINOR}.${ITERATION}" > ${register_dir}/common/version_asic.h
    # xml
    cp ${REG_DIR}/config_regs.xml ${register_dir}/common
    cp ${REG_DIR}/config_regs_edit.xml ${register_dir}/common
    cp ${REG_DIR}/qasara_regs_edit.xml ${register_dir}/common
    # h
    cp ${REG_DIR}/base_addresses_defs.h ${register_dir}/common

    if ( $DELIV ) then
        ## Create delivery folder
        echo "Create delivery folder : ${DEL_DIR}"
        mkdir -p ${DEL_DIR}

        # copy Register to delivery
        echo "Copy Registers in ${DEL_DIR}"
        cp -r ${register_dir} ${DEL_DIR}


        # create archive in delivery
        set archive="palladium_${svn_number}.tar.gz"
        set delivery="${DEL_DIR}/$archive"
        echo "Create palladium archive ${archive} in ${DEL_DIR}"
        tar czf $delivery ${PALLA_DIRS}

        set CUR_DATE=`date +%x`
        set CUR_HOUR=`date +%T`
        echo "\n\n\033[36m########################################################"
        echo "########################################################"
        echo "##### END DELIVERY ${delivery} at $CUR_HOUR the $CUR_DATE"
        echo "########################################################"
        echo "########################################################"
    else
        echo "No files delivered."
    endif
endif

echo "Sending mail"
set palladium_tool_rel=`vaelab --it_rel`
set filelist_args="--fileList $MONITOR_FILE_LIST"
set misc_args=""
set info_mail_file="info_mail.txt"

if ( ${SEND_MAIL} ) then
    set misc_args="--toAll"
    # Update svn id which will be used as svn_range_start for next delivery
    echo ${svn_range_end} > ${SVNID_PALLADIUM_DELIVERY_FILE}
    svn ci ${SVNID_PALLADIUM_DELIVERY_FILE} -m "<no_comment></> update palladium delivery id"
endif

echo "</>IXE version : ${palladium_tool_rel}</>" > ${info_mail_file}
if ( $?regression_id ) then
    echo "</>Regression ID : ${regression_id}</>" >> ${info_mail_file}
endif
if ( $?message ) then
    echo "$message" >> ${info_mail_file}
endif
set message_args="--message ${info_mail_file}"

set cmd="_svnDelivery.py --palladium ${misc_args} --svnrange ${svn_range_start}:${svn_range_end} --family $FAMILY --del_dir "${DEL_DIR}" $filelist_args $message_args"
echo "$cmd"

_svnDelivery.py --palladium ${misc_args} --svnrange ${svn_range_start}:${svn_range_end} --family $FAMILY --del_dir "${DEL_DIR}" $filelist_args --rel "${FAMILY}" ${message_args}


