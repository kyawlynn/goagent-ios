#!/bin/bash
find . -name "*~" -exec rm {} \;
make clean && make install && make package 
