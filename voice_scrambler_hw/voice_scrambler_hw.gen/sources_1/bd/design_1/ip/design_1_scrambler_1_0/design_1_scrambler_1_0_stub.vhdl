-- Copyright 1986-2021 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2021.2 (win64) Build 3367213 Tue Oct 19 02:48:09 MDT 2021
-- Date        : Thu May  7 23:20:05 2026
-- Host        : MSI running 64-bit major release  (build 9200)
-- Command     : write_vhdl -force -mode synth_stub
--               c:/Users/sasyc/Documents/VivadoProjects/voice_scrambler_hw/voice_scrambler_hw.gen/sources_1/bd/design_1/ip/design_1_scrambler_1_0/design_1_scrambler_1_0_stub.vhdl
-- Design      : design_1_scrambler_1_0
-- Purpose     : Stub declaration of top-level module interface
-- Device      : xc7z020clg400-1
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity design_1_scrambler_1_0 is
  Port ( 
    ap_local_block : out STD_LOGIC;
    s_axi_scrambler_io_AWADDR : in STD_LOGIC_VECTOR ( 5 downto 0 );
    s_axi_scrambler_io_AWVALID : in STD_LOGIC;
    s_axi_scrambler_io_AWREADY : out STD_LOGIC;
    s_axi_scrambler_io_WDATA : in STD_LOGIC_VECTOR ( 31 downto 0 );
    s_axi_scrambler_io_WSTRB : in STD_LOGIC_VECTOR ( 3 downto 0 );
    s_axi_scrambler_io_WVALID : in STD_LOGIC;
    s_axi_scrambler_io_WREADY : out STD_LOGIC;
    s_axi_scrambler_io_BRESP : out STD_LOGIC_VECTOR ( 1 downto 0 );
    s_axi_scrambler_io_BVALID : out STD_LOGIC;
    s_axi_scrambler_io_BREADY : in STD_LOGIC;
    s_axi_scrambler_io_ARADDR : in STD_LOGIC_VECTOR ( 5 downto 0 );
    s_axi_scrambler_io_ARVALID : in STD_LOGIC;
    s_axi_scrambler_io_ARREADY : out STD_LOGIC;
    s_axi_scrambler_io_RDATA : out STD_LOGIC_VECTOR ( 31 downto 0 );
    s_axi_scrambler_io_RRESP : out STD_LOGIC_VECTOR ( 1 downto 0 );
    s_axi_scrambler_io_RVALID : out STD_LOGIC;
    s_axi_scrambler_io_RREADY : in STD_LOGIC;
    ap_clk : in STD_LOGIC;
    ap_rst_n : in STD_LOGIC;
    interrupt : out STD_LOGIC
  );

end design_1_scrambler_1_0;

architecture stub of design_1_scrambler_1_0 is
attribute syn_black_box : boolean;
attribute black_box_pad_pin : string;
attribute syn_black_box of stub : architecture is true;
attribute black_box_pad_pin of stub : architecture is "ap_local_block,s_axi_scrambler_io_AWADDR[5:0],s_axi_scrambler_io_AWVALID,s_axi_scrambler_io_AWREADY,s_axi_scrambler_io_WDATA[31:0],s_axi_scrambler_io_WSTRB[3:0],s_axi_scrambler_io_WVALID,s_axi_scrambler_io_WREADY,s_axi_scrambler_io_BRESP[1:0],s_axi_scrambler_io_BVALID,s_axi_scrambler_io_BREADY,s_axi_scrambler_io_ARADDR[5:0],s_axi_scrambler_io_ARVALID,s_axi_scrambler_io_ARREADY,s_axi_scrambler_io_RDATA[31:0],s_axi_scrambler_io_RRESP[1:0],s_axi_scrambler_io_RVALID,s_axi_scrambler_io_RREADY,ap_clk,ap_rst_n,interrupt";
attribute X_CORE_INFO : string;
attribute X_CORE_INFO of stub : architecture is "scrambler,Vivado 2021.2";
begin
end;
