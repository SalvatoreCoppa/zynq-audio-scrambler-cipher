# ==============================================================
# Vitis HLS - High-Level Synthesis from C, C++ and OpenCL v2021.2 (64-bit)
# Copyright 1986-2021 Xilinx, Inc. All Rights Reserved.
# ==============================================================
proc generate {drv_handle} {
    xdefine_include_file $drv_handle "xparameters.h" "XScrambler" \
        "NUM_INSTANCES" \
        "DEVICE_ID" \
        "C_S_AXI_SCRAMBLER_IO_BASEADDR" \
        "C_S_AXI_SCRAMBLER_IO_HIGHADDR"

    xdefine_config_file $drv_handle "xscrambler_g.c" "XScrambler" \
        "DEVICE_ID" \
        "C_S_AXI_SCRAMBLER_IO_BASEADDR"

    xdefine_canonical_xpars $drv_handle "xparameters.h" "XScrambler" \
        "DEVICE_ID" \
        "C_S_AXI_SCRAMBLER_IO_BASEADDR" \
        "C_S_AXI_SCRAMBLER_IO_HIGHADDR"
}

