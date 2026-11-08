module biu_fv #(parameter W = 8, LAT = 16) (
  input logic clk, rst_n,
  input logic c_req, c_wr, input logic [W-1:0] c_data,
  input logic b_ready, b_rvalid, input logic [W-1:0] b_rdata,          // in
  input logic c_ack, b_req, input logic [W-1:0] b_wdata,
  input logic c_rvalid, input logic [W-1:0] c_rdata                    // out
);
  default clocking cb @(posedge clk); endclocking
  default disable iff (!rst_n);
  logic [W-1:0] color; logic hit, seen; logic pend;
  wire in_ev = b_rvalid, out_ev = c_rvalid;
  color_trk #(W) trk (.clk, .rst_n, .in_ev, .in_data(b_rdata), .out_ev, .color, .hit, .seen);
  always_ff @(posedge clk or negedge rst_n)
    if (!rst_n) pend <= 0; else if (c_req && !c_ack) pend <= 1; else if (c_ack) pend <= 0;

  asm_req_hold   : assume property ((c_req && !c_ack) |=> c_req);
  logic rd_out;   // an accepted read is awaiting its response
  always_ff @(posedge clk or negedge rst_n)
    if (!rst_n) rd_out <= 0;
    else if (b_req && b_ready && !c_wr) rd_out <= 1;
    else if (b_rvalid)                  rd_out <= 0;
  asm_rv_out     : assume property (b_rvalid |-> rd_out);
  asm_color_stab : assume property ($stable(color));
  asm_color_once : assume property ((b_rvalid && b_rdata == color) |-> !seen);
  asm_bus_fair   : assume property (b_req |-> ##[0:4] b_ready);
  asm_rd_resp    : assume property ((b_req && !c_wr && b_ready) |-> ##[1:6] b_rvalid);

  ast_fwd_ack    : assert property (c_req |-> ##[0:LAT] c_ack);
  ast_spur_breq  : assert property (b_req |-> (c_req || pend));
  ast_spur_rv    : assert property (c_rvalid |-> (b_rvalid || pend));
  ast_di_color   : assert property ((out_ev && hit) |-> c_rdata == color);
  ast_di_wdata   : assert property ((c_req && c_wr && b_req) |-> (b_wdata == c_data));
  cov_ack        : cover  property (c_req ##[0:LAT] c_ack);
  cov_color_hit  : cover  property (out_ev && hit);
endmodule
bind biu biu_fv u_fv (.*);
