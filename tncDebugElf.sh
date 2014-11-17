#!/bin/bash
/opt/soft/toolchains/mips-ecos-elf/bin/mips-ecos-elf-readelf -S titanic-mips.elf > elf_sections
nm -C --size-sort -n titanic-mips.elf > nm.out
