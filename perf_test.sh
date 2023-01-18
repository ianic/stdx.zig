#!/bin/sh
zig build -Drelease-fast && hyperfine --parameter-scan alg 1 9 './zig-out/bin/comb_hp_bench {alg}' --warmup 1
