#!/bin/bash
BIN_DIR=$(dirname $(realpath $0))
GALLERY_ROOT=$1
THUMBS_DIR=${GALLERY_ROOT}/.thumbs

# Rename images into timestamps names for automatic sorting
echo "Rename images"
${BIN_DIR}/gg_rename_pictures.py ${GALLERY_ROOT}

# Generate thumbnails for all images found under gallery's root.
echo "Create thumbnails"
${BIN_DIR}/gg_create_thumbnails.sh ${GALLERY_ROOT}

# Create htmls pages for each folder
for d in $(find ${GALLERY_ROOT} -path '*/\.thumbs*' -prune -o -type d  -print); do
  echo "Create $d Gallery"
  ${BIN_DIR}/gg_create_html.py ${d} ${THUMBS_DIR}
done
