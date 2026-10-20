# 
# Usage: To re-create this platform project launch xsct with below options.
# xsct C:\Users\sasyc\Documents\VitisProjects\voice_scrambler_sw\scrambler_platform\platform.tcl
# 
# OR launch xsct and run below command.
# source C:\Users\sasyc\Documents\VitisProjects\voice_scrambler_sw\scrambler_platform\platform.tcl
# 
# To create the platform in a different location, modify the -out option of "platform create" command.
# -out option specifies the output directory of the platform project.

platform create -name {scrambler_platform}\
-hw {C:\Users\sasyc\Documents\VivadoProjects\voice_scrambler_hw\voice_scrambler_design_wrapper.xsa}\
-proc {ps7_cortexa9_0} -os {standalone} -out {C:/Users/sasyc/Documents/VitisProjects/voice_scrambler_sw}

platform write
platform generate -domains 
platform active {scrambler_platform}
bsp reload
platform generate
platform generate
platform active {scrambler_platform}
platform config -updatehw {C:/Users/sasyc/Documents/VivadoProjects/voice_scrambler_hw/voice_scrambler_design_wrapper.xsa}
platform generate -domains 
platform active {scrambler_platform}
platform config -updatehw {C:/Users/sasyc/Documents/VivadoProjects/voice_scrambler_hw/voice_scrambler_wrapper.xsa}
platform generate -domains 
platform generate -domains 
platform active {scrambler_platform}
platform active {scrambler_platform}
domain active {zynq_fsbl}
bsp reload
platform generate
platform active {scrambler_platform}
platform config -updatehw {C:/Users/sasyc/Documents/VivadoProjects/voice_scrambler_hw/voice_scrambler_wrapper.xsa}
platform generate -domains 
platform config -updatehw {C:/Users/sasyc/Documents/VivadoProjects/voice_scrambler_hw/voice_scrambler_wrapper.xsa}
platform generate -domains 
platform clean
platform generate
platform clean
platform generate
platform generate
