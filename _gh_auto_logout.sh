# This script is meant to be sourced, not executed
# shellcheck disable=SC2148

_gh_logged_users()
{
    if gh auth status 2> /dev/null 1>&2 ; then
        gh auth status -a --json hosts --jq '.hosts."github.com"[].login'
    fi
}

_is_gh_user_logged_in()
{
    local gh_user="$1"

    _gh_logged_users | grep -q "${gh_user}"
}

_login_user_cnt()
{
    who | awk -v u="$USER" '$1 == u {count++} END {print count+0}'
}

_gh_auto_logout()
{
    local gh_user="Nicolas-Vincent_vossloh"
    if [ "$(_login_user_cnt)" -gt 1 ]; then
        return
    fi


    if _is_gh_user_logged_in "${gh_user}" ; then
        gh auth logout --user "${gh_user}"
    fi
}

trap _gh_auto_logout EXIT
