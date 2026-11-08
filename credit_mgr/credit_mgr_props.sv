module credit_mgr_fv #(parameter INIT = 8, CW = 4) (
  input logic clk, rst_n,
  input logic send_req, credit_ret,                          // in
  input logic send_grant, input logic [CW-1:0] credits       // out
);
  default clocking cb @(posedge clk); endclocking
  default disable iff (!rst_n);
  logic [CW:0] inflight;
  always_ff @(posedge clk or negedge rst_n)
    if (!rst_n) inflight <= '0;
    else inflight <= inflight + (CW+1)'(send_grant) - (CW+1)'(credit_ret);

  asm_ret_legal  : assume property (credit_ret |-> inflight != 0);   // receiver never over-returns
  asm_req_hold   : assume property ((send_req && !send_grant) |=> send_req);
  asm_ret_fair   : assume property ((inflight != 0) |-> ##[0:8] credit_ret);   // receiver returns credits

  ast_fwd_grant  : assert property ((send_req && credits > 0) |-> send_grant);
  ast_fwd_ret    : assert property ((send_req && credits == 0) |-> ##[1:32] send_grant);
  ast_spur_grant : assert property (send_grant |-> credits > 0);
  ast_spur_over  : assert property (credits <= INIT);
  ast_di_conserve: assert property (credits + inflight == INIT);
  cov_exhaust    : cover  property (credits == 0);
  cov_full       : cover  property (credits == INIT ##1 send_grant);
endmodule
bind credit_mgr credit_mgr_fv u_fv (.*);
