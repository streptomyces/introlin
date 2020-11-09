#!/usr/bin/bash

coproc ./copr.pl 
read cpout <&"${COPROC[0]}"
echo $cpout


# coproc CP {
#   ./copr.pl $1
# }
# # echo ${CP[1]}
# # echo ${CP[0]}
# echo stuffed >&"${CP[1]}"
# read cpout <&"${CP[0]}"
# echo $cpout
# #;
