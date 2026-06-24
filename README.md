# 32-Bit 5-Stage Pipelined Processor

<p align="center">
  <img src="https://img.shields.io/badge/License-MIT-blue?style=flat-square" alt="License"/>
  <img src="https://img.shields.io/badge/HDL-SystemVerilog-orange?style=flat-square" alt="HDL"/>
  <img src="https://img.shields.io/badge/Status-Complete-success?style=flat-square" alt="Status"/>
  <img src="https://img.shields.io/badge/Course-CIE249%20Computer%20Architecture-navy?style=flat-square" alt="Course"/>
</p>

<p align="center">
A fully functional <b>32-bit ARM-subset pipelined processor</b> implemented in SystemVerilog, featuring a 5-stage pipeline with complete hazard resolution — data forwarding, load-use stalling, and control hazard flushing.
</p>

---

## Architecture Overview

The processor implements a classic **5-stage pipeline**:

| Stage | Name | Operation |
|-------|------|-----------|
| F | **Fetch** | Retrieve instruction from memory; PC ← PC + 4 |
| D | **Decode** | Read register file; decode control signals; PC + 8 |
| E | **Execute** | ALU computation or address calculation |
| M | **Memory** | Read/write data memory |
| W | **Writeback** | Write result back to register file |

**Key optimization:** The register file writes on the **falling edge** of the clock, allowing a write and read to occur within the same cycle — eliminating one pipeline register.

**PC optimization:** `PCPlus8D` is forwarded directly from `PCPlus4F`, removing a redundant 32-bit adder from the Decode stage.

---

## Pipeline Registers

Four sets of pipeline registers isolate the five stages and carry both data and control signals forward:

```
IF/ID → ID/EX → EX/MEM → MEM/WB
```

Control signals (e.g. `RegWrite`, `MemtoReg`) are propagated through all pipeline registers so they arrive at the correct stage exactly when their instruction is ready to commit.

Destination register address `WA3` is similarly propagated:

```systemverilog
// D→E
flopenrc #(.WIDTH(4)) wa3DE (.clk(clk), .reset(reset), .en(1'b1), .clear(FlushE), .d(InstrD[15:12]), .q(WA3E));
// E→M
flopr    #(.WIDTH(4)) wa3EM (.clk(clk), .reset(reset), .d(WA3E),  .q(WA3M));
// M→W
flopr    #(.WIDTH(4)) wa3MW (.clk(clk), .reset(reset), .d(WA3M),  .q(WA3W));
```

---

## Hazard Unit

The **Hazard Unit** is the core of this design. It detects all pipeline conflicts and resolves them transparently in hardware.

### 1 — Data Forwarding (RAW Hazards)

A Read-After-Write (RAW) hazard occurs when an instruction reads a register before a previous instruction has written to it.

**Solution:** Forward the computed result directly from the EX/MEM or MEM/WB pipeline register back to the ALU input — bypassing the register file entirely.

```systemverilog
assign Match_1E_M = (RA1E == WA3M);
assign Match_1E_W = (RA1E == WA3W);
assign Match_2E_M = (RA2E == WA3M);
assign Match_2E_W = (RA2E == WA3W);

always_comb begin
    if      (Match_1E_M & RegWriteM) ForwardAE = 2'b10;
    else if (Match_1E_W & RegWriteW) ForwardAE = 2'b01;
    else                              ForwardAE = 2'b00;

    if      (Match_2E_M & RegWriteM) ForwardBE = 2'b10;
    else if (Match_2E_W & RegWriteW) ForwardBE = 2'b01;
    else                              ForwardBE = 2'b00;
end
```

Forwarding muxes select the correct operand before the ALU:

```systemverilog
mux3 #(.WIDTH(WIDTH)) fwdA_mux (.d0(RD1E), .d1(ResultW), .d2(ResultM), .s(ForwardAE), .y(SrcAE));
mux3 #(.WIDTH(WIDTH)) fwdB_mux (.d0(RD2E), .d1(ResultW), .d2(ResultM), .s(ForwardBE), .y(SrcBE_raw));
```

### 2 — Load-Use Stall (LDR Hazard)

A `LDR` instruction does not produce its result until the end of the **Memory** stage. Forwarding cannot reach backward in time, so a **stall** is required.

The processor holds Fetch and Decode for one cycle and inserts a bubble into Execute:

```systemverilog
assign Match_12D_E = (RA1D == WA3E) | (RA2D == WA3E);
assign LDRstall     = Match_12D_E & MemtoRegE;

assign StallF = LDRstall | PCWrPendingF;
assign StallD = LDRstall;
assign FlushE = LDRstall | BranchTakenE;
```

### 3 — Control Hazard Flushing (Branch)

Branch resolution is moved up to the **Execute stage**, reducing the misprediction penalty from 4 cycles down to **2 cycles**.

```systemverilog
assign PCWrPendingF = PCSrcD | PCSrcE | PCSrcM;

assign StallF = LDRstall | PCWrPendingF;
assign FlushD = PCWrPendingF | PCSrcW | BranchTakenE;
assign FlushE = LDRstall    | BranchTakenE;
```

---

## Performance

| Metric | Single-Cycle | Pipelined |
|--------|-------------|-----------|
| Clock period | 680 ps | 200 ps |
| Instruction latency | 680 ps | 1000 ps (5 × 200 ps) |
| Throughput | 1.47 GIPS | **5.00 GIPS** |
| Speedup | — | **~3.4×** |

---

## Project Structure

```
32-Bit-5-Stage-Pipelined-Processor/
├── src/
│   ├── top.sv               # Top-level module
│   ├── datapath.sv          # Full pipelined datapath
│   ├── control_unit.sv      # Instruction decoder & control signals
│   ├── hazard_unit.sv       # Forwarding, stall, and flush logic
│   ├── alu.sv               # 32-bit ALU
│   ├── regfile.sv           # Register file (write on falling edge)
│   ├── flopr.sv             # Pipeline register (with reset)
│   └── flopenrc.sv          # Pipeline register (with enable + clear)
├── tb/
│   └── tb_top.sv            # Testbench
├── Report/
│   └── Pipelined_Processor_Report.pdf
└── README.md
```

---

## Tools

| Tool | Purpose |
|------|---------|
| SystemVerilog | RTL design |
| ModelSim / QuestaSim | Simulation & waveform verification |

### Running the Simulation

```bash
vlog src/*.sv tb/tb_top.sv
vsim tb_top
```

---

## Course

**CIE 249 — Computer Architecture and Assembly Language**
Zewail City of Science and Technology
Instructor: Dr. Elmahdy Maree

---

## License

MIT License — see [LICENSE](LICENSE) for details.
