// 4-phase req/ack (ack is a one-cycle registered pulse; payload passes through)
module prop_if #(parameter W = 8) (
  input  logic clk, rst_n,
  input  logic req, input logic [W-1:0] payload_in,
  output logic ack, output logic [W-1:0] payload_out
);
  assign payload_out = payload_in;
  always_ff @(posedge clk or negedge rst_n)
    if (!rst_n) ack <= 1'b0; else ack <= req && !ack;
endmodule
