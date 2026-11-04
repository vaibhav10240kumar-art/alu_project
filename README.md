# 8-bit ALU in Verilog

A small ALU I wrote to learn Verilog. It's purely combinational, takes two 8-bit inputs and a 4-bit opcode, and gives back a result plus a few flags. The width is a parameter, so changing it to 16 or 32 bits just means changing `N`.

## Operations

| op   | Operation                     |
|------|-------------------------------|
| 0000 | ADD                           |
| 0001 | SUB                           |
| 0010 | AND                           |
| 0011 | OR                            |
| 0100 | XOR                           |
| 0101 | NOT a                         |
| 0110 | Shift left                    |
| 0111 | Shift right (logical)         |
| 1000 | Shift right (arithmetic)      |
| 1001 | Set less than (signed)        |

Any other opcode gives 0.

## Flags

- `zero`: result is all zeros
- `negative`: top bit of the result is 1
- `carry`: carry out on ADD, borrow on SUB
- `overflow`: signed overflow on ADD and SUB

Carry and overflow only mean something for ADD and SUB. For everything else they stay 0.

## Files

```
src/alu.v       the ALU
tb/alu_tb.v     self-checking testbench
sim/            build output and waveforms (not tracked by git)
```

## Running it

You need Icarus Verilog and GTKWave:

```
sudo apt install iverilog gtkwave
```

Then, from the project folder:

```
iverilog -g2012 -o sim/alu_sim src/alu.v tb/alu_tb.v
vvp sim/alu_sim
```

If everything works you'll see a bunch of PASS lines and `ALL TESTS PASSED` at the end. To look at the waveforms:

```
gtkwave sim/alu.vcd
```

The `-g2012` flag is needed because the code uses `$signed` and `>>>`.

## Flag examples (8-bit)

| a   | b   | op  | result | carry | overflow | zero |
|-----|-----|-----|--------|-------|----------|------|
| 200 | 100 | ADD | 44     | 1     | 0        | 0    |
| 100 | 100 | ADD | 200    | 0     | 1        | 0    |
| 5   | 5   | SUB | 0      | 0     | 0        | 1    |
| 3   | 5   | SUB | 254    | 1     | 0        | 0    |

## Notes

- 200 + 100 in 8 bits wraps around to 44 with carry set. The testbench checks this on purpose.
- The testbench only covers a handful of cases per operation. It's not exhaustive.

## Ideas for later

- Add a clock and register the outputs (Verify using openSTA)
- Multiply and rotate operations
- Run it on an FPGA board with switches for the inputs and LEDs for the result
- Use it inside a simple CPU

## Timing analysis

Synthesized with Yosys against the Nangate45 library and timed with OpenSTA. The ALU has no clock, so I used a virtual clock (10 ns) with 1 ns input and output delay.

```
yosys -s sta/synth.ys
sta -no_splash -exit sta/run_sta.tcl
```

Critical path: 7.483 ns, worst slack: 2.024 ns, area: 269.990 um^2. Full reports are in `sta/`.
The library file isn't in the repo. Download it from OpenROAD-flow-scripts (platforms/nangate45).

## Things I learned

- 200 + 100 in 8 bits wraps to 44 and sets carry, but overflow stays 0 because in signed terms it's -56 + 100. Same bits, two different flags.
- Defaulting every output at the top of the `always` block saves you from accidental latches.
- A typo in `$display` cost me more time than I'd like to admit.

