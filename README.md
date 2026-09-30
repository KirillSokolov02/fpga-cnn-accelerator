# confCNN — Configurable CNN Accelerator

A **hardware CNN (Convolutional Neural Network) accelerator** implementing a configurable dataflow architecture with parallel processing elements, MAC units, and fully connected layers. Designed for **Xilinx Kintex-7** using **Vivado 2021.2**.

## Overview

This project implements a **configurable CNN accelerator** optimized for image classification and feature extraction tasks. The architecture features a parallel processing element (PE) array with multiply-accumulate (MAC) units, dataflow-optimized memory hierarchies, and a fully connected layer (FCL) with softmax activation — all orchestrated across **five independent clock domains** for maximum throughput.

The system processes convolutional neural network layers in a streaming fashion, leveraging spatial reuse (input reuse) and weight reuse techniques to minimize memory bandwidth requirements while maintaining high computational parallelism.

## Architecture

The accelerator is built around a **five-stage pipelined architecture** with five independent clock domains:

1. **Clock Domain 1-4 (CLK1-4)** — Input extraction and PE array processing
2. **Clock Domain 5 (CLK5)** — Fully connected layer and output processing
3. **Shared Clock Domain** — Control and coordination logic

The dataflow architecture ensures continuous data movement through the pipeline, with each stage operating asynchronously and communicating via handshaking protocols.

### PE Array (Processing Element Array)

The core of the accelerator is a **16×16 PE array** that performs parallel convolution operations:

- **16 rows × 16 columns = 256 PEs** per processing stage
- Each PE contains:
  - **MAC unit** (Multiply-Accumulate): 8-bit × 8-bit → 32-bit with accumulation
  - **Local register file** for weight storage
  - **Data forwarding logic** for neighbor-to-neighbor communication
- **Configurable precision**: Weight precision (WP) parameterized at 14-bit
- **Addition precision**: 8-bit accumulator bits (add_bits parameter)

### MAC Unit (Multiply-Accumulate)

Each MAC unit performs the fundamental CNN computation:

```
dataout = Σ(dataa[i] × datab[i])  (accumulated over multiple cycles)
```

- **Input A**: 8-bit (pixel/activation values)
- **Input B**: 8-bit (weight values)
- **Output**: 32-bit (accumulated sum)
- **Accumulation**: Supports multi-cycle accumulation with data enable gating
- **Dont-touch attribute**: Preserves optimal placement for timing

### RIETOP (Reuse Input Extraction Top)

Four parallel RIETOP units handle **input data reuse** across the PE array:

| Unit | Clock Domain | Function |
|------|-------------|----------|
| RIETOP 1 | CLK1 | Input extraction for PE row group 1 |
| RIETOP 2 | CLK2 | Input extraction for PE row group 2 |
| RIETOP 3 | CLK3 | Input extraction for PE row group 3 |
| RIETOP 4 | CLK4 | Input extraction for PE row group 4 |

Each RIETOP:
- Receives pixel data and memory addresses
- Implements **spatial reuse** by broadcasting input values to multiple PEs
- Manages **weight reuse** by loading weights from BRAM
- Outputs extracted features to the PE array
- Reports FCL full/empty status

### Fully Connected Layer (FCL)

The FCL processes the extracted features for classification:

| Component | Function |
|-----------|----------|
| **FCL Input Buffer** | Collects outputs from PE array |
| **FCL Weight Storage** | 14-bit weights for fully connected operations |
| **FCL MAC** | Matrix-vector multiplication |
| **Softmax** | Normalizes output probabilities |
| **Request Address** | Generates memory addresses for weight retrieval |

**Softmax Activation**: Computes normalized probability distribution over output classes:

```
softmax(x_i) = exp(x_i) / Σ exp(x_j)
```

Implemented in fixed-point arithmetic for FPGA efficiency.

### Memory Hierarchy

The accelerator employs a **multi-level memory hierarchy** to optimize data movement:

| Memory Type | Purpose | Depth | Width |
|------------|---------|-------|-------|
| **FCLdata BRAM** | FCL input features | Configurable | 14-bit × 4 channels |
| **BRAM_W** | Weight storage | Configurable | 14-bit |
| **BRAM_fcl** | FCL intermediate results | Configurable | 14-bit |
| **weightURAM** | Large weight storage | Deep | 14-bit |
| **URAM_rd_back** | Read-back URAM | Deep | For weight reuse |
| **wghtBRAMIRE** | Weight reuse buffer | Configurable | 14-bit |
| **FIFO** | Pipelining buffer | Configurable | Data width |

### Auxiliary Modules

| Module | Function |
|--------|----------|
| **counter** | Cycle and address generation |
| **mux** | Data path multiplexing |
| **mybram** | Custom BRAM wrapper with control logic |
| **address_generator** | Generates memory addresses for weights and activations |
| **weightbuffer** | Buffers weight data for reuse |
| **IRE1/IRE2** | Input reuse extraction stages |
| **cPPU/cPPU0/cPPU1** | Pixel processing units for preprocessing |
| **cPE** | Configurable processing element |
| **newPE** | Enhanced processing element with additional features |
| **sobel** | Sobel edge detection for preprocessing |
| **motion** | Motion detection for video processing |
| **ram** | General-purpose RAM for intermediate storage |

## Dataflow Architecture

The accelerator implements a **spatial dataflow** where data moves through the PE array in a wavefront pattern:

```
Input Data → RIETOP (CLK1-4) → PE Array (16×16) → FCL Input Buffer
                                                ↓
                                          FCL Processing (CLK5)
                                                ↓
                                          Softmax + Output
```

**Key optimizations**:

1. **Weight stationary**: Weights are reused across multiple input activations
2. **Input reuse**: Each input activation is broadcast to multiple PEs
3. **Output stationary**: Partial sums are accumulated locally before forwarding
4. **Row stationary**: Minimizes data movement by keeping row data local

## Configuration Parameters

The top module is parameterized for configurability:

| Parameter | Default | Description |
|-----------|---------|-------------|
| **WP** | 14 | Weight precision (bits) |
| **row** | 16 | PE array rows |
| **col** | 16 | PE array columns |
| **knl** | 9 | Kernel size |
| **add_bits** | 8 | Accumulator addition bits |
| **region** | 256 | Total PE count (row × col) |

## Interfaces

### Input Signals

| Signal | Width | Description |
|--------|-------|-------------|
| **clk1-5** | 1-bit each | Five independent clock domains |
| **load** | 1-bit | Load weights/activations mode |
| **we** | 1-bit | Write enable for input data |
| **start** | 1-bit | Start computation trigger |
| **rst** | 5-bit | Per-domain reset (rst[0-4] for each clock domain) |
| **inpixel1-4** | WP+add_bits-1:0 | Input pixel data (4 channels) |
| **memdata1-4** | WP+add_bits-1:0 | Memory data (4 channels) |
| **weightin** | WP-1:0 | Weight input for conv layers |
| **weightFCL** | WP-1:0 | FCL weights |
| **weightfcl2** | 7:0 | Second FCL layer weights |
| **indataFCL** | 4×WP-1:0 | FCL input data |
| **makeempty** | 1-bit | Clear FCL buffer |
| **genmux** | 1-bit | Generate multiplexer control |

### Output Signals

| Signal | Width | Description |
|--------|-------|-------------|
| **FCLIN** | 4×WP-1:0 | FCL input features from PE array |
| **finaloutput** | WP-1:0 | Final convolution output |
| **softmaxout** | 7:0 | Softmax-normalized output |
| **reqaddress** | 7:0 | Requested memory address |
| **dummyout** | WP-1:0 | Debug/monitoring output |

## Top Module Hierarchy

```
topmodule
├── RIETOP × 4 (one per clock domain CLK1-4)
│   ├── IRE1, IRE2 (input reuse extraction)
│   ├── cPPU, cPPU0, cPPU1 (pixel processing)
│   └── counter, mux (control)
├── macfcl (FCL multiply-accumulate with softmax)
├── memory management
│   ├── BRAM_fcl, BRAM_W, FCLdata
│   ├── weightURAM, uram_rd_back
│   └── wghtBRAMIRE (weight reuse)
├── FIFO (pipelining)
└── address generation
    └── address_generator
```

## Building

### Prerequisites

- **Xilinx Vivado 2021.2** (or later, 64-bit)
- **Xilinx Kintex-7 FPGA board** (e.g., KC705, ZedBoard with Kintex-7 add-on)
- Sufficient BRAM/URAM resources for target CNN model

### Compilation Steps

1. Open **Vivado 2021.2**
2. Select **File → Open Project**
3. Open `confCNN.xpr` from the confCNN subdirectory
4. Select **Flow → Run Synthesis**
5. After synthesis, select **Flow → Run Implementation**
6. Generate bitstream with **Flow → Generate Bitstream**
7. Program the Kintex-7 board

### Device Configuration

| Parameter | Value |
|-----------|-------|
| **Family** | Kintex-7 |
| **Device** | XC7K70T |
| **Package** | FBF676 |
| **Speed Grade** | -1 |
| **Vivado Version** | 2021.2 |
| **Top-Level Entity** | topmodule |

### Resource Considerations

This accelerator is resource-intensive due to:

- **256 PEs** with MAC units (~256 multipliers)
- **Multiple BRAM/URAM** blocks for weight and activation storage
- **5 clock domains** requiring careful timing closure
- **Deep pipelining** for high throughput

Estimated resource usage (varies with configuration):
- **LUTs**: ~40-60% of available
- **DSPs**: ~50-70% (multipliers)
- **BRAM**: ~60-80% (weights + activations)
- **URAM**: ~30-50% (large weight storage)

## CNN Model Support

The configurable architecture supports various CNN layers:

### Convolutional Layers

- **Kernel sizes**: Configurable (default 3×3, 5×5, 7×7 via knl parameter)
- **Input channels**: 4 (configurable)
- **Output channels**: 16×16 (PE array dimension)
- **Precision**: 8-bit activations, 8-bit weights, 14-bit accumulation

### Fully Connected Layers

- **Input size**: 4 × 256 (from PE array output)
- **Output size**: Configurable (softmax normalizes)
- **Precision**: 8-bit weights, 14-bit accumulation

### Activation Functions

- **Softmax**: Output probability distribution
- **ReLU**: Implied in datapath (can be added via clipping)

## Optimization Techniques

### Spatial Reuse

Input activations are broadcast horizontally across PE rows, reducing memory accesses by a factor of **col** (16).

### Weight Reuse

Weights are loaded once and reused across multiple input activations, reducing memory bandwidth by a factor of **knl²** (kernel size squared).

### Output Stationary

Partial sums are accumulated in local registers before being forwarded, minimizing data movement between PEs.

### Pipelining

Five independent clock domains enable **deep pipelining** with no data hazards between stages.

## Testing

### Testbench

The project includes a behavioral testbench (`testbench.v`) for simulation:

1. Open Vivado and select **Add Sources**
2. Add `testbench.v` from `confCNN.sim/sim_1/behav/xsim/`
3. Set **testbench** as the top module
4. Run **Run Simulation → Run Behavioral Simulation**

### Simulation Files

| File | Description |
|------|-------------|
| `testbench.v` | Top-level testbench |
| `mac_behav.v` | MAC unit behavioral model |
| `newPE_behav.v` | PE behavioral model |
| `topmodule_vhdl.v` | Top module behavioral model |

### WebTalk Logs

Simulation logs are stored in `confCNN.sim/sim_1/behav/xsim/` for analysis of timing and resource usage.

## References

- Xilinx PG058: UltraRAM Controller Guide
- Xilinx UG573: Kintex-7 Data Sheet
- Xilinx UG687: Vivado Design Suite User Guide
- IEEE 754 Floating-Point Standard

> *Note: This README was generated by AI to describe the project. The source code itself was written by the user.*
