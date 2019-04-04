#!/bin/bash
# Usage : gg_create_thumbnails.sh <directory>
# Create thumbnails of images present in directory in directory/.thumbs
# thumbnails already existing are not redone
IMG_EXT="jpg png JPG"

# Report list of image to generate a thumbnail of.
function gen_img_list()
{
  local img_dir=$1
  local thumbs_dir=$(realpath --relative-to=${img_dir} $2)
  pushd ${img_dir} > /dev/null
  for ext in ${IMG_EXT}; do
    # List image found under hierarchy, excluding the ones present in thumbs dir
    for img in $(find . -path ./${thumbs_dir} -prune -o -name "*.${ext}" -print); do
      # report image if it is not present in thumbs dir
      if [ ! -f ${thumbs_dir}/${img} ]; then
        echo ${img}
      fi
    done
  done
  popd > /dev/null
}

function create_thumbs()
{
  local img_dir=$1
  local img_list=$2
  local thumbs_dir=$3
  pushd $img_dir > /dev/null
  gm mogrify -output-directory ${thumbs_dir} -create-directories -resize 320x200 @${img_list}
  popd > /dev/null
}

IMAGE_DIR=$(realpath $1)
THUMBS_DIR=${IMAGE_DIR}/.thumbs

# Get list of thumbnails to create, and store them in a file
IMG_LIST=$(mktemp)
gen_img_list ${IMAGE_DIR} ${THUMBS_DIR} > ${IMG_LIST}
# Create thumbnails to thumbs directory
create_thumbs ${IMAGE_DIR} ${IMG_LIST} ${THUMBS_DIR}

# Remove file list
rm -f ${IMG_LIST}
