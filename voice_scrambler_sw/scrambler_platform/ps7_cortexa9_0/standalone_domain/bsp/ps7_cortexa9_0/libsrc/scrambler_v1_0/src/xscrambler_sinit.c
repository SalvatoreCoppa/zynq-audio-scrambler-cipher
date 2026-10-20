// ==============================================================
// Vitis HLS - High-Level Synthesis from C, C++ and OpenCL v2021.2 (64-bit)
// Copyright 1986-2021 Xilinx, Inc. All Rights Reserved.
// ==============================================================
#ifndef __linux__

#include "xstatus.h"
#include "xparameters.h"
#include "xscrambler.h"

extern XScrambler_Config XScrambler_ConfigTable[];

XScrambler_Config *XScrambler_LookupConfig(u16 DeviceId) {
	XScrambler_Config *ConfigPtr = NULL;

	int Index;

	for (Index = 0; Index < XPAR_XSCRAMBLER_NUM_INSTANCES; Index++) {
		if (XScrambler_ConfigTable[Index].DeviceId == DeviceId) {
			ConfigPtr = &XScrambler_ConfigTable[Index];
			break;
		}
	}

	return ConfigPtr;
}

int XScrambler_Initialize(XScrambler *InstancePtr, u16 DeviceId) {
	XScrambler_Config *ConfigPtr;

	Xil_AssertNonvoid(InstancePtr != NULL);

	ConfigPtr = XScrambler_LookupConfig(DeviceId);
	if (ConfigPtr == NULL) {
		InstancePtr->IsReady = 0;
		return (XST_DEVICE_NOT_FOUND);
	}

	return XScrambler_CfgInitialize(InstancePtr, ConfigPtr);
}

#endif

