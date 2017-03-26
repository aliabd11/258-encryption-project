# Set the working dir, where all compiled Verilog goes.
vlib work

# Compile all Verilog modules in mux.v to working dir;
# could also have multiple Verilog files.
# The timescale argument defines default time unit
# (used when no unit is specified), while the second number
# defines precision (all times are rounded to this value)
vlog -timescale 1ns/1ns cipher.v

# Load simulation using mv ux as the top level simulation module.
vsim cipher_top

# Log all signals and add some signals to waveform window.
log {/*}
# add wave {/*} would add all items in top level simulation module.
add wave {/*}


# Shifting letter b to c. 

force {CLOCK_50} 0 0 ns, 1 1 ns -r 2
force {SW[9]} 0
force {SW[8]} 1
force {SW[7:6]} 00
force {SW[4:0]} 00001
force {KEY[2]} 1
run 10ns

force {KEY[2]} 0 
run 4ns 

force {KEY[2]} 1 
run 2ns

force {SW[4:0]} 00001 
run 4ns

force {SW[7:6]} 01
run 10ns

# Shifting letter y to b.
force {KEY[2]} 0 
force {SW[7:6]} 00 
force {SW[4:0]} 11000 
run 4ns 

force {KEY[2]} 1 
run 2ns

force {SW[4:0]} 00011 
run 4ns

force {SW[7:6]} 01
run 10ns

