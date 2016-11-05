# TCL File Generated by Component Editor 13.0
# Fri Nov 04 13:31:31 CET 2016
# DO NOT MODIFY


# 
# BCH "BCH" v1.0
#  2016.11.04.13:31:31
# BCH
# 

# 
# request TCL package from ACDS 13.0
# 
package require -exact qsys 13.0


# 
# module BCH
# 
set_module_property DESCRIPTION BCH
set_module_property NAME BCH
set_module_property VERSION 1.0
set_module_property INTERNAL false
set_module_property OPAQUE_ADDRESS_MAP true
set_module_property GROUP BCH
set_module_property AUTHOR ""
set_module_property DISPLAY_NAME BCH
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE true
set_module_property ANALYZE_HDL AUTO
set_module_property REPORT_TO_TALKBACK false
set_module_property ALLOW_GREYBOX_GENERATION false


# 
# file sets
# 
add_fileset QUARTUS_SYNTH QUARTUS_SYNTH "" ""
set_fileset_property QUARTUS_SYNTH TOP_LEVEL bch
set_fileset_property QUARTUS_SYNTH ENABLE_RELATIVE_INCLUDE_PATHS false
add_fileset_file avalon.vhd VHDL PATH D:/CSP_BCH_RLG/BCH/src/avalon.vhd
add_fileset_file bch.vhd VHDL PATH D:/CSP_BCH_RLG/BCH/src/bch.vhd TOP_LEVEL_FILE
add_fileset_file corr.vhd VHDL PATH D:/CSP_BCH_RLG/BCH/src/corr.vhd
add_fileset_file fifo.vhd VHDL PATH D:/CSP_BCH_RLG/BCH/src/fifo.vhd
add_fileset_file lut.vhd VHDL PATH D:/CSP_BCH_RLG/BCH/src/lut.vhd
add_fileset_file syndrome.vhd VHDL PATH D:/CSP_BCH_RLG/BCH/src/syndrome.vhd
add_fileset_file uc_corr.vhd VHDL PATH D:/CSP_BCH_RLG/BCH/src/uc_corr.vhd
add_fileset_file uc_lut.vhd VHDL PATH D:/CSP_BCH_RLG/BCH/src/uc_lut.vhd
add_fileset_file uc_master.vhd VHDL PATH D:/CSP_BCH_RLG/BCH/src/uc_master.vhd
add_fileset_file uc_syndrome.vhd VHDL PATH D:/CSP_BCH_RLG/BCH/src/uc_syndrome.vhd
add_fileset_file ut_corr.vhd VHDL PATH D:/CSP_BCH_RLG/BCH/src/ut_corr.vhd
add_fileset_file ut_lut.vhd VHDL PATH D:/CSP_BCH_RLG/BCH/src/ut_lut.vhd
add_fileset_file ut_syndrome.vhd VHDL PATH D:/CSP_BCH_RLG/BCH/src/ut_syndrome.vhd


# 
# parameters
# 


# 
# display items
# 


# 
# connection point avalon_slave_0
# 
add_interface avalon_slave_0 avalon end
set_interface_property avalon_slave_0 addressUnits WORDS
set_interface_property avalon_slave_0 associatedClock clock_sink
set_interface_property avalon_slave_0 associatedReset reset_sink
set_interface_property avalon_slave_0 bitsPerSymbol 8
set_interface_property avalon_slave_0 burstOnBurstBoundariesOnly false
set_interface_property avalon_slave_0 burstcountUnits WORDS
set_interface_property avalon_slave_0 explicitAddressSpan 0
set_interface_property avalon_slave_0 holdTime 0
set_interface_property avalon_slave_0 linewrapBursts false
set_interface_property avalon_slave_0 maximumPendingReadTransactions 0
set_interface_property avalon_slave_0 readLatency 0
set_interface_property avalon_slave_0 readWaitStates 0
set_interface_property avalon_slave_0 readWaitTime 0
set_interface_property avalon_slave_0 setupTime 0
set_interface_property avalon_slave_0 timingUnits Cycles
set_interface_property avalon_slave_0 writeWaitTime 0
set_interface_property avalon_slave_0 ENABLED true
set_interface_property avalon_slave_0 EXPORT_OF ""
set_interface_property avalon_slave_0 PORT_NAME_MAP ""
set_interface_property avalon_slave_0 SVD_ADDRESS_GROUP ""

add_interface_port avalon_slave_0 w write Input 1
add_interface_port avalon_slave_0 D_in writedata Input 32
add_interface_port avalon_slave_0 D_out readdata Output 32
add_interface_port avalon_slave_0 addr address Input 2
add_interface_port avalon_slave_0 r read Input 1
set_interface_assignment avalon_slave_0 embeddedsw.configuration.isFlash 0
set_interface_assignment avalon_slave_0 embeddedsw.configuration.isMemoryDevice 0
set_interface_assignment avalon_slave_0 embeddedsw.configuration.isNonVolatileStorage 0
set_interface_assignment avalon_slave_0 embeddedsw.configuration.isPrintableDevice 0


# 
# connection point clock_sink
# 
add_interface clock_sink clock end
set_interface_property clock_sink clockRate 0
set_interface_property clock_sink ENABLED true
set_interface_property clock_sink EXPORT_OF ""
set_interface_property clock_sink PORT_NAME_MAP ""
set_interface_property clock_sink SVD_ADDRESS_GROUP ""

add_interface_port clock_sink clk clk Input 1


# 
# connection point reset_sink
# 
add_interface reset_sink reset end
set_interface_property reset_sink associatedClock clock_sink
set_interface_property reset_sink synchronousEdges DEASSERT
set_interface_property reset_sink ENABLED true
set_interface_property reset_sink EXPORT_OF ""
set_interface_property reset_sink PORT_NAME_MAP ""
set_interface_property reset_sink SVD_ADDRESS_GROUP ""

add_interface_port reset_sink reset reset Input 1


# 
# connection point interrupt_sender
# 
add_interface interrupt_sender interrupt end
set_interface_property interrupt_sender associatedAddressablePoint avalon_slave_0
set_interface_property interrupt_sender associatedClock clock_sink
set_interface_property interrupt_sender associatedReset reset_sink
set_interface_property interrupt_sender ENABLED true
set_interface_property interrupt_sender EXPORT_OF ""
set_interface_property interrupt_sender PORT_NAME_MAP ""
set_interface_property interrupt_sender SVD_ADDRESS_GROUP ""

add_interface_port interrupt_sender irq irq_n Output 1
