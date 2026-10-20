# Zynq Audio Scrambler Cipher

![Language](https://img.shields.io/badge/Language-C%20%2F%20C%2B%2B-00599C?style=for-the-badge&logo=c)
![Hardware](https://img.shields.io/badge/Hardware-Xilinx%20Zynq--7000-E01F27?style=for-the-badge)
![Tools](https://img.shields.io/badge/Tools-Vivado%20%7C%20Vitis%20HLS-03234B?style=for-the-badge)

A real-time Hardware/Software Co-Design implementation of an audio stream cipher on the Xilinx Zynq-7000 System-on-Chip (deployed on the Digilent Zybo Z7-20 board). 

> 🇮🇹 **Note on Documentation:** The full project report, theoretical analysis, and mathematical modeling are available in Italian in the [`SoC_VoiceScrambler_docs.pdf`](./SoC_VoiceScrambler_docs.pdf) file.

## 🎯 Project Overview

This project implements a secure voice communication scrambler using a Galois Linear Feedback Shift Register (LFSR) stream cipher. The system captures analog audio via the onboard SSM2603 codec, encrypts the digital stream in real-time, and outputs the masked audio. 

By leveraging the Zynq SoC architecture, the workload is strictly partitioned to achieve deterministic latency and high efficiency:
*   **Programmable Logic (PL):** Handles the high-speed cryptographic XOR operations and LFSR state updates using a custom hardware accelerator synthesized via Vitis HLS.
*   **Processing System (PS):** The ARM Cortex-A9 manages the audio routing, I2C codec initialization, and interactive dynamic re-keying via UART.

## 🏗️ System Architecture

The development workflow follows a strict Top-Down Model-Based Design approach:

1.  **Model-Based Design (MATLAB):** Mathematical simulation of the 16-bit Galois LFSR, discrete autocorrelation analysis to prove pseudo-randomness, and vulnerability assessment (Two-Time Pad attack simulation).
2.  **High-Level Synthesis (Vitis HLS):** C/C++ to RTL synthesis of the cryptographic IP core. The module is mapped to an AXI4-Lite interface and executes the encryption algorithm in purely combinational logic with zero-cycle latency.
3.  **Hardware Integration (Vivado):** System-level block design containing two scrambler instances (TX and RX), the I2S audio controller, and the AXI Interconnects.
4.  **Software Development (Vitis):** Bare-metal C application orchestrating the hardware IPs, handling AXI GPIO interrupts, and multiplexing the audio stream into 4 operational states: Software Bypass, TX Only, RX Only, and Cascade Loopback.

## 📂 Repository Structure

```text
├── voice_scrambler_hls/                    # Vitis HLS source files (scrambler.c, scrambler.h, testbench)
├── voice_scrambler_hw/                 # Hardware block design, IP integrator files, and XDC constraints
├── voice_scrambler_sw/                  # Bare-metal C application and Board Support Package (BSP)
├── SoC_VoiceScrambler_docs.pdf                   # PDF report and project documentation
└── README.md
