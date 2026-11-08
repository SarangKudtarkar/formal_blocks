# Memory controller - spec
Purpose : accept read/write commands, drive memory, return read data (tagged by address).
Interface : cmd_valid,cmd_we,cmd_addr,cmd_wdata -> cmd_ready,rd_valid,rd_addr,rd_data
Requirements
- MEM-1 accepted read => rd_valid within RL                  (forward)
- MEM-2 rd_valid => an outstanding read exists               (spurious)
- MEM-3 read of color_addr after colored write returns color (data integrity)
Abstraction : MEMORY ABSTRACTION - model only ONE symbolic location (color_addr);
              all other addresses are don't-care.
Data coloring: color_addr (address color) + color (data color).
UNEARTH log : read-after-write same cycle, refresh, bank conflict, write to color_addr twice.
