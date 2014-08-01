# Install tools stuff for asic team

if ($?NEWT) then
    if !($?VERTOOLS) then
        setenv VERTOOLS "default"
    endif
    setenv RELTOOLS "latest2"
    if (-e /tools/tools_env/$RELTOOLS/source_tools.csh) then
        source /tools/tools_env/$RELTOOLS/source_tools.csh
    endif
else
    if !($?VERTOOLS) then
        setenv VERTOOLS "default"
    endif
    setenv RELTOOLS "latest"
    alias repo '/tools/google/repo/bin/repo'
    if (-e /delivery/tools_env/$RELTOOLS/source_tools.csh) then
        source /delivery/tools_env/$RELTOOLS/source_tools.csh
    endif
endif

# Setup sge (grid engine)
#setenv PATH /opt/sge/bin/lx-amd64:$PATH
#source /opt/sge/sequans/common/settings.csh
