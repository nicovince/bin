#!/bin/bash

GALLERY_ROOT=$1
THUMBS_DIR=${GALLERY_ROOT}/.thumbs

# Generate thumbnails for all images found under gallery's root.
echo "Create thumbnails"
gg_create_thumbnails.sh ${GALLERY_ROOT}

# Create htmls pages for each folder
for d in $(find . -path '*/\.thumbs*' -prune -o -type d  -print); do
  echo "Create $d Gallery"
  gg_create_html.py ${d} ${THUMBS_DIR}
done
