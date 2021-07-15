restart

# Setup Clock
add_force {/processor_stepper/s00_axi_aclk} -radix hex {1 0ns} {0 5000ps} -repeat_every 10000ps
run 100 ns

# Enter reset
add_force {/processor_stepper/s00_axi_aresetn} -radix hex {0 0ns}
run 50 ns

# Setup PC
add_force {/processor_stepper/curr_PC} -radix hex {0 0ns}
# Setup Axi write addr channal as idle
add_force {/processor_stepper/s00_axi_awvalid} -radix hex {0 0ns}
add_force {/processor_stepper/s00_axi_awaddr} -radix hex {0 0ns}
add_force {/processor_stepper/s00_axi_awprot} -radix hex {0 0ns}
# Setup Axi write data channal as idle
add_force {/processor_stepper/s00_axi_wvalid} -radix hex {0 0ns}
add_force {/processor_stepper/s00_axi_wstrb} -radix hex {f 0ns}
add_force {/processor_stepper/s00_axi_wdata} -radix hex {0 0ns}
# Setup Axi write resp channal as constant sink
add_force {/processor_stepper/s00_axi_bready} -radix hex {1 0ns}
# Setup Axi read addr channal as idle
add_force {/processor_stepper/s00_axi_arvalid} -radix hex {0 0ns}
add_force {/processor_stepper/s00_axi_araddr} -radix hex {0 0ns}
add_force {/processor_stepper/s00_axi_arprot} -radix hex {0 0ns}
# Setup Axi read data channal as idle
add_force {/processor_stepper/s00_axi_rready} -radix hex {0 0ns}
run 50 ns

# Exit reset
add_force {/processor_stepper/s00_axi_aresetn} -radix hex {1 0ns}
run 100 ns

# Start continous mode
add_force {/processor_stepper/s00_axi_awaddr} -radix hex {0 0ns}
add_force {/processor_stepper/s00_axi_awvalid} -radix hex {1 0ns}
add_force {/processor_stepper/s00_axi_wdata} -radix hex {00000100 0ns}
add_force {/processor_stepper/s00_axi_wvalid} -radix hex {1 0ns}
run 20 ns
add_force {/processor_stepper/s00_axi_awvalid} -radix hex {0 0ns}
add_force {/processor_stepper/s00_axi_wvalid} -radix hex {0 0ns}
run 200 ns

# End continous mode
add_force {/processor_stepper/s00_axi_awaddr} -radix hex {0 0ns}
add_force {/processor_stepper/s00_axi_awvalid} -radix hex {1 0ns}
add_force {/processor_stepper/s00_axi_wdata} -radix hex {0 0ns}
add_force {/processor_stepper/s00_axi_wvalid} -radix hex {1 0ns}
run 20 ns
add_force {/processor_stepper/s00_axi_awvalid} -radix hex {0 0ns}
add_force {/processor_stepper/s00_axi_wvalid} -radix hex {0 0ns}

# intertest gap
run 250 ns

# Test clock step rule
add_force {/processor_stepper/s00_axi_awaddr} -radix hex {0 0ns}
add_force {/processor_stepper/s00_axi_awvalid} -radix hex {1 0ns}
add_force {/processor_stepper/s00_axi_wdata} -radix hex {00010000 0ns}
add_force {/processor_stepper/s00_axi_wvalid} -radix hex {1 0ns}
run 20 ns
add_force {/processor_stepper/s00_axi_awvalid} -radix hex {0 0ns}
add_force {/processor_stepper/s00_axi_wvalid} -radix hex {0 0ns}
run 200 ns

# intertest gap
run 250 ns

# Test clock counter rule with a count of 8
add_force {/processor_stepper/s00_axi_awaddr} -radix hex {4 0ns}
add_force {/processor_stepper/s00_axi_awvalid} -radix hex {1 0ns}
add_force {/processor_stepper/s00_axi_wdata} -radix hex {8 0ns}
add_force {/processor_stepper/s00_axi_wvalid} -radix hex {1 0ns}
run 20 ns
add_force {/processor_stepper/s00_axi_awvalid} -radix hex {0 0ns}
add_force {/processor_stepper/s00_axi_wvalid} -radix hex {0 0ns}
run 10 ns
add_force {/processor_stepper/s00_axi_awaddr} -radix hex {0 0ns}
add_force {/processor_stepper/s00_axi_awvalid} -radix hex {1 0ns}
add_force {/processor_stepper/s00_axi_wdata} -radix hex {00020000 0ns}
add_force {/processor_stepper/s00_axi_wvalid} -radix hex {1 0ns}
run 20 ns
add_force {/processor_stepper/s00_axi_awvalid} -radix hex {0 0ns}
add_force {/processor_stepper/s00_axi_wvalid} -radix hex {0 0ns}
run 200 ns

# intertest gap
run 250 ns

# Test PC step rule
add_force {/processor_stepper/s00_axi_awaddr} -radix hex {0 0ns}
add_force {/processor_stepper/s00_axi_awvalid} -radix hex {1 0ns}
add_force {/processor_stepper/s00_axi_wdata} -radix hex {01000000 0ns}
add_force {/processor_stepper/s00_axi_wvalid} -radix hex {1 0ns}
run 20 ns
add_force {/processor_stepper/s00_axi_awvalid} -radix hex {0 0ns}
add_force {/processor_stepper/s00_axi_wvalid} -radix hex {0 0ns}
run 100 ns
add_force {/processor_stepper/curr_PC} -radix hex {4 0ns}
run 100 ns

# intertest gap
run 250 ns

# Test PC counter rule with a count of 8
add_force {/processor_stepper/s00_axi_awaddr} -radix hex {8 0ns}
add_force {/processor_stepper/s00_axi_awvalid} -radix hex {1 0ns}
add_force {/processor_stepper/s00_axi_wdata} -radix hex {8 0ns}
add_force {/processor_stepper/s00_axi_wvalid} -radix hex {1 0ns}
run 20 ns
add_force {/processor_stepper/s00_axi_awvalid} -radix hex {0 0ns}
add_force {/processor_stepper/s00_axi_wvalid} -radix hex {0 0ns}
run 10 ns
add_force {/processor_stepper/s00_axi_awaddr} -radix hex {0 0ns}
add_force {/processor_stepper/s00_axi_awvalid} -radix hex {1 0ns}
add_force {/processor_stepper/s00_axi_wdata} -radix hex {02000000 0ns}
add_force {/processor_stepper/s00_axi_wvalid} -radix hex {1 0ns}
run 20 ns
add_force {/processor_stepper/s00_axi_awvalid} -radix hex {0 0ns}
add_force {/processor_stepper/s00_axi_wvalid} -radix hex {0 0ns}
run 50 ns
add_force {/processor_stepper/curr_PC} -radix hex {10 0ns}
run 30 ns
add_force {/processor_stepper/curr_PC} -radix hex {14 0ns}
run 10 ns
add_force {/processor_stepper/curr_PC} -radix hex {18 0ns}
run 80 ns
add_force {/processor_stepper/curr_PC} -radix hex {1C 0ns}
run 50 ns
add_force {/processor_stepper/curr_PC} -radix hex {10 0ns}
run 30 ns
add_force {/processor_stepper/curr_PC} -radix hex {14 0ns}
run 10 ns
add_force {/processor_stepper/curr_PC} -radix hex {18 0ns}
run 80 ns
add_force {/processor_stepper/curr_PC} -radix hex {1C 0ns}
run 100 ns

# intertest gap
run 250 ns

# Test PC to rule with a count of 8
add_force {/processor_stepper/s00_axi_awaddr} -radix hex {C 0ns}
add_force {/processor_stepper/s00_axi_awvalid} -radix hex {1 0ns}
add_force {/processor_stepper/s00_axi_wdata} -radix hex {30 0ns}
add_force {/processor_stepper/s00_axi_wvalid} -radix hex {1 0ns}
run 20 ns
add_force {/processor_stepper/s00_axi_awvalid} -radix hex {0 0ns}
add_force {/processor_stepper/s00_axi_wvalid} -radix hex {0 0ns}
run 10 ns
add_force {/processor_stepper/s00_axi_awaddr} -radix hex {0 0ns}
add_force {/processor_stepper/s00_axi_awvalid} -radix hex {1 0ns}
add_force {/processor_stepper/s00_axi_wdata} -radix hex {04000000 0ns}
add_force {/processor_stepper/s00_axi_wvalid} -radix hex {1 0ns}
run 20 ns
add_force {/processor_stepper/s00_axi_awvalid} -radix hex {0 0ns}
add_force {/processor_stepper/s00_axi_wvalid} -radix hex {0 0ns}
run 50 ns
add_force {/processor_stepper/curr_PC} -radix hex {20 0ns}
run 30 ns
add_force {/processor_stepper/curr_PC} -radix hex {24 0ns}
run 10 ns
add_force {/processor_stepper/curr_PC} -radix hex {40 0ns}
run 80 ns
add_force {/processor_stepper/curr_PC} -radix hex {44 0ns}
run 50 ns
add_force {/processor_stepper/curr_PC} -radix hex {48 0ns}
run 60 ns
add_force {/processor_stepper/curr_PC} -radix hex {4C 0ns}
run 30 ns
add_force {/processor_stepper/curr_PC} -radix hex {30 0ns}
run 100 ns

# intertest gap
run 250 ns

# Test first.all rule, using clock count 32 and PC counter 4, all
add_force {/processor_stepper/s00_axi_awaddr} -radix hex {4 0ns}
add_force {/processor_stepper/s00_axi_awvalid} -radix hex {1 0ns}
add_force {/processor_stepper/s00_axi_wdata} -radix hex {20 0ns}
add_force {/processor_stepper/s00_axi_wvalid} -radix hex {1 0ns}
run 20 ns
add_force {/processor_stepper/s00_axi_awvalid} -radix hex {0 0ns}
add_force {/processor_stepper/s00_axi_wvalid} -radix hex {0 0ns}
run 10 ns
add_force {/processor_stepper/s00_axi_awaddr} -radix hex {8 0ns}
add_force {/processor_stepper/s00_axi_awvalid} -radix hex {1 0ns}
add_force {/processor_stepper/s00_axi_wdata} -radix hex {4 0ns}
add_force {/processor_stepper/s00_axi_wvalid} -radix hex {1 0ns}
run 20 ns
add_force {/processor_stepper/s00_axi_awvalid} -radix hex {0 0ns}
add_force {/processor_stepper/s00_axi_wvalid} -radix hex {0 0ns}
run 10 ns
add_force {/processor_stepper/s00_axi_awaddr} -radix hex {0 0ns}
add_force {/processor_stepper/s00_axi_awvalid} -radix hex {1 0ns}
add_force {/processor_stepper/s00_axi_wdata} -radix hex {02020000 0ns}
add_force {/processor_stepper/s00_axi_wvalid} -radix hex {1 0ns}
run 20 ns
add_force {/processor_stepper/s00_axi_awvalid} -radix hex {0 0ns}
add_force {/processor_stepper/s00_axi_wvalid} -radix hex {0 0ns}
run 50 ns
add_force {/processor_stepper/curr_PC} -radix hex {80 0ns}
run 50 ns
add_force {/processor_stepper/curr_PC} -radix hex {84 0ns}
run 50 ns
add_force {/processor_stepper/curr_PC} -radix hex {80 0ns}
run 50 ns
add_force {/processor_stepper/curr_PC} -radix hex {8C 0ns}
run 50 ns
add_force {/processor_stepper/curr_PC} -radix hex {80 0ns}
run 50 ns
add_force {/processor_stepper/curr_PC} -radix hex {84 0ns}
run 50 ns
add_force {/processor_stepper/curr_PC} -radix hex {80 0ns}
run 50 ns
add_force {/processor_stepper/curr_PC} -radix hex {8C 0ns}
run 50 ns

# intertest gap
run 250 ns

# Test first.all rule, using clock count 32 and PC counter 4, first
add_force {/processor_stepper/s00_axi_awaddr} -radix hex {4 0ns}
add_force {/processor_stepper/s00_axi_awvalid} -radix hex {1 0ns}
add_force {/processor_stepper/s00_axi_wdata} -radix hex {20 0ns}
add_force {/processor_stepper/s00_axi_wvalid} -radix hex {1 0ns}
run 20 ns
add_force {/processor_stepper/s00_axi_awvalid} -radix hex {0 0ns}
add_force {/processor_stepper/s00_axi_wvalid} -radix hex {0 0ns}
run 10 ns
add_force {/processor_stepper/s00_axi_awaddr} -radix hex {8 0ns}
add_force {/processor_stepper/s00_axi_awvalid} -radix hex {1 0ns}
add_force {/processor_stepper/s00_axi_wdata} -radix hex {4 0ns}
add_force {/processor_stepper/s00_axi_wvalid} -radix hex {1 0ns}
run 20 ns
add_force {/processor_stepper/s00_axi_awvalid} -radix hex {0 0ns}
add_force {/processor_stepper/s00_axi_wvalid} -radix hex {0 0ns}
run 10 ns
add_force {/processor_stepper/s00_axi_awaddr} -radix hex {0 0ns}
add_force {/processor_stepper/s00_axi_awvalid} -radix hex {1 0ns}
add_force {/processor_stepper/s00_axi_wdata} -radix hex {02020001 0ns}
add_force {/processor_stepper/s00_axi_wvalid} -radix hex {1 0ns}
run 20 ns
add_force {/processor_stepper/s00_axi_awvalid} -radix hex {0 0ns}
add_force {/processor_stepper/s00_axi_wvalid} -radix hex {0 0ns}
run 50 ns
add_force {/processor_stepper/curr_PC} -radix hex {80 0ns}
run 50 ns
add_force {/processor_stepper/curr_PC} -radix hex {84 0ns}
run 50 ns
add_force {/processor_stepper/curr_PC} -radix hex {80 0ns}
run 50 ns
add_force {/processor_stepper/curr_PC} -radix hex {8C 0ns}
run 50 ns
add_force {/processor_stepper/curr_PC} -radix hex {80 0ns}
run 50 ns
add_force {/processor_stepper/curr_PC} -radix hex {84 0ns}
run 50 ns
add_force {/processor_stepper/curr_PC} -radix hex {80 0ns}
run 50 ns
add_force {/processor_stepper/curr_PC} -radix hex {8C 0ns}
run 50 ns
