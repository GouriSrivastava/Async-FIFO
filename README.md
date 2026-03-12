
# Asynchronous FIFO in Verilog

This project implements a parameterized asynchronous FIFO for safe data transfer between two independent clock domains.

## Features

- Dual clock FIFO
- Gray-coded read/write pointers
- Two-flop CDC synchronizers
- Parameterized FIFO depth
- Almost-full / almost-empty flags
- Randomized verification testbench
- Scoreboard-based correctness checking

## Architecture

The FIFO uses Gray-coded pointers to safely synchronize read and write pointers across clock domains.

Modules:
- write_ptr.v
- read_ptr.v
- sync_2ff.v
- fifo_mem.v
- async_fifo.v

## Verification

- Random read/write traffic
- Scoreboard comparison with reference FIFO
- GTKWave waveform verification

## Tools Used

- Verilog
- Icarus Verilog
- GTKWave
- Git


