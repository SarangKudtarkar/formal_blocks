module io_mux #(parameter N = 4) (
  input  logic clk, rst_n,
  input  logic [$clog2(N)-1:0] sel, input logic [N-1:0] func_out, input logic pad_in,
  output logic pad_out, output logic [N-1:0] func_in
);
  assign pad_out = func_out[sel];
  always_comb for (int i = 0; i < N; i++) func_in[i] = (sel == i) ? pad_in : 1'b0;
endmodule
