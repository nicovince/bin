#!/bin/bash
# Functions from creating konsoles.


#####################################################################
# Create new console.
function create_konsole()
{
    local basename=$(date +"%H%M%N")
    local name=$basename"_konsoleX1_"
    local kstart_options=$1
    local konsole_options=$2
    kstart $kstart_options --window $name konsole $konsole_options --script -T $name >/dev/null 2>&1
    local konsole_id=konsole-$(ps aux | grep konsole | grep -v grep | grep $name | awk '{print $2}')
    echo $konsole_id
}

#####################################################################
# Wait to make sure the session count equals $1.
function wait_for_session()
{
    local konsole_id=$1
    local count=$2
    local session_count=$(dcop $konsole_id konsole sessionCount 2>/dev/null)
    while [[ $session_count -ne $count ]]
    do
        sleep 0.1
        session_count=$(dcop $konsole_id konsole sessionCount)
    done
}

#####################################################################
# Start sessions in konsole.
function start_sessions()
{
    local konsole_id=$1
    local nsessions=1
    local session_count=${#sessions[*]}
    local i=0

    while [[ $i -lt $session_count ]]
    do
        local name=${sessions[$i]}
        let i++
        local user=${sessions[$i]}
        let i++
        local machine=${sessions[$i]}
        let i++
        local command=${sessions[$i]}
        let i++
        dcop $konsole_id $session_id renameSession "$name"
        if [ "$user" = "fpga" ]; then
            dcop $konsole_id $session_id sendSession "ssf"
        fi
        if [ -n "$machine" ]; then
            dcop $konsole_id $session_id sendSession "ssh -XY $machine"
        fi
        dcop $konsole_id $session_id sendSession "$command"

        if [[ $i -lt $session_count ]]; then
            let nsessions++
            local session_id=$(dcop $konsole_id konsole newSession)
            wait_for_session $konsole_id $nsessions
            sleep 1
        fi
    done
}


#####################################################################
# Start sessions in konsole.
function setup_win()
{
    local desktop=$1
    konsole_id=$(create_konsole "--iconify --desktop $desktop")
    wait_for_session 1
    sleep 1
    
    session_id=$(dcop $konsole_id konsole currentSession)
    first_session_id=$session_id
    sleep 1
    
    start_sessions $konsole_id
    
    dcop $konsole_id konsole activateSession $first_session_id
    sleep 0.1
    dcop $konsole_id 'konsole-mainwindow#1' restore
    sleep 0.1
    dcop $konsole_id 'konsole-mainwindow#1' setGeometry 50 50 1000 700
}




#####################################################################
#####################################################################
# USER PART
#####################################################################
#####################################################################

# Format :
# tabName  user  machine  command
# setup_win bureau

## Mail
sessions=(
    "tb"                ""  "" "setenv VERTOOLS 'default' && setenv RELTOOLS 'draftTools' && source /tools/tools_env/draftTools/source_tools.csh && thunderbird"
    "chrome"            ""  "richebourg" "unsetenv LD_LIBRARY_PATH && google-chrome"
    "firefox"           ""  "" "setenv VERTOOLS 'default' && setenv RELTOOLS 'draftTools' && source /tools/tools_env/draftTools/source_tools.csh && firefox"
    "weekly"            ""  "" "vimweekly"
    "sap"               ""  "" ""
    "foo"               ""  "" ""
)
setup_win 1

######################################################################
# palladium
sessions=(
    "repo"        "" "" "setenv VERTOOLS 'default' && setenv RELTOOLS 'draftTools' && source /tools/tools_env/draftTools/source_tools.csh && cd ~/work/Project_Mongoose/Mongoose_palladium"
    "Palladium9"         "" "mazis" "cd ~/work/Project_Mongoose/Mongoose_palladium/top/simv/tops/palladium/pi_test/titanic/9_domains"
    "Palladium6A"        "" "mazis" "cd ~/work/Project_Mongoose/Mongoose_palladium/top/simv/tops/palladium/pi_test/titanic/6A_domains"
    "Palladium6B"        "" "mazis" "cd ~/work/Project_Mongoose/Mongoose_palladium/top/simv/tops/palladium/pi_test/titanic/6B_domains"
)
#setup_win 3

######################################################################
# lpctrl
lpctrl_sessions=(
    "svn.lp"     "" "" "cd ~/work/SQN3210/SQN3210_integration/"
    "vim.lp"     "" "" "cd ~/work/SQN3210/SQN3210_integration/"
    "regs.lp"    "" "" "cd ~/work/SQN3210/SQN3210_integration/srcv/common/config_regs"
    "foo.lp"     "" "" "cd ~/work/SQN3210/SQN3210_integration"
    "sim.lp"     "" "" "cd ~/work/SQN3210/SQN3210_integration/simv"
)
#setup_win 3

######################################################################
# fpga
sessions=(
    "svn.fpga"     "" "" "cd ~/work/SQN3210/SQN3210_FPGA/"
    "vim.fpga"     "" "" "cd ~/work/SQN3210/SQN3210_FPGA/"
    "regs.fpga"    "" "" "cd ~/work/SQN3210/SQN3210_FPGA/srcv/common/config_regs"
    "foo.fpga"     "" "" "cd ~/work/SQN3210/SQN3210_FPGA"
    "sim.fpga"     "" "" "cd ~/work/SQN3210/SQN3210_FPGA/simv"
)
#setup_win 8

######################################################################
# Env
sessions=(
    "git.envC"           ""  ""       "setenv VERTOOLS 'default' && setenv RELTOOLS 'draftTools' && source /tools/tools_env/draftTools/source_tools.csh && cd ~/work/ENV/git/envC"
    "git.swenv"          ""  ""       "setenv VERTOOLS 'default' && setenv RELTOOLS 'draftTools' && source /tools/tools_env/draftTools/source_tools.csh && cd ~/work/ENV/git/swenv"
    "foo"                ""  ""       "cd ~/work/ENV/git/"
    "compil.envC"        ""  "aloxe" "cd ~/work/ENV/git/envC && sc gcc64_ccss2009_ius12_1 && ./deliverCompile.csh -r draftNvincent"
    "compil.swenv"       ""  "aloxe" "cd ~/work/ENV/git/swenv && sc gcc64_ccss2009_ius12_1 && ./deliverCompile.csh -r draftNvincent"
    "testCase"           ""  ""       "~/work/ENV/TestCaseCadence45393898"
    "sim.SceMi"          ""  ""       "cd ~/work/ENV/git/swenv/simv/testSceMi/sce0"
    "edith"              ""  "aloxe" "cd ~/work/Project_Mongoose/Mongoose/top/simv/tops/shiva_top/dlp_scenarios/sce_csirs"
)
setup_win 6
sessions=(
    "git.envC"           ""  "" "setenv VERTOOLS 'default' && setenv RELTOOLS 'draftTools' && source /tools/tools_env/draftTools/source_tools.csh && cd ~/work/ENV/git/envC"
    "git.swenv"          ""  "" "setenv VERTOOLS 'default' && setenv RELTOOLS 'draftTools' && source /tools/tools_env/draftTools/source_tools.csh && cd ~/work/ENV/git/swenv"
    "vim.envC"           ""  "" "cd ~/work/ENV/git/envC"
    "vim.swenv"          ""  "" "cd ~/work/ENV/git/swenv"
    "draft"              ""  "" "cd /delivery/lib/draftNvincent/"
    "foo"                ""  "" "cd ~/work/env/git/"
    "sim.SceMi"          ""  "" "cd ~/work/ENV/git/swenv/simv/testSceMi/sce0"
    "sim.reg"            ""  "" "cd ~/work/ENV/git/swenv/simv/genreg/macros/city"
)
setup_win 6

######################################################################
## integration
integration_sessions=(
    "svn"        "" "" "cd ~/work/SQN3210/SQN3210_integration"
    "vim"        "" "" "cd ~/work/SQN3210/SQN3210_integration"
    "scapa"      "" "" "cd ~/work/SQN3210/SQN3210_integration/simv"
    "foo"        "" "" "cd ~/work/SQN3210/SQN3210_integration"
    "sim"        "" "" "cd ~/work/SQN3210/SQN3210_integration/simv"
)
#setup_win 8

######################################################################
## delivEnv
sessions=(
    "deliv.envC"      "" "" "setenv VERTOOLS 'default' && setenv RELTOOLS 'draftTools' && source /tools/tools_env/draftTools/source_tools.csh && cd ~/work/ENV/delivery/envC"
    "deliv.Swenv"     "" "" "setenv VERTOOLS 'default' && setenv RELTOOLS 'draftTools' && source /tools/tools_env/draftTools/source_tools.csh && cd ~/work/ENV/delivery/swenv"
    "compil.envC"     "" "aloxe" "cd ~/work/ENV/delivery/envC"
    "compil.Swenv"    "" "aloxe" "cd ~/work/ENV/delivery/swenv"
    "vim.envC"        "" "" "cd ~/work/ENV/delivery/envC"
    "vim.Swenv"       "" "" "cd ~/work/ENV/delivery/swenv"
    "Scapa.rel"       "" "" "cd ~/work/nobackup/reg2/SQN3210/simv"
    "foo"             "" "" "echo https://s3lte.sequans.com/doku.php?id=private:ic-bb:envlibdelivery"
)
#setup_win 7

######################################################################
## viterbi
sessions=(
    "repo"       "" "" "cd ~/work/Project_Mongoose/MongooseFix"
    "git"        "" "" "cd ~/work/Project_Mongoose/MongooseFix/downlink"
    "vim"        "" "" "cd ~/work/Project_Mongoose/MongooseFix/downlink"
    "foo"        "" "" "cd ~/work/Project_Mongoose/MongooseFix"
    "sim"        "" "" "cd ~/work/Project_Mongoose/MongooseFix/downlink"
)
#setup_win 5

######################################################################
## tfcp
sessions=(
    "repo"       "" "" "setenv VERTOOLS 'default' && setenv RELTOOLS 'draftTools' && source /tools/tools_env/draftTools/source_tools.csh && cd ~/work/Project_Mongoose/Mongoose"
    "git"        "" "" "setenv VERTOOLS 'default' && setenv RELTOOLS 'draftTools' && source /tools/tools_env/draftTools/source_tools.csh && cd ~/work/Project_Mongoose/Mongoose"
    "vim"        "" "" "cd ~/work/Project_Mongoose/Mongoose"
    "sim"        "" "" "cd ~/work/Project_Mongoose/Mongoose/top/simv/tops/shiva_top/dlp_scenarios/sce_max_size_cat4"
    "log"        "" "" "cd ~/work/Project_Mongoose/Mongoose/top/simv/tops/shiva_top/dlp_scenarios/sce_max_size_cat4"
    "foo"        "" "" ""
)
#setup_win 2
#setup_win 2

######################################################################
## iopad mux
sessions=(
    "repo"        "" "" "cd ~/work/Project_Mongoose/Mongoose"
    "git.scripts" "" "" "cd ~/work/Project_Mongoose/Mongoose/scripts"
    "vim"         "" "" "cd ~/work/Project_Mongoose/Mongoose"
    "shiva_top"   "" "" "cd ~/work/Project_Mongoose/Mongoose/shiva_top"
    "iopadmux"    "" "" "cd ~/work/Project_Mongoose/Mongoose/scripts/iopadmux"
)
#setup_win 3
#setup_win 3


######################################################################
## uart
sessions=(
    "repo"        "" "" "cd ~/work/Project_Mongoose/Mongoose"
    "git.top"     "" "" "cd ~/work/Project_Mongoose/Mongoose/top"
    "vim"         "" "" "cd ~/work/Project_Mongoose/Mongoose"
    "envC"        "" "" "cd ~/work/ENV/git/envC"
    "swenv"       "" "" "cd ~/work/ENV/git/swenv"
    "foo"         "" "" "cd ~/work/Project_Mongoose/Mongoose"
)
#setup_win 8

sessions=(
    "repo"        "" "" "cd ~/work/Project_Mongoose/Mongoose"
    "git.top"     "" "" "cd ~/work/Project_Mongoose/Mongoose/top"
    "vim"         "" "" "cd ~/work/Project_Mongoose/Mongoose"
    "envC"        "" "" "cd ~/work/ENV/git/envC"
    "swenv"       "" "" "cd ~/work/ENV/git/swenv"
    "simv"        "" "" "cd ~/work/Project_Mongoose/Mongoose/top/simv/tops/shiva_top/uart_scenarios/sce_uart0_basic && echo 'make -f ../../GNUmakefile VERLIB=rel5-2.2p2 all'"
)
#setup_win 8

######################################################################
# Mongoose_trunk
sessions=(
    "repo"        "" "" "cd ~/work/Project_Mongoose/Mongoose_trunk"
    "git"         "" "" "cd ~/work/Project_Mongoose/Mongoose_trunk/top"
    "vim"         "" "" "cd ~/work/Project_Mongoose/Mongoose_trunk"
    "gen"         "" "mazis" "sc janus && cd ~/work/Project_Mongoose/Mongoose_Palladium/top/simv/tops/palladium/pi_test/titanic/sce0"
)


######################################################################
# gls
sessions=(
    "repo"        "" "" "cd ~/work/Project_Mongoose/Mongoose"
    "git"         "" "" "cd ~/work/Project_Mongoose/Mongoose/top"
    "vim"         "" "" "cd ~/work/Project_Mongoose/Mongoose"
    "sim.gate"    "" "aloxe" "sc default_64 && cd ~/work/Project_Mongoose/Mongoose/top/simv/tops/shiva_top/platform_scenario/sce_bank_id"
    "log.gate"    "" "" "cd ~/work/Project_Mongoose/Mongoose/top/simv/tops/shiva_top/platform_scenario/sce_bank_id"
    "simvision.gate"    "" "aloxe" "sc default_64 && cd ~/work/Project_Mongoose/Mongoose/top/simv/tops/shiva_top/platform_scenario/sce_bank_id"
)

setup_win 2
sessions=(
    "repo"        "" "" "cd ~/work/Project_Mongoose/Mongoose"
    "git"         "" "" "cd ~/work/Project_Mongoose/Mongoose/top"
    "vim"         "" "" "cd ~/work/Project_Mongoose/Mongoose"
)
setup_win 2

######################################################################
# gls shared
sessions=(
    "repo"        "" "" "cd ~/work/Project_Mongoose/Mongoose_gls_top"
    "git"         "" "" "cd ~/work/Project_Mongoose/Mongoose_gls_top/top"
    "vim"         "" "" "cd ~/work/Project_Mongoose/Mongoose_gls_top"
    "sim.gate"    "" "aloxe" "sc default_64 && cd ~/work/Project_Mongoose/Mongoose_gls_top/top/simv/tops/shiva_top/platform_scenario/sce_bank_id"
    "log.gate"    "" "" "cd ~/work/Project_Mongoose/Mongoose_gls_top/top/simv/tops/shiva_top/platform_scenario/sce_bank_id"
    "simvision.gate"    "" "aloxe" "sc default_64 && cd ~/work/Project_Mongoose/Mongoose_gls_top/top/simv/tops/shiva_top/platform_scenario/sce_bank_id"
)

setup_win 3
sessions=(
    "repo"        "" "" "cd ~/work/Project_Mongoose/Mongoose_gls_top"
    "git"         "" "" "cd ~/work/Project_Mongoose/Mongoose_gls_top/top"
    "vim"         "" "" "cd ~/work/Project_Mongoose/Mongoose_gls_top"
)
setup_win 3

######################################################################
# gls new macros
sessions=(
    "repo"        "" "" "cd ~/work/Project_Mongoose/Mongoose_gls_new_macros"
    "git"         "" "" "cd ~/work/Project_Mongoose/Mongoose_gls_new_macros/top"
    "vim"         "" "" "cd ~/work/Project_Mongoose/Mongoose_gls_new_macros"
    "sim.gate"    "" "aloxe" "sc default_64 && cd ~/work/Project_Mongoose/Mongoose_gls_new_macros/top/simv/tops/shiva_top/setup_gls/sce0"
    "log.gate"    "" "" "cd ~/work/Project_Mongoose/Mongoose_gls_new_macros/top/simv/tops/shiva_top/setup_gls/sce0"
    "simvision.gate"    "" "aloxe" "sc default_64 && cd ~/work/Project_Mongoose/Mongoose_gls_new_macros/top/simv/tops/shiva_top/setup_gls/sce0"
)

setup_win 4
sessions=(
    "repo"        "" "" "cd ~/work/Project_Mongoose/Mongoose_gls_new_macros"
    "git"         "" "" "cd ~/work/Project_Mongoose/Mongoose_gls_new_macros/top"
    "vim"         "" "" "cd ~/work/Project_Mongoose/Mongoose_gls_new_macros"
)
setup_win 4

######################################################################
# I2S v2
setup_win 8
sessions=(
    "repo"        "" "" "cd ~/work/Project_Mongoose/Janus_i2s_v2_dev"
    "git"         "" "" "cd ~/work/Project_Mongoose/Janus_i2s_v2_dev/top"
    "vim"         "" "" "cd ~/work/Project_Mongoose/Janus_i2s_v2_dev"
)
setup_win 8

