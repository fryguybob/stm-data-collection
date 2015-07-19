#!/bin/bash
# run from project root directory as ./PriorityQueue/pqbench.sh

ghc -o BenchPQ BenchmarkPQ.hs gettime.c -O2 -threaded -rtsopts -fno-omit-yields -eventlog
if [ $? -eq 0 ]; then
  echo OK
  ./BenchPQ timing 50000 200 --runs=10 --initsize=100 --insrate=100 +RTS -s -N4 -la -K16m -qa
  # ./Bench throughput 200 --runs=3 --initsize=10000 --insrate=50 +RTS -s -N4 -la -K16m -qa

  rm BenchPQ
  find . -type f -name '*.o' -delete
  find . -type f -name '*.hi' -delete
else
  echo FAIL
fi