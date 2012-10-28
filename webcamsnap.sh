#!/bin/bash

#mplayer tv:// -frames 10 -tv fps=5:driver=v4l2:width=640:height=480:device=/dev/video0 -vo jpeg
#convert 000000??.jpg -average frame.jpg 


DEVICE="/dev/video0"
WIDTH="640"
HEIGHT="480"


print_help()
{
  echo "Usage : webcamsnap.sh -f output"
  echo "This script will take multiple snapshots from webcam and make an average of the photos to reduce noise"
  echo "Valid options are :"
  echo " -f, --file OUTPUT_FILE : specify output file name"
  echo " -d, --delete : delete temp folder where captures are stored"
  echo " -h, --help : display this help and exit"
}



delete=0
while [ $# -ne 0 ]; do
  case $1 in
    -f|--file)
      outfile=$2
      shift;;
    -d|--delete)
      delete=1;;
    -h|--help)
      print_help
      exit 0;;
    *)
      echo "Unknown option $1"
      exit 1;;
  esac
  shift
done


folder_out=${outfile%.*}
mkdir $folder_out

#take snapshots
mplayer tv:// -frames 10 -tv fps=5:driver=v4l2:width=$WIDTH:height=$HEIGHT:device=$DEVICE -vo jpeg:outdir=${folder_out}

#smooth image ${outfile}
convert $folder_out/000000??.jpg -average $outfile

# rm tmp folder
if [ $delete -eq 1 ]; then
  rm -Rf $folder_out
fi
