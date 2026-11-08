// Single-entry register slice (s_* -> d_*)
module bus_bridge #(parameter W = 8) (
  input  logic clk, rst_n,
  input  logic s_valid, input logic [W-1:0] s_data, input logic d_ready,
  output logic s_ready, output logic d_valid, output logic [W-1:0] d_data
);
  assign s_ready = !d_valid || d_ready;
  always_ff @(posedge clk or negedge rst_n)
    if (!rst_n) begin d_valid <= 1'b0; d_data <= '0; end
    else if (s_valid && s_ready) begin d_valid <= 1'b1; d_data <= s_data; end
    else if (d_ready)            d_valid <= 1'b0;
endmodule
