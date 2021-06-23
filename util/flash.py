#!/bin/python

import serial
import sys

filename = sys.argv[1]
image = []
with open(filename, 'rb') as f:
    image = f.read()

if len(image) == 0:
    raise Exception("no data")

packet = bytearray()
packet.extend(b's' * 8)
packet.extend(b'_')
for c in image:
    if c == ord('s') or c == ord('e') or c == ord('q'):
        packet.append(ord('q'))
    packet.append(c)
packet.extend(b'ee')

print(len(packet))

with serial.Serial("/dev/ttyUSB0", 115200) as ser:
    ser.write(packet)
