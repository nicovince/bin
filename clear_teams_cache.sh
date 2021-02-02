#!/bin/bash
# inspired from https://gist.github.com/mrcomoraes/c83a2745ef8b73f9530f2ec0433772b7

cd "$HOME"/.config/Microsoft/Microsoft\ Teams || exit 1

rm -rf Application\ Cache/Cache/*
rm -rf blob_storage/*
rm -rf databases/*
rm -rf GPUCache/*
rm -rf IndexedDB/*
rm -rf Local\ Storage/*
rm -rf tmp/*
rm -rf Cache/*
#rm -rf backgrounds/*
find ./ -maxdepth 1 -type f -name "*log*" -exec rm {} \;
