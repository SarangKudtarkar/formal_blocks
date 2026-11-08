module decoder_fv #(parameter AW = 3, N = 8) (
  input logic clk, rst_n,
  input logic en, input logic [AW-1:0] addr,   // inputs  (left)
  input logic [N-1:0] sel                      // outputs (right)
);
  default clocking cb @(posedge clk); endclocking
  default disable iff (!rst_n);
  logic [AW-1:0] color_addr;                   // data color (free symbolic)

  // ---- assumes
  asm_addr_range : assume property (addr < N);
  asm_color_stab : assume property ($stable(color_addr));
  asm_color_range: assume property (color_addr < N);

  // ---- forward
  for (genvar i = 0; i < N; i++) begin : g
    ast_fwd_sel  : assert property ((en && addr == i) |-> sel[i]);
    ast_spur_sel : assert property (sel[i] |-> (en && addr == i));   // spurious
    cov_sel      : cover  property ((en && addr == i) ##0 sel[i]);
  end
  ast_fwd_onehot : assert property (en  |-> $onehot(sel));
  ast_spur_idle  : assert property (!en |-> sel == '0);
  // ---- data integrity (colored address)
  ast_di_color   : assert property ((en && addr == color_addr) |-> sel[color_addr]);
  cov_di_color   : cover  property ((en && addr == color_addr) ##0 sel[color_addr]);
endmodule
bind decoder decoder_fv u_fv (.*);
