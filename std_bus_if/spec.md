# Standard bus interface (valid/ready register slice) - spec
Purpose : AXI-Stream style slave->master pass-through with registering.
Interface : s_valid,s_data,s_last,m_ready -> s_ready,m_valid,m_data,m_last
Requirements
- BUS-1 accepted beat => m_valid within LAT                 (forward)
- BUS-2 m_valid => beat was accepted; no duplicates         (spurious)
- BUS-3 payload stable under stall; colored beat preserved  (data integrity)
Abstraction : width reduced; use the protocol's own VIP/assume set for the master side.
Data coloring: color_trk, plus s_last color to check packet framing.
UNEARTH log : back-pressure bubbles, reset mid-packet, last on first beat.
