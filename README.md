# Synchronous FIFO
SystemVerilog implementation of a single clock, synchronous FIFO, verified with a custom 
(non-UVM) testbench environment, including a driver, monitor, scoreboard, assertions, and 
functional coverage.

## Design
`fifo_sync` uses an extra pointer bit to detect FULL/EMPTY without a seperate occupancy
counter. The lower bits of each pointer index into memory and the extra MSB toggles on 
wraparound. This allows FULL/EMPTY to be asserted by a simple pointer comparison.

## Repo structure
```
rtl/fifo.sv - DUT
tb/driver.sv - stimulus generation
   monitor.sv - passive transaction logger
   scoreboard.sv - reference model + pass/fail checker
   assertions.sv - protocol/invariant checks
   coverage.sv - functional coverage tracking
   tb_fifo.sv - top level testbench, test sequence
Makefile
```

## Running the Tests
```bash
make
```

Runs firstly a directed test sequence covering reset, single R/W, fill/empty, overflow,
underflow, wraparound, and simultaneous R/W, followed by a 10,000 iteration randomised
test, and then prints scoreboard results, assertion error count, coverage report and 
final occupancy.

## Results
=================================
FIFO Verification Complete
=================================

Passes : 6488
Errors : 0
Assertion Errors : 0
RESULT : PASS

==============================
FIFO Coverage Report
==============================

Reset Tested             : PASS
Full Condition           : PASS
Empty Condition          : PASS
Simultaneous Read/Write  : PASS
Overflow Attempt         : PASS
Underflow Attempt        : PASS

Occupancy 0 :  HIT
Occupancy 1 :  HIT
Occupancy 2 :  HIT
Occupancy 3 :  HIT
Occupancy 4 :  HIT
Occupancy 5 :  HIT
Occupancy 6 :  HIT
Occupancy 7 :  HIT
Occupancy 8 :  HIT
Occupancy 9 :  HIT
Occupancy 10 :  HIT
Occupancy 11 :  HIT
Occupancy 12 :  HIT
Occupancy 13 :  HIT
Occupancy 14 :  HIT
Occupancy 15 :  HIT
Occupancy 16 :  HIT

Total Writes (Lifetime)            : 6519
Total Reads (Lifetime)             : 6488

Final FIFO Occupancy : 6