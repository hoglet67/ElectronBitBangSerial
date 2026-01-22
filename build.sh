#!/bin/bash

mkdir -p build
rm -f build/serial.ssd
beebasm -i src/serial_driver.asm -do build/serial.ssd -v > build/serial.log
ls -l build
