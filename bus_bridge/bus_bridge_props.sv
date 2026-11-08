module bus_bridge_fv #(parameter W = 8, LAT = 16) (
  input logic clk, rst_n,
  input logic s_valid, input logic [W-1:0] s_data, input logic d_ready, // in
  input logic s_ready, input logic d_valid, input logic [W-1:0] d_data   // out
);
  default clocking cb @(posedge clk); endclocking
  default disable iff (!rst_n);
  logic [W-1:0] color;  logic hit, seen;
  logic [15:0]  outst;
  wire in_ev = s_valid && s_ready, out_ev = d_valid && d_ready;
  color_trk #(W) trk (.clk, .rst_n, .in_ev, .in_data(s_data), .out_ev, .color, .hit, .seen);
  always_ff @(posedge clk or negedge rst_n)
    if (!rst_n) outst <= '0; else outst <= outst + 16'(in_ev) - 16'(out_ev);

  asm_color_stab : assume property ($stable(color));
  asm_color_once : assume property ((s_valid && s_data == color) |-> !seen);
  asm_s_hold     : assume property ((s_valid && !s_ready) |=> s_valid && $stable(s_data));
  asm_d_ready_fair: assume property (d_valid |-> ##[0:4] d_ready);

  ast_fwd_deliver: assert property (in_ev |-> ##[1:LAT] d_valid);
  ast_spur_valid : assert property (d_valid |-> (outst != 0));
  ast_spur_color : assert property ((out_ev && d_data == color) |-> hit);
  ast_di_color   : assert property ((out_ev && hit) |-> d_data == color);
  ast_di_hold    : assert property ((d_valid && !d_ready) |=> d_valid && $stable(d_data));
  cov_deliver    : cover  property (in_ev ##[1:LAT] out_ev);
  cov_color_hit  : cover  property (out_ev && hit);
endmodule
bind bus_bridge bus_bridge_fv u_fv (.*);
