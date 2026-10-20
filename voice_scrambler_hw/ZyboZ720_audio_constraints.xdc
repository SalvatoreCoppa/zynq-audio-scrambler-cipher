# ZyBo Z7-20 board
# Audio Related constraints
set_property PACKAGE_PIN R19 [get_ports BCLK]
set_property IOSTANDARD LVCMOS33 [get_ports BCLK]

set_property PACKAGE_PIN T19 [get_ports PBLRCLK]
set_property IOSTANDARD LVCMOS33 [get_ports PBLRCLK]

set_property PACKAGE_PIN Y18 [get_ports RECLRCLK]
set_property IOSTANDARD LVCMOS33 [get_ports RECLRCLK]

set_property PACKAGE_PIN R16 [get_ports RECDAT]
set_property IOSTANDARD LVCMOS33 [get_ports RECDAT]

set_property PACKAGE_PIN R18 [get_ports PBDATA]
set_property IOSTANDARD LVCMOS33 [get_ports PBDATA]

# GPIO[0] output - For MUTE signal (Attivo Basso)
set_property PACKAGE_PIN P18 [get_ports {MUTE_tri_o[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {MUTE_tri_o[0]}]

# MCLK for the audio codec. it is at 12.288 MHz
set_property PACKAGE_PIN R17 [get_ports FCLK_CLK1]
set_property IOSTANDARD LVCMOS33 [get_ports FCLK_CLK1]

# I2C 1 interface
set_property PACKAGE_PIN N18 [get_ports IIC_1_scl_io]
set_property IOSTANDARD LVCMOS33 [get_ports IIC_1_scl_io]

set_property PACKAGE_PIN N17 [get_ports IIC_1_sda_io]
set_property IOSTANDARD LVCMOS33 [get_ports IIC_1_sda_io]

# GPIO2[1:0] for routing the audio (SW0 and SW1)
set_property PACKAGE_PIN G15 [get_ports {SW_tri_i[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {SW_tri_i[0]}]

set_property PACKAGE_PIN P15 [get_ports {SW_tri_i[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {SW_tri_i[1]}]