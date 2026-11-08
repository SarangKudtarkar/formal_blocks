# Clock / Reset control unit - spec
Purpose : gate clocks after PLL lock; release resets in order (sync deassert).
Interface : rst_in_n,pll_lock,clk_en_req -> clk_gate_en,rst_out_n
Requirements
- CRC-1 pll_lock && clk_en_req => clk_gate_en within L      (forward)
- CRC-2 rst_out_n high / clock enabled only after pll_lock  (spurious)
- CRC-3 rst_in_n low => rst_out_n low within 1 cycle; deassert is synchronous (integrity)
Abstraction : PLL black-boxed (pll_lock free, assumed to rise and stay stable).
Data coloring: N/A (control).
UNEARTH log : lock glitch, enable during reset, reset during clock-gate transition.
NOTE : checker runs on a free clock; the reset used in properties is rst_in_n.
