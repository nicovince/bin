#!/bin/bash
# Usage : gg_create_thumbnails.sh <directory>
# Create thumbnails of images present in directory in directory/.thumbs
# thumbnails already existing are not redone
IMG_EXT="jpg png"

# Report list of image to generate a thumbnail of.
function gen_img_list()
{
  local img_dir=$1
  local thumbs_dir=$2
  for ext in ${IMG_EXT}; do
    # List image found under hierarchy, excluding the ones present in thumbs dir
    for img in $(find ${img_dir} -path ${thumbs_dir} -prune -o -name "*.${ext}" -print); do
      # report image if it is not present in thumbs dir
      if [ ! -f ${thumbs_dir}/${img} ]; then
        echo ${img}
      fi
    done
  done
}

function create_thumbs()
{
  local img_list=$1
  local thumbs_dir=$2
  gm mogrify -output-directory ${thumbs_dir} -create-directories -resize 320x200 @${img_list}
}

IMAGE_DIR=$1
THUMBS_DIR=${IMAGE_DIR}/.thumbs

# Get list of thumbnails to create, and store them in a file
IMG_LIST=$(mktemp)
gen_img_list ${IMAGE_DIR} ${THUMBS_DIR} > ${IMG_LIST}
# Create thumbnails to thumbs directory
create_thumbs ${IMG_LIST} ${THUMBS_DIR}

# Remove file list
rm -f ${IMG_LIST}
