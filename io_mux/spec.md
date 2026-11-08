# I/O mux - spec
Purpose : route one of N functional signals to a pad (and pad input back to function).
Interface : sel,func_out[N],pad_in -> pad_out,func_in[N]
Requirements
- IOM-1 pad_out == func_out[sel]                            (forward, combinational)
- IOM-2 pad_out high => selected function high; unselected func_in idle (spurious)
- IOM-3 a toggle on selected function appears at pad         (data integrity)
Abstraction : N reduced; symmetric color_sel proves all selects at once.
Data coloring: color_sel (symbolic select) + toggle-coloring of that function.
UNEARTH log : select change glitch, two functions to one pad, tri-state/OE conflicts.
