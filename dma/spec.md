# DMA controller - spec
Purpose : copy len beats from read master to write master.
Interface : start,len,rd_valid,rd_data,wr_ready -> busy,done,rd_req,wr_valid,wr_data
Requirements
- DMA-1 start && len!=0 => done within MAXC                 (forward)
- DMA-2 done => a transfer was started; wr beats == len     (spurious)
- DMA-3 colored read beat => same data on write side        (data integrity)
Abstraction : memory black-boxed (rd_data free); len bounded to small LEN_MAX.
Data coloring: color_trk from rd side (in) to wr side (out).
UNEARTH log : len==1, len==LEN_MAX, wr_ready stall, start while busy.
