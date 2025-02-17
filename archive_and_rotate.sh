#!/bin/bash -e
# Perform a backup of a single file or folder
# crontab -e
# 0 0 * * * /home/nicolas/bin/archive_and_rotate.sh /home/nicolas/.bash_history --infix daily
# 0 0 * * 1 /home/nicolas/bin/archive_and_rotate.sh /home/nicolas/.bash_history --infix weekly
# 0 0 1 * * /home/nicolas/bin/archive_and_rotate.sh /home/nicolas/.bash_history --infix montly
# 0 0 1 1 * /home/nicolas/bin/archive_and_rotate.sh /home/nicolas/.bash_history --infix yearly

DEST_BACKUP="${HOME}/backups"
SCRIPTNAME="$(basename "$0")"

usage()
{
    cat <<EOF
${SCRIPTNAME} Perform a backup of a single file or folder.

Usage: ${SCRIPTNAME} <file> [-i|--infix <backup infix>]

    <file>: File or folder to backup.
    -i, --infix <backup infix>:
        Specify the infix set between timestamp and filename on bakcup filename.
    -h, --help:
        Show this help and exit.
EOF




}

get_timestamp()
{
    date +%Y%m%d-%H%M%S
}

get_archive_name_suffix()
{
    filename="$1"
    period="$2"
    suffix="${period}_${filename}.tar.gz"
    echo "${suffix}"
}

get_archive_name()
{
    filename="$1"
    period="$2"
    suffix="$(get_archive_name_suffix "${filename}" "${period}")"
    archive_filename="$(get_timestamp)_${suffix}"
    echo "${archive_filename}"
}

# Archive a single file or single folder into destination.
# The period is stored in the archived filename.
archive()
{
    filepath="$(realpath "$1")"
    dest_folder="$(realpath "$2")"
    period="${3:-oneshot}"
    pushd "$(dirname "${filepath}")" > /dev/null
    archive_name="${dest_folder}/$(get_archive_name "$(basename "${filepath}")" "${period}")"
    mkdir -p "${dest_folder}"

    tar czf "${archive_name}" "$(basename "${filepath}")"
}

# Keep the last archive
clean_archive()
{
    file_suffix="$1"
    archive_folder=$2
    n=7
    ls "${archive_folder}"/*"${file_suffix}" | head -n -"${n}" | xargs rm -f
}

archive_and_clean()
{
    filepath="$1"
    dest_folder="$2"
    period="${3:-oneshot}"
    archive_suffix="$(get_archive_name_suffix "$(basename "${filepath}")" "${period}")"
    archive "${filepath}" "${dest_folder}" "${period}"
    clean_archive "${archive_suffix}" "${dest_folder}"
}

INFIX="oneshot"
PARAMS=""
while [ $# -gt 0 ]; do
    case $1 in
        -i|--infix)
            INFIX="$2"
            shift
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            PARAMS="${PARAMS} ${1}"
            ;;
    esac
    shift
done
eval set -- "${PARAMS}"

if [ $# -ne 1 ]; then
    echo 'Invalid number of arguments'
    usage
    exit 1
fi

archive_and_clean "$1" "${DEST_BACKUP}" "${INFIX}"
