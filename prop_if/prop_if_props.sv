module prop_if_fv #(parameter W = 8, LAT = 8) (
  input logic clk, rst_n,
  input logic req, input logic [W-1:0] payload_in,          // in
  input logic ack, input logic [W-1:0] payload_out          // out
);
  default clocking cb @(posedge clk); endclocking
  default disable iff (!rst_n);
  logic [W-1:0] color;
  asm_req_hold   : assume property ((req && !ack) |=> req && $stable(payload_in));
  asm_req_low    : assume property (ack |=> !req);                        // 4-phase
  asm_color_stab : assume property ($stable(color));

  ast_fwd_ack    : assert property (req |-> ##[0:LAT] ack);
  ast_spur_ack   : assert property (ack |-> req);
  ast_spur_rel   : assert property ($fell(req) |-> !ack);
  ast_di_stable  : assert property ((req && !ack) |=> $stable(payload_out));
  ast_di_color   : assert property ((req && payload_in == color && ack) |-> payload_out == color);
  cov_ack        : cover  property (req ##[0:LAT] ack);
  cov_color      : cover  property (req && payload_in == color && ack);
endmodule
bind prop_if prop_if_fv u_fv (.*);
