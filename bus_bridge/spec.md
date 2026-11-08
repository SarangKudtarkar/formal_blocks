# Bus bridge - spec
Purpose : move beats from source bus (s_*) to destination bus (d_*), in order.
Interface : s_valid,s_data,d_ready -> s_ready,d_valid,d_data
Requirements
- BRG-1 accepted s beat => d_valid within LAT                (forward)
- BRG-2 d_valid => at least one beat outstanding             (spurious)
- BRG-3 colored s_data => same colored d_data, in order      (data integrity)
Abstraction : data width reduced to W; FIFO depth counter-abstracted.
Data coloring: color_trk follows ONE colored beat end-to-end.
UNEARTH log : back-to-back beats, d_ready stall, FIFO full/empty edges.
