#!/usr/bin/env python

from optparse import OptionParser
import xml.etree.ElementTree as ET

def main():
    parser = OptionParser()
    parser.add_option("-f", "--file", dest="xml_filename",
                      help="xml input file")
    parser.add_option("-e", "--element", dest="xml_element", default="module",
                      help="xml elements for which the content must be dump [default: %default]")
    parser.add_option("-a", "--attribute", dest="xml_attribute",
                      help="xml attribute of dumped element to use to generate the output filename [default : %default]",
                      default="name")
    parser.add_option("-o", "--omit", dest="omit_xml_elements", action="append",
                      help="xml elements that are direct children of the dumped element that must not be dumped.\nThis option can be specified multiple times to specify multiple elements to omit",
                      default=[])
    (options,args) = parser.parse_args()
    print "Searching elements " + options.xml_element + " in " + options.xml_filename
    dump_xml_elements(options.xml_filename, options.xml_element, options.xml_attribute, options.omit_xml_elements)


def dump_xml_elements(xml_filename, xml_element, attr_name, omit_xml_elements):
    """Dump Xml elements from xml file into as many files as there are different elements.

    xml elements are dumped in sepearted files, the output filenames is generated from the value of an attribute of the dumped element
    xml_filename : filename of the xml file
    xml_element : name of the elements to dump
    attr_name : attribute name of the dumped element used to get the output filename
    omit_xml_elements : list of elements to be omited when dumping xml_element
    """
    tree = ET.parse(xml_filename)
    root = tree.getroot()
    for elt in root.iter(tag=xml_element):
        out_filename = elt.attrib[attr_name] + "_do_not_edit.xml"
        f = open(out_filename, 'w')
        f.write(dump_element_content(elt,3, omit_xml_elements))


def dump_element_content(element, shiftwidth, omit_xml_elements):
    """Return the content of an xml element.

    element : xml element to get the content of
    shiftwidth : level of indentation for the first element dumped
    """
    tag = element.tag
    # iterate over elements of current element
    dump_str = ''
    indent = ''.rjust(shiftwidth)
    dump_str += indent
    for elt in list(element):
        # discard root element and elements to omit
        if (elt.tag != tag) and (elt.tag not in omit_xml_elements):
            # Dump element
            dump_str += ET.tostring(elt)
    return dump_str

if __name__ == '__main__':
    main()

