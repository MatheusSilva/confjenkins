#!/bin/bash
mv $1 $1'.tmp'
cat $1'.tmp' | expand -t4 > $1
rm $1'.tmp'
