#!/usr/bin/env python3
import argparse
import os

# Split l into n-length lists
def chunks(l, n):
    for i in range(0, len(l), n):
        yield(l[i:i+n])

def html_header(fd):
    fd.write("  <head>\n")
    fd.write("    <title>todo title</title>\n")
    fd.write("  </head>\n")

# Write html content in page for given image list
def generate_page(page, img_list, thumbs_dir):
    print("-> %s" % page)
    fd = open(page, 'w')
    fd.write("<html>\n")
    html_header(fd)
    indent="  "
    fd.write("%s<body>\n" % indent)
    indent += 2 * " "

    #TODO Start array
    for img_grp in chunks(img_list, 3):
        #TODO start new line of array
        for img in img_grp:
            thumb = os.path.join(thumbs_dir, img)
            fd.write("%s<a href=\"%s\">" % (indent, img))
            fd.write("<img src=\"%s\" />" % (thumb))
            fd.write("</a>\n")
        #TODO Close line of array
        fd.write("\n")
    #TODO Close array

    fd.write("  <body>\n")
    fd.write("</html>\n")
    fd.close()

# Generate html pages for all images present in img_dir, thumbnails must be
# present in thumbs_dir with same file name
def generate_htmls(img_dir, thumbs_dir):
    thumbs_rel_dir = os.path.relpath(thumbs_dir, img_dir)
    files = os.listdir(img_dir)
    files.sort()
    for i,img_sublist in enumerate(chunks(files, 30)):
        page = os.path.join(img_dir, "p%02d.html" % (i))
        generate_page(page, img_sublist, thumbs_dir)

def main():
    parser = argparse.ArgumentParser(description="Create HTML page for image gallery")
    parser.add_argument('img_folder', type=str, help="Image folder")
    parser.add_argument('thumbs_folder', type=str, help="Thumbnails image folder")
    args = parser.parse_args()

    # make sure paths are absolutes
    args.img_folder = os.path.abspath(args.img_folder)
    args.thumbs_folder = os.path.abspath(args.thumbs_folder)

    generate_htmls(args.img_folder, args.thumbs_folder)

main()

