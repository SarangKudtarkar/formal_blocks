module scheduler_fv #(parameter N = 4, LAT = 32) (
  input logic clk, rst_n,
  input logic [N-1:0] task_rdy, input logic issue_ready,           // in
  input logic issue_valid, input logic [$clog2(N)-1:0] issue_id    // out
);
  default clocking cb @(posedge clk); endclocking
  default disable iff (!rst_n);
  logic [$clog2(N)-1:0] color_id;
  asm_color_stab : assume property ($stable(color_id));
  asm_color_rng  : assume property (color_id < N);
  for (genvar i = 0; i < N; i++) begin : g_hold
    asm_rdy_hold : assume property ((task_rdy[i] && !(issue_valid && issue_ready && issue_id == i)) |=> task_rdy[i]);
  end
  asm_ready_fair : assume property (issue_valid |-> ##[0:4] issue_ready);

  ast_fwd_issue  : assert property (task_rdy[color_id] |-> ##[0:LAT] (issue_valid && issue_id == color_id));
  ast_fwd_any    : assert property ((|task_rdy) |-> ##[0:LAT] issue_valid);
  ast_spur_valid : assert property (issue_valid |-> task_rdy[issue_id]);
  ast_spur_none  : assert property ((task_rdy == '0) |-> !issue_valid);
  ast_di_stable  : assert property ((issue_valid && !issue_ready) |=> issue_valid && $stable(issue_id));
  cov_issue_col  : cover  property (task_rdy[color_id] ##[0:LAT] (issue_valid && issue_id == color_id));
  cov_contention : cover  property ($countones(task_rdy) > 1 ##0 issue_valid);
endmodule
bind scheduler scheduler_fv u_fv (.*);
