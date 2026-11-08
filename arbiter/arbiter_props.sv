module arbiter_fv #(parameter N = 4, LAT = 8) (
  input logic clk, rst_n,
  input logic [N-1:0] req,                     // inputs  (left)
  input logic [N-1:0] gnt                      // outputs (right)
);
  default clocking cb @(posedge clk); endclocking
  default disable iff (!rst_n);
  logic [$clog2(N)-1:0] color_id;              // data color: requester id
  asm_color_stab : assume property ($stable(color_id));
  asm_color_rng  : assume property (color_id < N);

  for (genvar i = 0; i < N; i++) begin : g
    asm_hold     : assume property ((req[i] && !gnt[i]) |=> req[i]);
    ast_spur_gnt : assert property (gnt[i] |-> req[i]);
    cov_gnt      : cover  property (req[i] ##0 gnt[i]);
  end
  ast_fwd_any    : assert property ((|req) |-> ##[0:LAT] (|gnt));
  ast_spur_none  : assert property ((req == '0) |-> gnt == '0);
  ast_di_onehot0 : assert property ($onehot0(gnt));
  // forward progress per requester via ONE colored proof (abstraction)
  ast_fwd_color  : assert property (req[color_id] |-> ##[0:LAT] gnt[color_id]);
  cov_contention : cover  property ($countones(req) > 1 ##0 |gnt);
endmodule
bind arbiter arbiter_fv u_fv (.*);
