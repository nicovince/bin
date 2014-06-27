#!/usr/bin/env python
import sys

def get_slice(data, offset, width):
    mask = (1 << width) -1
    return (data >> offset) & mask

print sys.argv[1]
n = int(sys.argv[1],16);

real = get_slice(n, 0, 13)
imag = get_slice(n, 13, 13)
fifoId = get_slice(n, 27, 3)

print "real[12:0] = 0x%0.3X" % real
print "imag[26:13] = 0x%0.3X" % imag
print "fifoId[29:27] = %d" % fifoId


print "-----------------"
print "nonoise"
real = get_slice(n, 0, 14)
imag = get_slice(n, 14, 14)

print "real[13:0] = 0x%0.3X" % real
print "imag[27:14] = 0x%0.3X" % imag


