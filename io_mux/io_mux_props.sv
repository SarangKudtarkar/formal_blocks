module io_mux_fv #(parameter N = 4) (
  input logic clk, rst_n,
  input logic [$clog2(N)-1:0] sel, input logic [N-1:0] func_out, input logic pad_in, // in
  input logic pad_out, input logic [N-1:0] func_in                                   // out
);
  default clocking cb @(posedge clk); endclocking
  default disable iff (!rst_n);
  logic [$clog2(N)-1:0] color_sel;
  asm_sel_range  : assume property (sel < N);
  asm_color_stab : assume property ($stable(color_sel) && color_sel < N);

  for (genvar i = 0; i < N; i++) begin : g
    ast_fwd_route : assert property ((sel == i) |-> pad_out == func_out[i]);
    ast_spur_idle : assert property ((sel != i) |-> func_in[i] == 1'b0);
    cov_sel       : cover  property ((sel == i) ##0 pad_out);
  end
  ast_spur_pad   : assert property (pad_out |-> func_out[sel]);
  ast_di_color   : assert property ((sel == color_sel) |-> pad_out == func_out[color_sel]);
  ast_di_toggle  : assert property ((sel == color_sel && $stable(sel) && $changed(func_out[color_sel])) |-> $changed(pad_out));
  ast_di_inpath  : assert property ((sel == color_sel) |-> func_in[color_sel] == pad_in);
  cov_toggle     : cover  property (sel == color_sel && $changed(pad_out));
endmodule
bind io_mux io_mux_fv u_fv (.*);
