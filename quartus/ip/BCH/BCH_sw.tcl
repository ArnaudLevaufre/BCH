#
# BCH_driver.tcl
#

# Create a new driver
create_driver BCH_driver

# Associate it with some hardware known as "BCH"
set_sw_property hw_class_name BCH

# The version of this driver
set_sw_property version 13.0
set_sw_property min_compatible_hw_version 1.0

# Location in generated BSP that above sources will be copied into
set_sw_property bsp_subdirectory drivers

#driver utilisant les nouvelles API
set_sw_property supported_interrupt_apis enhanced_interrupt_api

#
# Source file listings...
#

# C/C++ source files
add_sw_property c_source src/BCHAPI.c

# asm source files
#add_sw_property asm_source src/< asm file name >.s

# Include files (*.h)
add_sw_property include_source inc/BCH_regs.h
add_sw_property include_source inc/BCHAPI.h

# This driver supports HAL and UCOSII BSP (OS) type
add_sw_property supported_bsp_type HAL
add_sw_property supported_bsp_type UCOSII

# End of file
