# Synchronous FIFO Verification Environment — SystemVerilog

> A complete, OOP-based functional verification environment for a Synchronous FIFO design, built with SystemVerilog. Features constrained-random stimulus, a self-checking scoreboard, functional coverage, and SVA assertions.

---

## Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Project Structure](#project-structure)
- [Architecture](#architecture)
- [Getting Started](#getting-started)
- [Running Simulations](#running-simulations)
- [Coverage & Reports](#coverage--reports)
- [Bug Detection](#bug-detection)

---

## Overview

This project implements a robust **Functional Verification Environment** for a Synchronous FIFO design using **SystemVerilog**. The testbench follows industry-standard verification practices including:

- Object-Oriented Programming (OOP) principles
- Constrained-random stimulus generation
- Automated result checking via a Golden Reference Model
- Functional coverage collection
- SystemVerilog Assertions (SVA) for internal signal monitoring

The environment is capable of running **10,000,000 operations** to expose corner-case bugs that might otherwise go undetected.

---

## Features

| Feature | Description |
|---|---|
| **Constrained Randomization** | Configurable read/write probability ratios (default: 70% write / 30% read) |
| **Golden Reference Model** | Scoreboard built with a SystemVerilog queue for automatic DUT output checking |
| **Functional Coverage** | Covergroups with cross coverage between control signals and status flags |
| **SVA Assertions** | Concurrent and combinational assertions monitoring `full`, `empty`, `almostfull`, `overflow`, `underflow`, and pointer behavior |
| **Automated Reporting** | Pass/fail counters, error logging, and a full coverage report exported to `Report.txt` |

---

## Project Structure

```
.
├── FIFO.sv                  # Design Under Test (DUT) with embedded SVA assertions
├── interface.sv             # SystemVerilog interface with DUT and TEST modports
├── FIFO_transaction.sv      # Transaction class with constrained-random variables
├── tb.sv                    # Stimulus generator — randomizes and drives transactions
├── monitor.sv               # Samples interface signals; fans out to scoreboard & coverage
├── FIFO_scoreboard.sv       # Golden reference model + automatic result comparison
├── FIFO_coverage.sv         # Covergroups with cross coverage and ignore bins
├── shared_pkg.sv            # Shared package: global counters, events, and flags
├── top.sv                   # Top-level module — clock gen, DUT instantiation, wiring
└── run.do                   # QuestaSim/ModelSim Tcl script for compile, run & report
```

### File Descriptions

#### `FIFO.sv` — Design Under Test
The synthesizable FIFO RTL. Includes embedded **concurrent and combinational SVA assertions** that fire every clock cycle to verify the correctness of status flags (`full`, `empty`, `almostfull`, `overflow`, `underflow`) and internal read/write pointer behavior.

#### `interface.sv` — Interface
Connects the DUT to the testbench. Uses `modports` to enforce signal directionality for both the DUT (`DUT` modport) and the testbench (`TEST` modport).

#### `FIFO_transaction.sv` — Transaction Class
Defines the data object exchanged between testbench components. Applies **constraints** to control the statistical distribution of read and write operations for targeted scenario coverage.

#### `tb.sv` — Stimulus Generator
Randomizes `FIFO_transaction` objects and drives them onto the interface. Configured to execute **10,000,000 operations** for high-confidence verification.

#### `monitor.sv` — Monitor
Passively observes interface signals and captures input/output values into transaction objects. Uses `fork...join` to simultaneously dispatch captured data to both the **scoreboard** and **coverage collector**.

#### `FIFO_scoreboard.sv` — Scoreboard
The self-checking engine. Maintains a **golden reference model** using a SystemVerilog queue, compares DUT outputs against expected values, and tracks cumulative pass/fail counts. Prints a detailed error report on any mismatch.

#### `FIFO_coverage.sv` — Coverage Collector
Implements **covergroups** for functional coverage tracking. Includes:
- Per-signal coverage bins for control and status signals
- **Cross coverage** between `wr_en`/`rd_en` and flags like `full`, `empty`, `almostfull`
- **Ignore bins** to exclude logically impossible combinations

#### `shared_pkg.sv` — Shared Package
A central package imported across all components. Contains:
- Global pass/fail counters
- Shared events (e.g., `pass_inputs`) for inter-component synchronization

#### `top.sv` — Top-Level Module
Instantiates and wires all components together. Responsible for clock generation and connecting the interface to the DUT, testbench, and monitor.

#### `run.do` — Simulation Script
A Tcl/DO script for **QuestaSim / ModelSim** that automates the full simulation flow.

---

## Architecture

```
                ┌─────────────┐
                │     tb.sv   │  (Stimulus Generator)
                │  Randomize  │
                └──────┬──────┘
                       │ drives signals
                ┌──────▼──────────────┐
                │    interface.sv     │
                └──────┬──────────────┘
          ┌────────────┤
          │            │
   ┌──────▼──────┐  ┌──▼──────────┐
   │   FIFO.sv   │  │  monitor.sv │  (Passive Observer)
   │    (DUT)    │  └──┬──────────┘
   │  + SVA      │     │ fork...join
   └─────────────┘  ┌──┴──────────────────────┐
                    │                          │
          ┌─────────▼──────────┐   ┌───────────▼──────────┐
          │ FIFO_scoreboard.sv │   │  FIFO_coverage.sv    │
          │  (Golden Model /   │   │  (Functional         │
          │   Auto-Checker)    │   │   Coverage)          │
          └────────────────────┘   └──────────────────────┘
                    │
             shared_pkg.sv
          (Counters & Events)
```

---

## Getting Started

### Prerequisites

A SystemVerilog-capable simulator is required. Recommended tools:

- **QuestaSim** (Siemens EDA) — *recommended*
- **ModelSim**

### Clone the Repository

```bash
git clone https://github.com/your-username/sync-fifo-verification.git
cd sync-fifo-verification
```

---

## Running Simulations

The entire flow — compilation, simulation, and coverage reporting — is automated via the provided `run.do` script.

```bash
vsim -do run.do
```

**What this script does:**

1. Creates a work library and **compiles** all `*.sv` files with functional coverage instrumentation enabled
2. **Runs the simulation** on the `top` module with full visibility (`voptargs=+acc`)
3. **Saves the coverage database** to `FIFO.ucdb` upon completion
4. **Generates a detailed coverage report** and writes it to `Report.txt`

---

## Coverage & Reports

After simulation completes, review the results:

| Output File | Contents |
|---|---|
| `FIFO.ucdb` | Binary coverage database — open in QuestaSim GUI for visual browsing |
| `Report.txt` | Human-readable text report with per-covergroup and per-bin coverage percentages |

Console output from the scoreboard will also display a **pass/fail summary** and flag any transactions where DUT output diverged from the golden model.

---

## Bug Detection

The combination of the **Scoreboard**, **SVA Assertions**, and high-volume randomized testing makes this environment effective at uncovering:

- Incorrect flag assertion/deassertion (`full`, `empty`, `overflow`, `underflow`, `almostfull`)
- Read/write pointer miscalculations
- Data corruption or incorrect data forwarding
- Boundary condition failures (e.g., writing when full, reading when empty)

Any detected bug produces a **timestamped error message** in the simulation log identifying the failing signal, expected value, and actual DUT output.

---

## License

This project is open for educational and personal use.

---

*Built as part of a digital design verification learning project using SystemVerilog best practices.*
