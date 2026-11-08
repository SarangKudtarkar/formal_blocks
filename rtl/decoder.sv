module decoder #(parameter AW = 3, N = 8) (
  input  logic clk, rst_n,
  input  logic en, input logic [AW-1:0] addr,
  output logic [N-1:0] sel
);
  always_comb begin
    sel = '0;
    if (en && addr < N) sel[addr] = 1'b1;
  end
endmodule
