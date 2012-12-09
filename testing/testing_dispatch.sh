#!/bin/bash
#setup tests

DISPATCH_USENET="../dispatch_usenet.py"
videosFolder="${PWD}/videosFolder"
rm -Rf nzb_*
rm -Rf dummy/

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
                 --verbose

echo "--- Should find nothing ---"
$DISPATCH_USENET --type "SUCCESS" \
                 --archiveName "nzb_dummy" \
                 --destDir "${PWD}/nzb_dummy" \
                 --elapsedTime "2m 43s" \
                 --parMessage "" \
                 --videosFolder "${videosFolder}" \
                 --verbose

echo "--- Should move nothing ---"
touch nzb_dummy/video_dummy.mp4
$DISPATCH_USENET --type "SUCCESS" \
                 --archiveName "nzb_dummy" \
                 --destDir "${PWD}/nzb_dummy" \
                 --elapsedTime "2m 43s" \
                 --parMessage "" \
                 --videosFolder "${videosFolder}" \
                 --verbose

echo "--- Should move sample_dummy.mp4 to ${videosFolder}/dummy ---"
touch nzb_dummy/video_dummy.mp4
touch nzb_dummy/sample_dummy.mp4
$DISPATCH_USENET --type "SUCCESS" \
                 --archiveName "nzb_dummy" \
                 --destDir "${PWD}/nzb_dummy" \
                 --elapsedTime "2m 43s" \
                 --parMessage "" \
                 --videosFolder "${videosFolder}" \
                 --verbose

echo "--- should not move anything ---"
$DISPATCH_USENET --type "SUCCESS" \
                 --archiveName "nzb_nomatch" \
                 --destDir "${PWD}/nzb_nomatch" \
                 --elapsedTime "2m 43s" \
                 --parMessage "" \
                 --videosFolder "${videosFolder}" \
                 --verbose
