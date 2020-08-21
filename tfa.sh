#!/bin/sh

# Trace file accesses
strace -fe trace=creat,open,openat,unlink,unlinkat "$@"
