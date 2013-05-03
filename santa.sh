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
    "tb"                ""  "" "thunderbird"
    "chrome"            ""  "richebourg" "google-chrome"
    "weekly"            ""  "" "vimweekly"
    "sap"               ""  "" ""
    "foo"               ""  "" ""
)
setup_win 1

######################################################################
# palladium
palladium_sessions1=(
    "svn"        "" "" "cd ~/work/SQN3210/SQN3210_palladium/"
    "vim"        "" "" "cd ~/work/SQN3210/SQN3210_palladium"
    "gen_palla"  "" "montrecul" "cd ~/work/SQN3210/SQN3210_palladium/simv/tops/palladium/pi_test/titanic/sce0"
    "foo"        "" "" "cd ~/work/SQN3210/SQN3210_palladium"
)
#setup_win 2

palladimu_sessions2=(
    "regs"        "" "" "cd /home/nvincent/work/SQN3210/SQN3210_palladium/srcv/common/config_regs"
    "sail"        "" "" "cd ~/work/SQN3210/SQN3210_palladium/srcv/common/config_regs/sail"
    "vim"        "" "" "cd ~/work/SQN3210/SQN3210_palladium"
    "foo"        "" "" "cd ~/work/SQN3210/SQN3210_palladium"
)
#setup_win 2

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
    "git.envC"           ""  ""       "cd ~/work/ENV/git/envC"
    "git.swenv"          ""  ""       "cd ~/work/ENV/git/swenv"
    "3210"               ""  ""       "cd ~/work/SQN3210/SQN3210_trunk"
    "foo"                ""  ""       "ce ~/work/ENV/git/"
    "compil.envC"        ""  "montrecul" "cd ~/work/ENV/git/envC && sc gcc64_ccss2009_ius12_1 && echo compileEnvC.sh -lib draftNvincent"
    "compil.swenv"       ""  "montrecul" "cd ~/work/ENV/git/swenv && sc gcc64_ccss2009_ius12_1 && echo 'compileSwenv.sh -lib draftNvincent'"
    "testCase"           ""  ""       "~/work/ENV/TestCaseCadence45393898"
    "sim.SceMi"          ""  ""       "cd ~/work/ENV/git/swenv/simv/testSceMi/sce0"
)
setup_win 6
sessions=(
    "git.envC"           ""  "" "cd ~/work/ENV/git/envC"
    "git.swenv"          ""  "" "cd ~/work/ENV/git/swenv"
    "vim.envC"           ""  "" "cd ~/work/ENV/git/envC"
    "vim.swenv"          ""  "" "cd ~/work/ENV/git/swenv"
    "3210"               ""  "" "cd ~/work/SQN3210/SQN3210_integration"
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
    "deliv.envC"      "" "" "cd ~/work/ENV/delivery/envC"
    "deliv.Swenv"     "" "" "cd ~/work/ENV/delivery/swenv"
    "compil.envC"     "" "montrecul" "cd ~/work/ENV/delivery/envC"
    "compil.Swenv"    "" "montrecul" "cd ~/work/ENV/delivery/swenv"
    "vim.envC"        "" "" "cd ~/work/ENV/delivery/envC"
    "vim.Swenv"       "" "" "cd ~/work/ENV/delivery/swenv"
    "Scapa.rel"       "" "" "cd ~/work/nobackup/reg2/SQN3210/simv"
    "foo"             "" "" "echo https://s3lte.sequans.com/doku.php?id=private:ic-bb:envlibdelivery"
)
#setup_win 7

######################################################################
## trunk
sessions=(
    "svn"        "" "" "cd ~/work/SQN3210/SQN3210_trunk"
    "vim"        "" "" "cd ~/work/SQN3210/SQN3210_trunk"
    "scapa"      "" "" "cd ~/work/SQN3210/SQN3210_trunk/simv"
    "foo"        "" "" "cd ~/work/SQN3210/SQN3210_trunk"
    "sim"        "" "" "cd ~/work/SQN3210/SQN3210_trunk/simv"
)
setup_win 5

######################################################################
## tfcp
sessions=(
    "repo"       "" "" "cd ~/work/Project_Mongoose/Mongoose"
    "git.dsproc" "" "" "cd ~/work/Project_Mongoose/Mongoose/lte_top_dsproc"
    "vim"        "" "" "cd ~/work/Project_Mongoose/Mongoose"
    "dsproc"     "" "" "cd ~/work/Project_Mongoose/Mongoose/lte_top_dsproc"
    "sim"        "" "" "cd ~/work/Project_Mongoose/Mongoose/lte_top_dsproc/simv"
)
setup_win 2
setup_win 2

######################################################################
## iopad mux
sessions=(
    "repo"        "" "" "cd ~/work/Project_Mongoose/Mongoose"
    "git.scripts" "" "" "cd ~/work/Project_Mongoose/Mongoose/scripts"
    "vim"         "" "" "cd ~/work/Project_Mongoose/Mongoose"
    "shiva_top"   "" "" "cd ~/work/Project_Mongoose/Mongoose/shiva_top"
    "iopadmux"    "" "" "cd ~/work/Project_Mongoose/Mongoose/scripts/iopadmux"
)
setup_win 3
setup_win 3


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
setup_win 8

sessions=(
    "repo"        "" "" "cd ~/work/Project_Mongoose/Mongoose"
    "git.top"     "" "" "cd ~/work/Project_Mongoose/Mongoose/top"
    "vim"         "" "" "cd ~/work/Project_Mongoose/Mongoose"
    "envC"        "" "" "cd ~/work/ENV/git/envC"
    "swenv"       "" "" "cd ~/work/ENV/git/swenv"
    "simv"        "" "" "cd ~/work/Project_Mongoose/Mongoose/top/simv/tops/shiva_top/uart_scenarios/sce_uart0_basic && echo 'make -f ../../GNUmakefile VERLIB=rel5-2.2p0 all'"
)
setup_win 8


######################################################################
# palladium
sessions=(
    "repo"        "" "" "cd ~/work/Project_Mongoose/Mongoose_Palladium"
    "git.top"     "" "" "cd ~/work/Project_Mongoose/Mongoose_Palladium/top"
    "vim"         "" "" "cd ~/work/Project_Mongoose/Mongoose_Palladium"
    "gen"         "" "mazis" "sc janus && cd ~/work/Project_Mongoose/Mongoose_Palladium/top/simv/tops/palladium/pi_test/titanic/sce0"
)
