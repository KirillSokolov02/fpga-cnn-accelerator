# Configurable CNN Accelerator — 16x16 PE Array on Kintex-7

Verilog implementation of a configurable convolutional neural network hardware accelerator with a systolic PE array, fully-connected layer, and configurable parameters. Built for Xilinx Kintex-7.

## Overview

This project implements a hardware-accelerated CNN inference engine for image classification. The core is a configurable Processing Element (PE) array with MAC units for convolution, a fully-connected layer with softmax, and dedicated memory buffers for weights and input data.

## Project Structure

| File | Description |
|------|-------------|
| `topmodule.v` | Top-level wrapper for the CNN accelerator |
| `top.v` | Main system module |
| `cPE.v` | Configurable Processing Element with MAC unit |
| `cPPU.v` / `cPPU0.v` / `cPPU1.v` | PE array control and pipeline management |
| `RIETOP.v` / `RPU.v` | Row/Column input handling |
| `newPE.v` | Enhanced Processing Element |
| `mac.v` / `macfcl.v` | MAC units for convolution and FCL |
| `sobel.v` | Sobel edge detection module |
| `motion.v` | Motion detection module |
| `weightbuffer.v` | Weight memory buffer controller |
| `IRE1.v` / `IRE2.v` | Input Row/Column expansion |
| `fcl.v` | Fully-connected layer with softmax |
| `counter.v` / `mux.v` / `address_generator.v` | Supporting logic |
| `mybram.v` / `ram.v` | RAM models |

## Hardware

- **Device:** Xilinx Kintex-7 XC7K70T (xc7k70tfbv676-1)
- **Tool:** Vivado 2021.2
- **Language:** Verilog-2001

## Architecture

**Multi-clock-domain design (5 clock domains):**

- **PE Array:** 16x16 configurable Processing Elements with MAC units performing multiply-accumulate
- **FCL with Softmax:** Fully-connected layer for classification output
- **Configurable parameters:** WP (window position), row/col dimensions, kernel size
- **Memory hierarchy:** BRAM for weights, URAM for large buffers, FIFOs for pipeline staging

## Building

1. Open `confCNN.xpr` in Vivado
2. Run Synthesis and Implementation
3. Generate bitstream
