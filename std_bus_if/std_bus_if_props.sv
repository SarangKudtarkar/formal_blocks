module std_bus_if_fv #(parameter W = 8, LAT = 8) (
  input logic clk, rst_n,
  input logic s_valid, input logic [W-1:0] s_data, input logic s_last, input logic m_ready, // in
  input logic s_ready, m_valid, input logic [W-1:0] m_data, input logic m_last             // out
);
  default clocking cb @(posedge clk); endclocking
  default disable iff (!rst_n);
  logic [W-1:0] color; logic hit, seen; logic [7:0] outst;
  wire in_ev = s_valid && s_ready, out_ev = m_valid && m_ready;
  color_trk #(W) trk (.clk, .rst_n, .in_ev, .in_data(s_data), .out_ev, .color, .hit, .seen);
  always_ff @(posedge clk or negedge rst_n)
    if (!rst_n) outst <= 0; else outst <= outst + 8'(in_ev) - 8'(out_ev);

  asm_s_stable   : assume property ((s_valid && !s_ready) |=> s_valid && $stable(s_data) && $stable(s_last));
  asm_m_fair     : assume property (m_valid |-> ##[0:4] m_ready);
  asm_color_stab : assume property ($stable(color));
  asm_color_once : assume property ((s_valid && s_data == color) |-> !seen);

  ast_fwd_pass   : assert property (in_ev |-> ##[1:LAT] m_valid);
  ast_spur_valid : assert property (m_valid |-> (outst != 0));
  ast_di_stable  : assert property ((m_valid && !m_ready) |=> m_valid && $stable(m_data) && $stable(m_last));
  ast_di_color   : assert property ((out_ev && hit) |-> m_data == color);
  cov_pass       : cover  property (in_ev ##[1:LAT] out_ev);
  cov_color_hit  : cover  property (out_ev && hit);
  cov_last       : cover  property (out_ev && m_last);
endmodule
bind std_bus_if std_bus_if_fv u_fv (.*);
