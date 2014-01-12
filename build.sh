#!/bin/bash
find . -name "*~" -exec rm {} \;
make clean && make package && make deploy
