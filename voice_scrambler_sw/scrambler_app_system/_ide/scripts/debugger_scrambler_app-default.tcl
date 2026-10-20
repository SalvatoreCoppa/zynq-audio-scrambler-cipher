# Usage with Vitis IDE:
# In Vitis IDE create a Single Application Debug launch configuration,
# change the debug type to 'Attach to running target' and provide this 
# tcl script in 'Execute Script' option.
# Path of this script: C:\Users\sasyc\Documents\VitisProjects\voice_scrambler_sw\scrambler_app_system\_ide\scripts\debugger_scrambler_app-default.tcl
# 
# 
# Usage with xsct:
# To debug using xsct, launch xsct and run below command
# source C:\Users\sasyc\Documents\VitisProjects\voice_scrambler_sw\scrambler_app_system\_ide\scripts\debugger_scrambler_app-default.tcl
# 
connect -url tcp:127.0.0.1:3121
targets -set -nocase -filter {name =~"APU*"}
rst -system
after 3000
targets -set -filter {jtag_cable_name =~ "Digilent Zybo Z7 210351B7BE85A" && level==0 && jtag_device_ctx=="jsn-Zybo Z7-210351B7BE85A-23727093-0"}
fpga -file C:/Users/sasyc/Documents/VitisProjects/voice_scrambler_sw/scrambler_app/_ide/bitstream/voice_scrambler_wrapper.bit
targets -set -nocase -filter {name =~"APU*"}
loadhw -hw C:/Users/sasyc/Documents/VitisProjects/voice_scrambler_sw/scrambler_platform/export/scrambler_platform/hw/voice_scrambler_wrapper.xsa -mem-ranges [list {0x40000000 0xbfffffff}] -regs
configparams force-mem-access 1
targets -set -nocase -filter {name =~"APU*"}
source C:/Users/sasyc/Documents/VitisProjects/voice_scrambler_sw/scrambler_app/_ide/psinit/ps7_init.tcl
ps7_init
ps7_post_config
targets -set -nocase -filter {name =~ "*A9*#0"}
dow C:/Users/sasyc/Documents/VitisProjects/voice_scrambler_sw/scrambler_app/Debug/scrambler_app.elf
configparams force-mem-access 0
targets -set -nocase -filter {name =~ "*A9*#0"}
con
