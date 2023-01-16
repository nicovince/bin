#!/bin/bash -e

# Use provided GIT_CREDENTIALS file or use default.
GIT_CREDENTIALS="${GIT_CREDENTIALS:=${HOME}/.git-credentials}"
GH_HOSTS="${GH_HOSTS:=${HOME}/.config/gh/hosts.yml}"

help()
{
    echo "Usage: $(basename $0) [-h | --help] <github username>"
    echo ""
    echo "Patch tokens in .git-credentials and gh's config files."
}

patch_git_credentials()
{
    local gh_username="$1"
    local gh_token="$2"

    if [ -z "$gh_username" ]; then
        echo "error: github username must not be empty"
        exit 1
    fi
    sed -i "s/\(${gh_username}\):\([^@]\+\)/\1:${gh_token}/" ${GIT_CREDENTIALS}
}

patch_gh_host()
{
    local gh_token="$1"

    sed -i "s/\(oauth_token: \).*/\1${gh_token}/g" ${GH_HOSTS}
}

# Parse command line arguments
PARAMS=""
while [ $# -gt 0 ]; do
    key="$1"
    case ${key} in
        -h|--help)
            help
            exit 0
            ;;
        *)
            PARAMS="${PARAMS} ${1}"
            shift
            ;;
    esac
done
eval set -- "${PARAMS}"

if [ -z "$1" ]; then
    echo "error: Missing github username"
    help
    exit 1
fi
GH_USERNAME="$1"

echo -n "Github Token:"
read -s token
echo

echo "Update credentials for github user ${GH_USERNAME} in ${GIT_CREDENTIALS} and ${GH_HOSTS}"
if [ -f "${GIT_CREDENTIALS}" ]; then
    echo "Update credentials for ${GH_USERNAME} in ${GIT_CREDENTIALS}"
    patch_git_credentials "${GH_USERNAME}" "${token}"
fi
if [ -f "${GH_HOSTS}" ]; then
    echo "Update credentials in ${GH_HOSTS}"
    patch_gh_host "${token}"
fi

echo "Update manually pass store:"
echo "pass git pull && pass edit www/github.com/token-git-cli@${HOSTNAME} && pass git push"
