# Set the working dir, where all compiled Verilog goes.
vlib work

# Compile all Verilog modules in mux.v to working dir;
# could also have multiple Verilog files.
# The timescale argument defines default time unit
# (used when no unit is specified), while the second number
# defines precision (all times are rounded to this value)
vlog -timescale 1ns/1ns cipher_machine.v

# Load simulation using mv ux as the top level simulation module.
vsim cipher_top

# Log all signals and add some signals to waveform window.
log -r /*
# add wave {/*} would add all items in top level simulation module.
add wave -r {/*}


#  Load letter a.  
force {CLOCK_50} 0 0 ns, 1 1 ns -r 2
force {SW[9]} 0
force {SW[8]} 1
force {SW[7:6]} 01
force {SW[4:0]} 00001
force {KEY[2]} 1
force {KEY[0]} 0
force {KEY[1]} 1
run 10ns

# Turn off reset. 
force {KEY[0]} 1 
run 4ns 

# Load char a 
force {KEY[2]} 0
run 2ns 

force {KEY[2]} 1 
run 2ns

# Load char b
force {SW[4:0]} 00010 
force {KEY[2]} 0 
run 2ns 

force {KEY[2]} 1 
run 2ns

# Load char c
force {SW[4:0]} 00011 
force {KEY[2]} 0 
run 2ns 

force {KEY[2]} 1 
run 2ns

# Load char d
force {SW[4:0]} 00100 
force {KEY[2]} 0 
run 2ns 

force {KEY[2]} 1 
run 2ns

# Load char z
force {SW[4:0]} 11010
force {KEY[2]} 0 
run 2ns 

force {KEY[2]} 1 
run 2ns

# Load key - shifting by 3 letters.
force {SW[4:0]} 00001  
run 4ns

force {KEY[1]} 0 
run 6ns

force {KEY[1]} 1 
run 100ns 


