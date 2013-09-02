#!/bin/bash

# TODO(dkorolev): Get rid of the Makefile and compile from this script with various options.

cat >/dev/null <<EOF
SAVE_IFS="$IFS"
COMPILERS="g++ clang++"
OPTIONS="-O0 -O3"
CMDLINES=""

for compiler in $COMPILERS ; do
  for options in $OPTIONS ; do
    CMDLINES+=$compiler' '$options':'
  done
done

IFS=':'
for cmdline in $CMDLINES ; do
  echo $cmdline
done
IFS="$SAVE_IFS"
EOF

for function in $(ls functions/ | cut -f1 -d.) ; do 
  echo "Function: "$function
  declare -A qps
  for action in generate evaluate intermediate_evaluate ; do
    qps[$action]=$(./test_binary $function $action 5)
  done
  params=""
  for action in generate evaluate intermediate_evaluate ; do
    params+=${qps[$action]}':'
  done
  echo $params | awk -F: '{ printf "Eval %.2f kqps, EvalSlow %.2f kqps\n", 0.001/(1/$2-1/$1), 0.001/(1/$3-1/$1) }'
  unset times
done