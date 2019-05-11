#!/usr/bin/env python3
import argparse
import os
import glob
from PIL import Image
from PIL.ExifTags import TAGS
import time  

def get_date_name(image):
    date =  Image.open(image)._getexif()[36867]
    date = date.replace(":", "")
    date = date.replace(" ", "_")
    ext = os.path.splitext(image)[1][1:]
    datename = date+"."+ext
    return datename

def file_has_ext(f, ext_list):
    return os.path.splitext(f)[1][1:] in ext_list

def main():
    parser = argparse.ArgumentParser(description="Rename pictures in given folder")
    parser.add_argument('img_folder', type=str, help="Image folder")
    args = parser.parse_args()
    img_ext = ["png", "jpg", "JPG"]

    # make sure paths are absolutes
    args.img_folder = os.path.abspath(args.img_folder)
    
    for img in [f for f in os.listdir(args.img_folder) if file_has_ext(f,img_ext)]:
        fileimg = os.path.join(args.img_folder, img)
        datename = get_date_name(fileimg)
        newname = os.path.join(args.img_folder, datename)

        if not os.path.exists(newname):
            os.rename(fileimg,newname)
        #else :
        #    print(fileimg)

main()
