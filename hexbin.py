#!/usr/bin/env python

import sys
import argparse


# 31-28 | 27-24 | 23-20 | 19-16 | 15-12 |  12-8 |   7-4 |   3-0
# Format a range bits to align on the rigth of a 5 width characters
def format_range(upper,lower):
    bitrange = str(upper) + "-" + str(lower)
    if len(bitrange) < 5:
        leading_spaces=5-len(bitrange)
        space = " "
        bitrange = leading_spaces * space + bitrange
    return bitrange

def split(n, bitlen):
    l = list()
    while n != 0:
        val = n & (1 << bitlen) - 1
        l.append(val)
        n = n >> bitlen

    return l

def bitval(n, b):
    if n & (1 << b):
        return 1
    else:
        return 0

def display2(n, pkt_sz=32, msb_zero=False):
    packets = split(n, pkt_sz)
    for pkt_cnt,p in enumerate(packets):
        s = " "
        c = ""
        for i in reversed(range(0, pkt_sz)):
            bit = bitval(p, i)
            s += str(bit)
            if (i % 4) == 0:
                msb_idx = pkt_cnt * pkt_sz + i + 3
                lsb_idx = pkt_cnt * pkt_sz + i

                if msb_zero:
                    msb_idx = len(packets) * pkt_sz - 1 - msb_idx
                    lsb_idx = len(packets) * pkt_sz - 1 - lsb_idx
                c += format_range(msb_idx, lsb_idx) + " | "
                s += " |  "
        print s
        print c

def display(n):
    while n != 0:
        s=" "
        c=""
        val = n & (1 << 32) - 1
        for i in reversed(range(0,32)):
            if val & (1 << i):
                bit = 1
            else:
                bit = 0
        
            s = s + str(bit)
            if i % 4 == 0:
                c = c + format_range(i+3, i) + " | "
                s = s + " |  "
        
        print s
        print c
        n = n >> 32

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("n", help="hexvalue to display in binary")
    parser.add_argument("--msb-zero", action="store_true",
                        help="msb is displayed as bit 0")
    parser.add_argument("--pkt-size", type=int, help="Number of bit to display per line",
                        choices=[8,16,32,64], default=32)
    args = parser.parse_args()
    args.n = int(args.n, 16)
    display2(args.n, args.pkt_size, args.msb_zero)

if __name__ == "__main__":
    main()
