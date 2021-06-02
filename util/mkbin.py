#!/usr/bin/python

import sys

if len(sys.argv) != 2:
    raise Exception("argv error")

filename = sys.argv[1]

with open(filename, 'rb') as f:
    data = f.read()

mem = data;

i = 0
for chunk in zip(*([iter(mem)]*4)):
    w = 0
    for x in reversed(chunk):
        w = (w << 8) + x
    print(f'{w:08x}', end='')
    print(' ' if i % 8 != 7 else '\n', end='')
    i += 1
print('')
