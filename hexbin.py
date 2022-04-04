#!/usr/bin/env python

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

def split(num, bitlen):
    """Split number into bitlen groups.

    split(0xAB,4) -> [0xA, 0xB]
    """
    split_num = []
    while num != 0:
        val = num & (1 << bitlen) - 1
        split_num.append(val)
        num = num >> bitlen

    return split_num

def bitval(num, bitpos):
    if num & (1 << bitpos):
        return 1
    return 0

def display(num, pkt_sz=32, msb_zero=False):
    packets = split(num, pkt_sz)
    for pkt_cnt,pkt in enumerate(packets):
        binstr = " "
        rangestr = ""
        for i in reversed(range(0, pkt_sz)):
            bit = bitval(pkt, i)
            binstr += str(bit)
            if (i % 4) == 0:
                msb_idx = pkt_cnt * pkt_sz + i + 3
                lsb_idx = pkt_cnt * pkt_sz + i

                if msb_zero:
                    msb_idx = len(packets) * pkt_sz - 1 - msb_idx
                    lsb_idx = len(packets) * pkt_sz - 1 - lsb_idx
                rangestr += format_range(msb_idx, lsb_idx) + " | "
                binstr += " |  "
        print(binstr)
        print(rangestr)

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("n", help="hexvalue to display in binary")
    parser.add_argument("--msb-zero", action="store_true",
                        help="msb is displayed as bit 0")
    parser.add_argument("--pkt-size", type=int, help="Number of bit to display per line",
                        choices=[8,16,32,64], default=32)
    args = parser.parse_args()
    args.n = int(args.n, 16)
    display(args.n, args.pkt_size, args.msb_zero)

if __name__ == "__main__":
    main()
