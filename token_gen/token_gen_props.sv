module token_gen_fv #(parameter MAX = 15, CW = 4) (
  input logic clk, rst_n,
  input logic tick, consume,                       // in
  input logic token_valid, input logic [CW-1:0] token_cnt  // out
);
  default clocking cb @(posedge clk); endclocking
  default disable iff (!rst_n);
  logic [CW:0] ref_cnt;
  wire inc = tick && (ref_cnt < MAX), dec = consume && token_valid;
  always_ff @(posedge clk or negedge rst_n)
    if (!rst_n) ref_cnt <= '0; else ref_cnt <= ref_cnt + (CW+1)'(inc) - (CW+1)'(dec);

  asm_consume_ok : assume property (consume |-> token_valid);

  ast_fwd_inc    : assert property ((tick && token_cnt < MAX) |=> token_cnt >= $past(token_cnt) || $past(consume));
  ast_spur_valid : assert property (token_valid |-> token_cnt != 0);
  ast_spur_gen   : assert property ((!tick && !consume) |=> token_cnt == $past(token_cnt));
  ast_di_ref     : assert property (token_cnt == ref_cnt);
  ast_di_max     : assert property (token_cnt <= MAX);
  cov_full       : cover  property (token_cnt == MAX);
  cov_empty_hit  : cover  property (consume ##1 token_cnt == 0);
endmodule
bind token_gen token_gen_fv u_fv (.*);
