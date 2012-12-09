#!/bin/bash
#setup tests

videosFolder="${PWD}/videosFolder"
rm -Rf nzb_*
rm -Rf dummy/

mkdir nzb_dummy
touch nzb_dummy/video_dummy.mp4

mkdir nzb_nomatch
touch nzb_nomatch/bambi.avi

echo "--- Should move video_dummy.mp4 to ${videosFolder}/dummy ---"
../bin.dev/dispatch_usenet.py --type "SUCCESS" \
                              --archiveName "nzb_dummy" \
                              --destDir "/home/admin/dev/testing/nzb_dummy" \
                              --elapsedTime "2m 43s" \
                              --parMessage "" \
                              --videosFolder "${videosFolder}" \
                              --verbose

echo "--- Should find nothing ---"
../bin.dev/dispatch_usenet.py --type "SUCCESS" \
                              --archiveName "nzb_dummy" \
                              --destDir "/home/admin/dev/testing/nzb_dummy" \
                              --elapsedTime "2m 43s" \
                              --parMessage "" \
                              --videosFolder "${videosFolder}" \
                              --verbose

echo "--- Should move nothing ---"
touch nzb_dummy/video_dummy.mp4
../bin.dev/dispatch_usenet.py --type "SUCCESS" \
                              --archiveName "nzb_dummy" \
                              --destDir "/home/admin/dev/testing/nzb_dummy" \
                              --elapsedTime "2m 43s" \
                              --parMessage "" \
                              --videosFolder "${videosFolder}" \
                              --verbose

echo "--- Should move sample_dummy.mp4 to ${videosFolder}/dummy ---"
touch nzb_dummy/video_dummy.mp4
touch nzb_dummy/sample_dummy.mp4
../bin.dev/dispatch_usenet.py --type "SUCCESS" \
                              --archiveName "nzb_dummy" \
                              --destDir "/home/admin/dev/testing/nzb_dummy" \
                              --elapsedTime "2m 43s" \
                              --parMessage "" \
                              --videosFolder "${videosFolder}" \
                              --verbose

echo "--- should not move anything ---"
../bin.dev/dispatch_usenet.py --type "SUCCESS" \
                              --archiveName "nzb_nomatch" \
                              --destDir "/home/admin/dev/testing/nzb_nomatch" \
                              --elapsedTime "2m 43s" \
                              --parMessage "" \
                              --videosFolder "${videosFolder}" \
                              --verbose
