module clk_rst_ctrl_fv #(parameter L = 16) (
  input logic clk, rst_n,                          // rst_n = rst_in_n here
  input logic pll_lock, clk_en_req,                // in
  input logic clk_gate_en, rst_out_n               // out
);
  default clocking cb @(posedge clk); endclocking
  default disable iff (1'b0);                      // reset behaviour is under test
  asm_lock_stable: assume property (pll_lock |=> pll_lock || !rst_n);
  asm_en_hold    : assume property ((clk_en_req && !clk_gate_en) |=> clk_en_req);

  ast_fwd_clk    : assert property ((rst_n && pll_lock && clk_en_req) |-> ##[1:L] (clk_gate_en || !rst_n));
  ast_fwd_rst    : assert property ((rst_n && pll_lock) |-> ##[1:L] (rst_out_n || !rst_n));
  ast_spur_clk   : assert property (clk_gate_en |-> (pll_lock || !rst_n));
  ast_spur_rst   : assert property ($rose(rst_out_n) |-> $past(pll_lock));
  ast_di_assert  : assert property (!rst_n |-> ##[0:1] !rst_out_n);
  ast_di_sync    : assert property ($rose(rst_out_n) |-> $past(rst_n));
  cov_clk_on     : cover  property (!clk_gate_en ##[1:L] clk_gate_en);
  cov_rst_rel    : cover  property (!rst_out_n ##[1:L] rst_out_n);
endmodule
bind clk_rst_ctrl clk_rst_ctrl_fv u_fv (.*);
