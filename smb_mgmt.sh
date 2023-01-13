#!/bin/bash -e

declare -A SMB_MNT_INFOS
SMB_MNT_INFOS[U]="//SV-VLB-0001/users$/nicolas.vincent"
SMB_MNT_INFOS[S]="//SV-VLB-0001/services"
SMB_MNT_INFOS[R]="//SV-VLB-0002/ref"
SMB_MNT_INFOS[X]="//SV-VLB-0002/echange"

SMB_CRED="$HOME/.smbcred"

MOUNT=0
UMOUNT=0
DRIVES=""
DRIVE_LIST="U S R X"
RW=0
while [ $# -gt 0 ]; do
    key="$1"
    case ${key} in
        mount)
            MOUNT=1
            shift
            ;;
        -u)
            DRIVES="${DRIVES} U"
            shift
            ;;
        -s)
            DRIVES="${DRIVES} S"
            shift
            ;;
        -r)
            DRIVES="${DRIVES} R"
            shift
            ;;
        -x)
            DRIVES="${DRIVES} X"
            shift
            ;;
        -rw)
            RW=1
            shift
            ;;
        umount)
            UMOUNT=1
            shift
            ;;
        *)
            echo "Unknown option ${key}"
            exit 1
            ;;
    esac
done

if [ ${RW} -eq 1 ]; then
    DIR_MODE="0755"
    FILE_MODE="0644"
else
    DIR_MODE="0555"
    FILE_MODE="0444"
fi
USR_UID="$(id -u)"
USR_GID="$(id -g)"
MNT_OPTS="_netdev,credentials=${SMB_CRED},dir_mode=${DIR_MODE},file_mode=${FILE_MODE},uid=${USR_UID},gid=${USR_GID}"

if [ -z "${DRIVES}" ]; then
    DRIVES="U S R X"
fi

if [ ${MOUNT} -eq 1 ]; then
    for drive in ${DRIVES}; do
        mnt_point="/media/smb_${drive}"
        sudo mount.cifs ${SMB_MNT_INFOS[${drive}]} ${mnt_point} -o ${MNT_OPTS}
    done
fi

if [ ${UMOUNT} -eq 1 ]; then
    for drive in ${DRIVES}; do
        mnt_point="/media/smb_${drive}"
        sudo umount ${mnt_point}
    done
fi
