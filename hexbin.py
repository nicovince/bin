#!/usr/bin/env python

import sys


# 31-28 | 27-24 | 23-20 | 19-16 | 15-12 |  12-8 |   7-4 |   3-0
# Format a range bits to align on the rigth of a 5 width characters
def format_range(upper,lower):
    bitrange = str(upper) + "-" + str(lower)
    if len(bitrange) < 5:
        leading_spaces=5-len(bitrange)
        space = " "
        bitrange = leading_spaces * space + bitrange
    return bitrange


def display(n):
    s=" "
    c=""
    for i in reversed(range(0,32)):
        if n & (1 << i):
            bit = 1
        else:
            bit = 0
    
        s = s + str(bit)
        if i % 4 == 0:
            c = c + format_range(i+3, i) + " | "
            s = s + " |  "
    
    print s
    print c


print sys.argv[1]
n = int(sys.argv[1],16);
display(n)
