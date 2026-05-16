# SiPi - 6-Stage Pipelined MIPS Processor

## Introduction

SiPi is a Verilog implementation of a 6-stage pipelined MIPS-based processor. This design extends the classic 5-stage MIPS pipeline to improve instruction throughput and support advanced hazard management. The processor includes dedicated forwarding and hazard detection units to handle data dependencies and control hazards efficiently.

**Key Features:**
- 6-stage instruction pipeline architecture
- MIPS instruction set support
- Data forwarding (bypass) unit
- Hazard detection unit
- Comprehensive testbenches for validation

---

## Working

### Pipeline Architecture

The SiPi processor implements a 6-stage pipeline, where each stage handles a specific portion of instruction execution:

#### **Stage 1: Instruction Fetch (IF)**
- Fetches the current instruction from instruction memory using the program counter (PC)
- Increments the PC for the next sequential instruction
- Stores fetched instruction and incremented PC in the IF/ID pipeline register
- Handles branch target updates when control hazards are resolved

#### **Stage 2: Instruction Decode & Register Read (ID)**
- Decodes the fetched instruction to identify operation type and operand fields
- Reads two source operands from the register file based on instruction fields
- Generates control signals that guide the instruction through remaining pipeline stages
- Stores decoded control signals, register values, and immediate values in the ID/EX pipeline register
- Performs early hazard detection to stall the pipeline if necessary

#### **Stage 3: Execute & Address Calculation (EX)**
- Performs arithmetic and logic operations using the ALU
- Calculates memory addresses for load/store instructions
- Evaluates branch conditions for conditional branches
- Passes ALU results to the EX/MEM pipeline register
- Interacts with the forwarding unit to obtain correct operand values when data hazards exist

#### **Stage 4: Memory Access Part 1 (MEM1)**
- Initiates memory operations for load and store instructions
- Prepares memory address and write data signals
- Passes data to memory system
- Stores intermediate results in MEM1/MEM2 pipeline register
- For non-memory instructions, data bypasses this stage without modification

#### **Stage 5: Memory Access Part 2 (MEM2)**
- Completes memory read or write operations
- Latches data returned from memory (for load instructions)
- Stores results in MEM2/WB pipeline register
- Ensures memory operations complete before write-back stage

#### **Stage 6: Write Back (WB)**
- Writes the final result back to the register file
- For ALU operations, writes computed result
- For load instructions, writes data fetched from memory
- Updates destination register with computed value
- Completes instruction execution

---

### Hazard Handling

#### **Data Hazards**

**Detection and Resolution:**
- **Hazard Detection Unit**: Identifies potential data dependencies between pipeline stages
  - Detects when an instruction needs a register value before it's available
  - Particularly checks for load-use hazards (load instruction followed by immediate use)
  - Signals the pipeline controller to insert a stall (bubble) when necessary
  
- **Forwarding Unit (Bypass Logic)**: Reduces stalls by forwarding intermediate results
  - Monitors all pipeline stages for uncommitted results
  - When an instruction needs a value being computed in a later stage, the forwarding unit directly supplies it
  - Checks: 
    - If the source register matches a result in the EX stage, forward from EX/MEM
    - If the source register matches a result in the MEM stage, forward from MEM2/WB
  - Eliminates unnecessary stalls for most data dependencies
  - Handles cases where forwarding alone cannot solve the hazard (load-use), triggering a stall

#### **Control Hazards**

- **Branch Resolution**: Branch target addresses are computed in the EX stage
- **Pipeline Flushing**: When a branch is taken, all instructions in earlier pipeline stages are flushed
- **Impact**: The pipeline loses 3 cycles of throughput per taken branch (IF, ID, and EX stages must restart)
- **Trade-off**: Splitting memory access into two stages increases branch penalty; branch prediction can mitigate this in advanced designs

#### **Structural Hazards**

- **Pipeline Register Architecture**: Each inter-stage pipeline register captures all necessary data and control signals
- **No Resource Conflicts**: The 6-stage design avoids structural hazards in standard scenarios
- **Register File**: Designed with separate read and write ports to avoid conflicts between stages

---

### Key Modules

**Instruction Fetch (IF)**
- PC management and increment logic
- Instruction memory interface
- Branch target handling

**Instruction Decode (ID)**
- Control signal generation
- Register file read operations
- Immediate value extraction and sign extension

**Execute (EX)**
- ALU for arithmetic and logical operations
- Address calculation for memory operations
- Branch condition evaluation
- Forwarding unit integration

**Memory (MEM1/MEM2)**
- Memory address setup and validation
- Data memory read/write operations
- Data latching and alignment

**Write Back (WB)**
- Register file write logic
- Result multiplexing (ALU result vs. memory data)

**Hazard Detection Unit**
- Dependency checking across pipeline stages
- Stall signal generation
- Load-use hazard identification

**Forwarding Unit**
- Bypass path multiplexing
- Result forwarding from EX and MEM stages
- Operand selection logic

---

### Pipeline Registers

Pipeline registers store intermediate data between stages:

- **IF/ID**: Instruction, incremented PC
- **ID/EX**: Control signals, register values, immediate values, PC
- **EX/MEM**: ALU result, memory write data, control signals, address information
- **MEM1/MEM2**: Data from memory, ALU results, control signals
- **MEM2/WB**: Final result (ALU or memory), write-back control signals

---

### Data Flow Example: ADD Instruction

```
Clock 1: ADD R3, R1, R2  →  IF stage (fetch instruction)
Clock 2: ADD R3, R1, R2  →  ID stage (decode, read R1 and R2)
Clock 3: ADD R3, R1, R2  →  EX stage (compute R1 + R2)
Clock 4: ADD R3, R1, R2  →  MEM1 stage (no memory operation)
Clock 5: ADD R3, R1, R2  →  MEM2 stage (no memory operation)
Clock 6: ADD R3, R1, R2  →  WB stage (write sum to R3)
```

---

### Data Flow Example: Load with Immediate Use (LW → ADD)

```
Clock 1: LW R1, 100(R2)  →  IF
Clock 2: LW R1, 100(R2)  →  ID   |  ADD R3, R1, R5  →  IF
Clock 3: LW R1, 100(R2)  →  EX   |  ADD R3, R1, R5  →  ID (Stall triggered by hazard detection)
Clock 4: Stall           →  Stall |  ADD R3, R1, R5  →  Stall (waits for R1)
Clock 5: LW R1, 100(R2)  →  MEM1 |  ADD R3, R1, R5  →  ID (can proceed)
Clock 6: LW R1, 100(R2)  →  MEM2 |  ADD R3, R1, R5  →  EX (R1 available via forwarding)
Clock 7: LW R1, 100(R2)  →  WB   |  ADD R3, R1, R5  →  MEM1
Clock 8: N/A             |  ADD R3, R1, R5  →  MEM2
Clock 9: N/A             |  ADD R3, R1, R5  →  WB
```

The stall is necessary because the result of LW is not available for forwarding until the MEM2 stage, but ADD needs it immediately in the EX stage.

---

### Design Advantages

1. **Higher Clock Frequency**: Splitting memory operations into two stages reduces per-stage logic depth, enabling faster clock rates
2. **Better Instruction Throughput**: With hazard management, most instructions complete in 6 cycles; pipelined execution allows one instruction to complete per cycle at steady state
3. **Scalability**: Modular design allows extension with branch prediction or additional cache levels
4. **Educational Value**: Comprehensive hazard handling demonstrates real processor design tradeoffs

---

## Testing

The repository includes testbenches in the `Testbench` directory for validating:
- Basic instruction execution
- Data forwarding correctness
- Hazard detection and stalling
- Pipeline register state transitions
- Memory operations

---

## Directory Structure

```
SiPi/
├── Modules/          # Core processor modules (Verilog)
├── Testbench/        # Test benches for validation
└── README.md         # This file
```

---

## References

- Hennessy, J. L., & Patterson, D. A. (2017). *Computer Organization and Design: The Hardware/Software Interface* (6th ed.). Morgan Kaufmann.
- MIPS Instruction Set Architecture specifications
- Standard digital design principles for pipelined processors
