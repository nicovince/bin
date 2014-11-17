#!/usr/bin/env python

from math import *

def precoder(n):
    re1 = cos(2*pi*n/32)/sqrt(8)
    fp_re1 = 512*re1
    im1 = sin(2*pi*n/32)/sqrt(8)
    fp_im1 = 512*im1
    print "real : " + str(fp_re1) + " - " + str(re1)
    print "imag : " + str(fp_im1) + " - " + str(im1)

precoder(30)

