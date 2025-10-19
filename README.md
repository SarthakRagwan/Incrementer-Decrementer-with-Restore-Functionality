# Incrementer-Decrementer-with-Restore-Functionality
Designed a combinational RTL arithmetic block capable of incrementing (+1/+2), decrementing (−1/−2), or buffering the input value based on control signals. Optimized for area efficiency to facilitate integration within larger datapath architectures.

Author
Sarthak Kumar
Digital Design & Verilog Enthusiast
This project demonstrates practical modular arithmetic design and testbench development in Verilog HDL.


# Incrementer / Decrementer / Buffer Circuit (Verilog)

##  Overview
This project implements a **parameterized combinational arithmetic circuit** in **Verilog HDL** that performs **increment, decrement, or buffer** operations based on three control signals.

The circuit can modify an input count by **±1 or ±2**, or simply **hold (buffer)** the same value when disabled.  
It uses **hierarchical modular design**, composed of smaller functional blocks:
- `initialModule`
- `processingUnit`
- `ic` (top-level)

The accompanying testbench (`ic_tb.v`) validates all operation modes with randomized inputs.

---

##  Features
- Supports **Increment / Decrement** by **1 or 2**.  
- Acts as a **Buffer** when disabled (`enable = 0`).  
- Fully **parameterized width** (`N+1` bits, default: 8-bit).  
- **Combinational logic** (no clock).  
- Designed with **structured module hierarchy** for clarity and reusability.

---

##  Operation Theory

### 1️⃣ Control Signal Definitions
| Signal | Width | Description |
|:-------|:------|:-------------|
| `enable` | 1-bit | Operation enable: when `0`, circuit acts as **buffer**. |
| `decInc` | 1-bit | Direction control: `0` = increment, `1` = decrement. |
| `oneOrTwo` | 1-bit | Step magnitude: `0` = ±1, `1` = ±2. |
| `count[N:0]` | (N+1)-bit | Input count (current value). |
| `xorOutput[N:0]` | (N+1)-bit | Final output (next count). |
| `andOutput[N:0]` | (N+1)-bit | Intermediate signals for internal logic chaining. |

---

### 2️⃣ Functional Behavior
The circuit operation depends on the control signals as shown below:

| Enable | decInc | oneOrTwo | Operation | Description |
|:------:|:------:|:--------:|:-----------|:-------------|
| 0 | X | X | **Buffer** | Output = Input (no change) |
| 1 | 0 | 0 | **Increment by 1** | Adds +1 to count |
| 1 | 0 | 1 | **Increment by 2** | Adds +2 to count |
| 1 | 1 | 0 | **Decrement by 1** | Subtracts −1 from count |
| 1 | 1 | 1 | **Decrement by 2** | Subtracts −2 from count |

---

### 3️⃣ Module Hierarchy

ic (Top-Level)

├── initialModule → Handles LSB and enable/buffer logic

└── processingUnit → Handles bit-wise computation and propagation

#### 🔹 initialModule
- Manages the **first bit stage**.
- Integrates the `enable` and `oneOrTwo` logic.
- Responsible for **buffer behavior** when `enable = 0`.

#### 🔹 processingUnit
- Propagates the increment/decrement logic to higher bits.
- Uses XOR and AND operations to simulate arithmetic carry/borrow.

#### 🔹 ic (Integrated Circuit)
- Connects the initial module with multiple processing units via a `generate` loop.
- Produces the final `xorOutput` (next count).

---

Internal Circuitry

Initial Module

<img width="1827" height="492" alt="inital module" src="https://github.com/user-attachments/assets/b62f9ca9-c584-44fc-8de5-e33845b58098" />

Processing Unit

<img width="1879" height="553" alt="processing unit" src="https://github.com/user-attachments/assets/fe386f19-9b71-4969-af23-c1a458bb1334" />

Circuit Design

<img width="724" height="920" alt="Circuit Design" src="https://github.com/user-attachments/assets/f38f8cfd-bf46-4a25-be41-e71b4230ace5" />



##  Testbench (`ic_tb.v`)

###  Purpose
The testbench applies random values of `count` and systematically iterates through all 8 possible control signal combinations `{enable, decInc, oneOrTwo}` to verify every mode:
- Increment by 1
- Increment by 2
- Decrement by 1
- Decrement by 2
- Buffer (no change)

###  Example Simulation Output and waveform

Time=0 | ENA=0 | DEC/INC=0 | 1/2=0 | COUNT=  8 | NEXT_COUNT=  8

Time=10 | ENA=0 | DEC/INC=0 | 1/2=1 | COUNT= 12 | NEXT_COUNT= 12

Time=20 | ENA=0 | DEC/INC=1 | 1/2=0 | COUNT=  7 | NEXT_COUNT=  7

Time=30 | ENA=0 | DEC/INC=1 | 1/2=1 | COUNT=  2 | NEXT_COUNT=  2

Time=40 | ENA=1 | DEC/INC=0 | 1/2=0 | COUNT= 12 | NEXT_COUNT= 13

Time=50 | ENA=1 | DEC/INC=0 | 1/2=1 | COUNT=  2 | NEXT_COUNT=  4

Time=60 | ENA=1 | DEC/INC=1 | 1/2=0 | COUNT=  5 | NEXT_COUNT=  4

Time=70 | ENA=1 | DEC/INC=1 | 1/2=1 | COUNT=  7 | NEXT_COUNT=  5

<img width="1546" height="192" alt="Controller" src="https://github.com/user-attachments/assets/2a3d1e2a-10e8-4bca-9703-0eff29be4d68" />

---

##  Simulation Instructions

### 🔧 Using Icarus Verilog (Linux/Windows)
```bash
iverilog -o simv main.v ic_tb.v
vvp simv

enable = 1
decInc = 0
oneOrTwo = 1
count = 0110 (6)
xorOutput = 1000 (8)

enable = 1
decInc = 1
oneOrTwo = 0
count = 0101 (5)
xorOutput = 0100 (4)

enable = 0
decInc = X
oneOrTwo = X
count = 1010 (10)
xorOutput = 1010 (10)

Design Highlights

Implements arithmetic logic without using '+' or '-' operators.
Uses XOR-AND chain for carry and borrow propagation.
Buffer mode allows data passthrough without modification.
Can be extended to any bit width by changing the parameter N.

