#! /bin/sh

sea bpf --cpu=1800 -g --bmc="${BMC}" --crab --track=mem --inline --dsa=sea-cs -m64 -DPROVERS -DPROVERS_SEAHORN /mount/${1}/${2}.c
