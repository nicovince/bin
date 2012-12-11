#!/bin/bash
#setup tests

DISPATCH_USENET="../dispatch_usenet.py"
videosFolder="${PWD}/videosFolder"
OPTIONS="--verbose --no-mail"
rm -Rf nzb_*
rm -Rf dummy/
rm -Rf ${videosFolder}

mkdir ${videosFolder}

mkdir nzb_dummy
touch nzb_dummy/video_dummy.mp4

mkdir nzb_nomatch
touch nzb_nomatch/bambi.avi

echo "--- Should move video_dummy.mp4 to ${videosFolder}/dummy ---"
$DISPATCH_USENET --type "SUCCESS" \
                 --archiveName "nzb_dummy" \
                 --destDir "${PWD}/nzb_dummy" \
                 --elapsedTime "2m 43s" \
                 --parMessage "" \
                 --videosFolder "${videosFolder}" \
                 ${OPTIONS}

echo "--- Should find nothing ---"
$DISPATCH_USENET --type "SUCCESS" \
                 --archiveName "nzb_dummy" \
                 --destDir "${PWD}/nzb_dummy" \
                 --elapsedTime "2m 43s" \
                 --parMessage "" \
                 --videosFolder "${videosFolder}" \
                 ${OPTIONS}

echo "--- Should move nothing ---"
touch nzb_dummy/video_dummy.mp4
$DISPATCH_USENET --type "SUCCESS" \
                 --archiveName "nzb_dummy" \
                 --destDir "${PWD}/nzb_dummy" \
                 --elapsedTime "2m 43s" \
                 --parMessage "" \
                 --videosFolder "${videosFolder}" \
                 ${OPTIONS}

echo "--- Should move sample_dummy.mp4 to ${videosFolder}/dummy ---"
touch nzb_dummy/video_dummy.mp4
touch nzb_dummy/sample_dummy.mp4
$DISPATCH_USENET --type "SUCCESS" \
                 --archiveName "nzb_dummy" \
                 --destDir "${PWD}/nzb_dummy" \
                 --elapsedTime "2m 43s" \
                 --parMessage "" \
                 --videosFolder "${videosFolder}" \
                 ${OPTIONS}

echo "--- should not move anything ---"
$DISPATCH_USENET --type "SUCCESS" \
                 --archiveName "nzb_nomatch" \
                 --destDir "${PWD}/nzb_nomatch" \
                 --elapsedTime "2m 43s" \
                 --parMessage "" \
                 --videosFolder "${videosFolder}" \
                 ${OPTIONS}
