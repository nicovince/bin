#!/bin/sh

SMB_CRED="$HOME/.smbcred"
MNT_OPTS="_netdev,credentials=${SMB_CRED},dir_mode=0555,file_mode=0444,uid=500,gid=500"

MOUNT=0
UMOUNT=0
while [ $# -gt 0 ]; do
    key="$1"
    case ${key} in
        mount)
            MOUNT=1
            shift
            ;;
        umount)
            UMOUNT=1
            shift
            ;;
    esac
done

if [ ${MOUNT} -eq 1 ]; then
    sudo mount.cifs //SV-VLB-0001/users$/nicolas.vincent /media/smb_U/ -o ${MNT_OPTS}
    sudo mount.cifs //SV-VLB-0001/services /media/smb_S/               -o ${MNT_OPTS}
    sudo mount.cifs //SV-VLB-0002/ref /media/smb_R/                    -o ${MNT_OPTS}
    sudo mount.cifs //SV-VLB-0002/echange /media/smb_X/                -o ${MNT_OPTS}
fi

if [ ${UMOUNT} -eq 1 ]; then
    sudo umount /media/smb_U
    sudo umount /media/smb_S
    sudo umount /media/smb_R
    sudo umount /media/smb_X
fi
