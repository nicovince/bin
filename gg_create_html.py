#!/usr/bin/env python3
import argparse
import os

# Split l into n-length lists
def chunks(l, n):
    for i in range(0, len(l), n):
        yield(l[i:i+n])

def indent(lvl):
    return lvl * "  "

def html_header(fd, lvl):
    fd.write("%s<head>\n" % (indent(lvl)))
    lvl += 1
    fd.write("%s<title>todo title</title>\n" % (indent(lvl)))
    lvl -= 1
    fd.write("%s</head>\n" % (indent(lvl)))

def navigation_links(previous_page, next_page, lvl):
    s = "%s<table>\n" % (indent(lvl))
    lvl += 1
    s += "%s<tr>\n" % (indent(lvl))
    lvl += 1
    s += "%s<td>" % (indent(lvl))
    if previous_page is not None:
        s += "<a href=\"%s\">page precedente</a>" % (previous_page)
    s += "</td>\n"
    s += "%s<td>" % (indent(lvl))
    if next_page is not None:
        s += "<a href=\"%s\">page suivante</a>" % (next_page)
    s += "</td>\n"
    lvl -= 1
    s += "%s</tr>\n" % (indent(lvl))
    s += "%s</body>" % (indent(lvl))
    return s


# Write html content in page for given image list
def generate_page(page, img_list, thumbs_dir, previous_page=None, next_page=None):
    print("-> %s [%s; %s]" % (page, previous_page, next_page))
    fd = open(page, 'w')
    fd.write("<html>\n")
    lvl = 1
    html_header(fd, lvl)

    fd.write("%s<body>\n" % (indent(lvl)))
    lvl += 1

    # generate navigation links
    fd.write("%s" % (navigation_links(previous_page, next_page, lvl)))

    # Start images array
    fd.write("%s<table>\n" % (indent(lvl)))
    lvl += 1

    for img_grp in chunks(img_list, 3):
        # start new line of array
        fd.write("%s<tr>\n" % (indent(lvl)))
        lvl += 1
        for img in img_grp:
            thumb = os.path.join(thumbs_dir, img)
            fd.write("%s<td>" % (indent(lvl)))
            fd.write("<a href=\"%s\">" % (img))
            fd.write("<img src=\"%s\" />" % (thumb))
            fd.write("</a>")
            fd.write("</td>\n")
        # Close line of array
        lvl -= 1
        fd.write("%s</tr>\n" % (indent(lvl)))

    # Close array
    lvl -= 1
    fd.write("%s</table>\n" % (indent(lvl)))

    fd.write("%s<body>\n" % (indent(lvl)))
    fd.write("</html>\n")
    fd.close()

def file_has_ext(f, ext_list):
    return os.path.splitext(f)[1][1:] in ext_list

# Generate html pages for all images present in img_dir, thumbnails must be
# present in thumbs_dir with same file name
def generate_htmls(img_dir, thumbs_dir, img_ext):
    thumbs_rel_dir = os.path.relpath(thumbs_dir, img_dir)
    files = [f for f in os.listdir(img_dir) if file_has_ext(f, img_ext)]
    files.sort()
    dirs = [f for f in os.listdir(img_dir) if os.path.isdir(f)]
    # remove .thumbs/ from directory list
    dirs = [d for d in dirs if os.path.basename(d) != ".thumbs"]

    # split images per pages
    imgs_per_page = chunks(dirs + files, 30)
    n_pages = sum(1 for _ in chunks(dirs + files, 30))
    for i, img_sublist in enumerate(chunks(dirs + files, 30)):
        previous_page = None
        next_page = None
        if i != 0:
            previous_page = "p%02d.html" % (i - 1)
        if i != (n_pages - 1):
            next_page = "p%02d.html" % (i + 1)

        page = os.path.join(img_dir, "p%02d.html" % (i))
        generate_page(page, img_sublist, thumbs_rel_dir, previous_page, next_page)

def main():
    parser = argparse.ArgumentParser(description="Create HTML page for image gallery")
    parser.add_argument('img_folder', type=str, help="Image folder")
    parser.add_argument('thumbs_folder', type=str, help="Thumbnails image folder")
    args = parser.parse_args()
    img_ext = ["png", "jpg", "JPG"]

    # make sure paths are absolutes
    args.img_folder = os.path.abspath(args.img_folder)
    args.thumbs_folder = os.path.abspath(args.thumbs_folder)

    generate_htmls(args.img_folder, args.thumbs_folder, img_ext)

main()

