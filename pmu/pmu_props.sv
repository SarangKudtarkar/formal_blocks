module pmu_fv #(parameter T = 32) (
  input logic clk, rst_n,
  input logic pwr_down_req, pwr_up_req, dom_idle, sw_ack,        // inputs  (left)
  input logic iso_en, sw_en, ret_save, pwr_on                    // outputs (right)
);
  default clocking cb @(posedge clk); endclocking
  default disable iff (!rst_n);
  logic req_seen, ret_seen, pwr_on_q;
  always_ff @(posedge clk or negedge rst_n)
    if (!rst_n) begin req_seen <= 0; ret_seen <= 0; pwr_on_q <= 1; end
    else begin
      pwr_on_q <= pwr_on;
      if (pwr_down_req) req_seen <= 1;
      if (pwr_on && !pwr_on_q) ret_seen <= 0;
      else if (ret_save)       ret_seen <= 1;
    end

  asm_no_both    : assume property (!(pwr_down_req && pwr_up_req));
  asm_down_hold  : assume property ((pwr_down_req && pwr_on) |=> pwr_down_req || !pwr_on);
  asm_ack_delay  : assume property (sw_en |-> ##[1:4] sw_ack);

  ast_fwd_down   : assert property ((pwr_down_req && dom_idle && pwr_on) |-> ##[1:T] !pwr_on);
  ast_fwd_up     : assert property ((pwr_up_req && !pwr_on) |-> ##[1:T] pwr_on);
  ast_spur_iso   : assert property (iso_en |-> req_seen);
  ast_spur_off   : assert property ($fell(pwr_on) |-> $past(iso_en));      // ordering
  ast_di_ret     : assert property ($fell(pwr_on) |-> ret_seen);   // retention saved before off
  cov_down       : cover  property (pwr_down_req ##[1:T] !pwr_on);
  cov_up         : cover  property (!pwr_on ##[1:T] pwr_on);
endmodule
bind pmu pmu_fv u_fv (.*);
