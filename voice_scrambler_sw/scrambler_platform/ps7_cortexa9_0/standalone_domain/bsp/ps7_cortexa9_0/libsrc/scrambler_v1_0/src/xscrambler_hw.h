// ==============================================================
// Vitis HLS - High-Level Synthesis from C, C++ and OpenCL v2021.2 (64-bit)
// Copyright 1986-2021 Xilinx, Inc. All Rights Reserved.
// ==============================================================
// scrambler_io
// 0x00 : Control signals
//        bit 0  - ap_start (Read/Write/COH)
//        bit 1  - ap_done (Read/COR)
//        bit 2  - ap_idle (Read)
//        bit 3  - ap_ready (Read/COR)
//        bit 7  - auto_restart (Read/Write)
//        others - reserved
// 0x04 : Global Interrupt Enable Register
//        bit 0  - Global Interrupt Enable (Read/Write)
//        others - reserved
// 0x08 : IP Interrupt Enable Register (Read/Write)
//        bit 0 - enable ap_done interrupt (Read/Write)
//        bit 1 - enable ap_ready interrupt (Read/Write)
//        bit 5 - enable ap_local_deadlock interrupt (Read/Write)
//        others - reserved
// 0x0c : IP Interrupt Status Register (Read/TOW)
//        bit 0 - ap_done (COR/TOW)
//        bit 1 - ap_ready (COR/TOW)
//        bit 5 - ap_local_deadlock (COR/TOW)
//        others - reserved
// 0x10 : Data signal of y
//        bit 15~0 - y[15:0] (Read)
//        others   - reserved
// 0x14 : Control signal of y
//        bit 0  - y_ap_vld (Read/COR)
//        others - reserved
// 0x20 : Data signal of x
//        bit 15~0 - x[15:0] (Read/Write)
//        others   - reserved
// 0x24 : reserved
// 0x28 : Data signal of seed
//        bit 15~0 - seed[15:0] (Read/Write)
//        others   - reserved
// 0x2c : reserved
// 0x30 : Data signal of load_seed
//        bit 0  - load_seed[0] (Read/Write)
//        others - reserved
// 0x34 : reserved
// (SC = Self Clear, COR = Clear on Read, TOW = Toggle on Write, COH = Clear on Handshake)

#define XSCRAMBLER_SCRAMBLER_IO_ADDR_AP_CTRL        0x00
#define XSCRAMBLER_SCRAMBLER_IO_ADDR_GIE            0x04
#define XSCRAMBLER_SCRAMBLER_IO_ADDR_IER            0x08
#define XSCRAMBLER_SCRAMBLER_IO_ADDR_ISR            0x0c
#define XSCRAMBLER_SCRAMBLER_IO_ADDR_Y_DATA         0x10
#define XSCRAMBLER_SCRAMBLER_IO_BITS_Y_DATA         16
#define XSCRAMBLER_SCRAMBLER_IO_ADDR_Y_CTRL         0x14
#define XSCRAMBLER_SCRAMBLER_IO_ADDR_X_DATA         0x20
#define XSCRAMBLER_SCRAMBLER_IO_BITS_X_DATA         16
#define XSCRAMBLER_SCRAMBLER_IO_ADDR_SEED_DATA      0x28
#define XSCRAMBLER_SCRAMBLER_IO_BITS_SEED_DATA      16
#define XSCRAMBLER_SCRAMBLER_IO_ADDR_LOAD_SEED_DATA 0x30
#define XSCRAMBLER_SCRAMBLER_IO_BITS_LOAD_SEED_DATA 1

