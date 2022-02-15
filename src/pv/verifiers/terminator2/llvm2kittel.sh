#!/bin/bash -xe

L=($(echo "${1}" | sed $'s/\// /g'))
./llvm2kittel --eager-inline -increase-strength -no-slicing --t2 --function "${L[-1]}" /mount/${1}.bc > /mount/${1}.t2.pre
/rewrite_kittel.py </mount/${1}.t2.pre >/mount/${1}.t2
