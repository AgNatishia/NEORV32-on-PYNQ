restart

add_force {/simulation_rv32i_overlay_wrapper/simulation_rv32i_overlay_i/clock} -radix hex {1 0ns} {0 5000ps} -repeat_every 10000ps
run 10000 ns

add_force {/simulation_rv32i_overlay_wrapper/simulation_rv32i_overlay_i/smartconnect_reset} -radix hex {0 0ns}
add_force {/simulation_rv32i_overlay_wrapper/simulation_rv32i_overlay_i/peripheral_reset} -radix hex {0 0ns}
add_force {/simulation_rv32i_overlay_wrapper/simulation_rv32i_overlay_i/cpu_reset} -radix hex {0 0ns}
run 10000 ns

add_force {/simulation_rv32i_overlay_wrapper/simulation_rv32i_overlay_i/smartconnect_reset} -radix hex {1 0ns}
run 1000 ns

add_force {/simulation_rv32i_overlay_wrapper/simulation_rv32i_overlay_i/peripheral_reset} -radix hex {1 0ns}
run 1000 ns

add_force {/simulation_rv32i_overlay_wrapper/simulation_rv32i_overlay_i/cpu_reset} -radix hex {1 0ns}
run 1000 ns

run 100000 ns
