#!/bin/bash
for i in $HOME/.kde/share/config/*; do

  if [ -f $i ]; then
    sed "s/,\?[^,]*\.lin[^,]*,\?//g" -i $i 
    sed 's/$HOME[^,]*petsa3un.aaa[^,],\?//g' -i $i 
  fi
done

for i in $HOME/.thumbnails/{large,normal}/*; do
  rm -f $i
done

sed -i '/firefox/d' ~/.bash_history
