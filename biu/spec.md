# Bus Interface Unit - spec
Purpose : translate core requests to bus transactions, return response data in order.
Interface : c_req,c_wr,c_data,b_ready,b_rvalid,b_rdata -> c_ack,b_req,b_wdata,c_rvalid,c_rdata
Requirements
- BIU-1 c_req => c_ack within LAT                           (forward)
- BIU-2 b_req => a pending c_req; c_rvalid => bus read done (spurious)
- BIU-3 read data from bus colored => same data at core     (data integrity)
Abstraction : bus slave black-boxed; address bits reduced.
Data coloring: color_trk on b_rdata -> c_rdata.
UNEARTH log : back-to-back reqs, bus error/retry, abort mid-transfer.
