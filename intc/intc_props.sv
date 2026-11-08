module intc_fv #(parameter N = 8, L = 8) (
  input logic clk, rst_n,
  input logic [N-1:0] irq_src, mask, input logic ack,                // in
  input logic irq_out, input logic [$clog2(N)-1:0] irq_id            // out
);
  default clocking cb @(posedge clk); endclocking
  default disable iff (!rst_n);
  logic [$clog2(N)-1:0] color_id;
  logic [N-1:0] pend;
  asm_color_stab : assume property ($stable(color_id));
  asm_color_rng  : assume property (color_id < N);
  asm_src_hold   : assume property ((irq_src[color_id] && !ack) |=> irq_src[color_id]);
  asm_ack_after  : assume property (ack |-> irq_out);
  asm_mask_hold  : assume property ((irq_src[color_id] && !mask[color_id]) |=> !mask[color_id]);

  always_ff @(posedge clk or negedge rst_n)
    if (!rst_n) pend <= '0;
    else begin
      pend <= pend | irq_src;
      if (ack) pend[irq_id] <= irq_src[irq_id];
    end

  ast_fwd_irq    : assert property ((irq_src[color_id] && !mask[color_id]) |-> ##[1:L] irq_out);
  ast_spur_irq   : assert property (irq_out |-> |(pend & ~mask));
  ast_spur_none  : assert property (((pend & ~mask) == '0) |-> !irq_out);
  ast_di_id_pend : assert property (irq_out |-> (pend[irq_id] && !mask[irq_id]));
  ast_di_prio    : assert property ((irq_out) |-> (irq_id == color_id || !(pend[color_id] && !mask[color_id]) || irq_id < color_id));
  cov_irq        : cover  property (irq_src[color_id] ##[1:L] irq_out && irq_id == color_id);
endmodule
bind intc intc_fv u_fv (.*);
