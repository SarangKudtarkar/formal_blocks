# Cache coherency - spec (MSI, NC cores)
Purpose : keep per-core line states and data coherent.
Interface : req_valid,req_core,req_wr,req_addr,req_wdata -> resp_valid,resp_core,resp_data,st[NC]
Requirements
- COH-1 req => resp within LAT                              (forward)
- COH-2 resp_valid => outstanding req;  M in core i => I elsewhere (spurious / SWMR)
- COH-3 read after colored write returns color               (data integrity)
Abstraction : SINGLE-LINE abstraction (addr == color_addr only), NC=2, data width W.
Data coloring: color_addr + color write data; latest-value flag in checker.
UNEARTH log : upgrade race (S->M both cores), writeback vs snoop, evict during miss.
