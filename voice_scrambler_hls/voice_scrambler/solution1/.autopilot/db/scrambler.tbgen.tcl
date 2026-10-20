set moduleName scrambler
set isTopModule 1
set isCombinational 0
set isDatapathOnly 0
set isPipelined 0
set pipeline_type none
set FunctionProtocol ap_ctrl_hs
set isOneStateSeq 1
set ProfileFlag 0
set StallSigGenFlag 0
set isEnableWaveformDebug 1
set C_modelName {scrambler}
set C_modelType { void 0 }
set C_modelArgList {
	{ y int 16 regular {axi_slave 1}  }
	{ x int 16 regular {axi_slave 0}  }
	{ seed uint 16 regular {axi_slave 0}  }
	{ load_seed uint 1 regular {axi_slave 0}  }
	{ ap_local_deadlock int 1 unused {axi_slave 1}  }
}
set C_modelArgMapList {[ 
	{ "Name" : "y", "interface" : "axi_slave", "bundle":"scrambler_io","type":"ap_vld","bitwidth" : 16, "direction" : "WRITEONLY", "offset" : {"out":16}, "offset_end" : {"out":23}} , 
 	{ "Name" : "x", "interface" : "axi_slave", "bundle":"scrambler_io","type":"ap_none","bitwidth" : 16, "direction" : "READONLY", "offset" : {"in":32}, "offset_end" : {"in":39}} , 
 	{ "Name" : "seed", "interface" : "axi_slave", "bundle":"scrambler_io","type":"ap_none","bitwidth" : 16, "direction" : "READONLY", "offset" : {"in":40}, "offset_end" : {"in":47}} , 
 	{ "Name" : "load_seed", "interface" : "axi_slave", "bundle":"scrambler_io","type":"ap_none","bitwidth" : 1, "direction" : "READONLY", "offset" : {"in":48}, "offset_end" : {"in":55}} , 
 	{ "Name" : "ap_local_deadlock", "interface" : "axi_slave", "bundle":"scrambler_io","type":"ap_none","bitwidth" : 1, "direction" : "WRITEONLY", "offset" : {"out":0}, "offset_end" : {"out":4294967295}} ]}
# RTL Port declarations: 
set portNum 21
set portList { 
	{ ap_local_block sc_out sc_logic 1 signal -1 } 
	{ ap_clk sc_in sc_logic 1 clock -1 } 
	{ ap_rst_n sc_in sc_logic 1 reset -1 active_low_sync } 
	{ s_axi_scrambler_io_AWVALID sc_in sc_logic 1 signal -1 } 
	{ s_axi_scrambler_io_AWREADY sc_out sc_logic 1 signal -1 } 
	{ s_axi_scrambler_io_AWADDR sc_in sc_lv 6 signal -1 } 
	{ s_axi_scrambler_io_WVALID sc_in sc_logic 1 signal -1 } 
	{ s_axi_scrambler_io_WREADY sc_out sc_logic 1 signal -1 } 
	{ s_axi_scrambler_io_WDATA sc_in sc_lv 32 signal -1 } 
	{ s_axi_scrambler_io_WSTRB sc_in sc_lv 4 signal -1 } 
	{ s_axi_scrambler_io_ARVALID sc_in sc_logic 1 signal -1 } 
	{ s_axi_scrambler_io_ARREADY sc_out sc_logic 1 signal -1 } 
	{ s_axi_scrambler_io_ARADDR sc_in sc_lv 6 signal -1 } 
	{ s_axi_scrambler_io_RVALID sc_out sc_logic 1 signal -1 } 
	{ s_axi_scrambler_io_RREADY sc_in sc_logic 1 signal -1 } 
	{ s_axi_scrambler_io_RDATA sc_out sc_lv 32 signal -1 } 
	{ s_axi_scrambler_io_RRESP sc_out sc_lv 2 signal -1 } 
	{ s_axi_scrambler_io_BVALID sc_out sc_logic 1 signal -1 } 
	{ s_axi_scrambler_io_BREADY sc_in sc_logic 1 signal -1 } 
	{ s_axi_scrambler_io_BRESP sc_out sc_lv 2 signal -1 } 
	{ interrupt sc_out sc_logic 1 signal -1 } 
}
set NewPortList {[ 
	{ "name": "s_axi_scrambler_io_AWADDR", "direction": "in", "datatype": "sc_lv", "bitwidth":6, "type": "signal", "bundle":{"name": "scrambler_io", "role": "AWADDR" },"address":[{"name":"scrambler","role":"start","value":"0","valid_bit":"0"},{"name":"scrambler","role":"continue","value":"0","valid_bit":"4"},{"name":"scrambler","role":"auto_start","value":"0","valid_bit":"7"},{"name":"x","role":"data","value":"32"},{"name":"seed","role":"data","value":"40"},{"name":"load_seed","role":"data","value":"48"}] },
	{ "name": "s_axi_scrambler_io_AWVALID", "direction": "in", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "scrambler_io", "role": "AWVALID" } },
	{ "name": "s_axi_scrambler_io_AWREADY", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "scrambler_io", "role": "AWREADY" } },
	{ "name": "s_axi_scrambler_io_WVALID", "direction": "in", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "scrambler_io", "role": "WVALID" } },
	{ "name": "s_axi_scrambler_io_WREADY", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "scrambler_io", "role": "WREADY" } },
	{ "name": "s_axi_scrambler_io_WDATA", "direction": "in", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "scrambler_io", "role": "WDATA" } },
	{ "name": "s_axi_scrambler_io_WSTRB", "direction": "in", "datatype": "sc_lv", "bitwidth":4, "type": "signal", "bundle":{"name": "scrambler_io", "role": "WSTRB" } },
	{ "name": "s_axi_scrambler_io_ARADDR", "direction": "in", "datatype": "sc_lv", "bitwidth":6, "type": "signal", "bundle":{"name": "scrambler_io", "role": "ARADDR" },"address":[{"name":"scrambler","role":"start","value":"0","valid_bit":"0"},{"name":"scrambler","role":"done","value":"0","valid_bit":"1"},{"name":"scrambler","role":"idle","value":"0","valid_bit":"2"},{"name":"scrambler","role":"ready","value":"0","valid_bit":"3"},{"name":"scrambler","role":"auto_start","value":"0","valid_bit":"7"},{"name":"y","role":"data","value":"16"}, {"name":"y","role":"valid","value":"20","valid_bit":"0"},{"name":"ap_local_deadlock","role":"data","value":"0"}] },
	{ "name": "s_axi_scrambler_io_ARVALID", "direction": "in", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "scrambler_io", "role": "ARVALID" } },
	{ "name": "s_axi_scrambler_io_ARREADY", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "scrambler_io", "role": "ARREADY" } },
	{ "name": "s_axi_scrambler_io_RVALID", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "scrambler_io", "role": "RVALID" } },
	{ "name": "s_axi_scrambler_io_RREADY", "direction": "in", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "scrambler_io", "role": "RREADY" } },
	{ "name": "s_axi_scrambler_io_RDATA", "direction": "out", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "scrambler_io", "role": "RDATA" } },
	{ "name": "s_axi_scrambler_io_RRESP", "direction": "out", "datatype": "sc_lv", "bitwidth":2, "type": "signal", "bundle":{"name": "scrambler_io", "role": "RRESP" } },
	{ "name": "s_axi_scrambler_io_BVALID", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "scrambler_io", "role": "BVALID" } },
	{ "name": "s_axi_scrambler_io_BREADY", "direction": "in", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "scrambler_io", "role": "BREADY" } },
	{ "name": "s_axi_scrambler_io_BRESP", "direction": "out", "datatype": "sc_lv", "bitwidth":2, "type": "signal", "bundle":{"name": "scrambler_io", "role": "BRESP" } },
	{ "name": "interrupt", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "scrambler_io", "role": "interrupt" } }, 
 	{ "name": "ap_local_block", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "ap_local_block", "role": "default" }} , 
 	{ "name": "ap_clk", "direction": "in", "datatype": "sc_logic", "bitwidth":1, "type": "clock", "bundle":{"name": "ap_clk", "role": "default" }} , 
 	{ "name": "ap_rst_n", "direction": "in", "datatype": "sc_logic", "bitwidth":1, "type": "reset", "bundle":{"name": "ap_rst_n", "role": "default" }}  ]}

set RtlHierarchyInfo {[
	{"ID" : "0", "Level" : "0", "Path" : "`AUTOTB_DUT_INST", "Parent" : "", "Child" : ["1"],
		"CDFG" : "scrambler",
		"Protocol" : "ap_ctrl_hs",
		"ControlExist" : "1", "ap_start" : "1", "ap_ready" : "1", "ap_done" : "1", "ap_continue" : "0", "ap_idle" : "1", "real_start" : "0",
		"Pipeline" : "None", "UnalignedPipeline" : "0", "RewindPipeline" : "0", "ProcessNetwork" : "0",
		"II" : "1",
		"VariableLatency" : "0", "ExactLatency" : "0", "EstimateLatencyMin" : "0", "EstimateLatencyMax" : "0",
		"Combinational" : "0",
		"Datapath" : "0",
		"ClockEnable" : "0",
		"HasSubDataflow" : "0",
		"InDataflowNetwork" : "0",
		"HasNonBlockingOperation" : "0",
		"IsBlackBox" : "0",
		"Port" : [
			{"Name" : "y", "Type" : "Vld", "Direction" : "O"},
			{"Name" : "x", "Type" : "None", "Direction" : "I"},
			{"Name" : "seed", "Type" : "None", "Direction" : "I"},
			{"Name" : "load_seed", "Type" : "None", "Direction" : "I"},
			{"Name" : "lfsr_state", "Type" : "OVld", "Direction" : "IO"},
			{"Name" : "ap_local_deadlock", "Type" : "None", "Direction" : "O"}]},
	{"ID" : "1", "Level" : "1", "Path" : "`AUTOTB_DUT_INST.scrambler_io_s_axi_U", "Parent" : "0"}]}


set ArgLastReadFirstWriteLatency {
	scrambler {
		y {Type O LastRead -1 FirstWrite 0}
		x {Type I LastRead 0 FirstWrite -1}
		seed {Type I LastRead 0 FirstWrite -1}
		load_seed {Type I LastRead 0 FirstWrite -1}
		lfsr_state {Type IO LastRead -1 FirstWrite -1}
		ap_local_deadlock {Type O LastRead -1 FirstWrite -1}}}

set hasDtUnsupportedChannel 0

set PerformanceInfo {[
	{"Name" : "Latency", "Min" : "0", "Max" : "0"}
	, {"Name" : "Interval", "Min" : "1", "Max" : "1"}
]}

set PipelineEnableSignalInfo {[
]}

set Spec2ImplPortList { 
}

set busDeadlockParameterList { 
}

# RTL port scheduling information:
set fifoSchedulingInfoList { 
}

# RTL bus port read request latency information:
set busReadReqLatencyList { 
}

# RTL bus port write response latency information:
set busWriteResLatencyList { 
}

# RTL array port load latency information:
set memoryLoadLatencyList { 
}
