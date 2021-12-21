#!/bin/bash

L=($(echo "${1}" | sed $'s/\// /g'))
./llvm2kittel --eager-inline -increase-strength -no-slicing --t2 --function "${L[-1]}" /mount/${1}.bc | /rewrite_kittel.py > /mount/${1}.t2
