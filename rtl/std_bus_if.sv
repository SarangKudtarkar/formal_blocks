// valid/ready register slice
module std_bus_if #(parameter W = 8) (
  input  logic clk, rst_n,
  input  logic s_valid, input logic [W-1:0] s_data, input logic s_last, input logic m_ready,
  output logic s_ready, m_valid, output logic [W-1:0] m_data, output logic m_last
);
  assign s_ready = !m_valid || m_ready;
  always_ff @(posedge clk or negedge rst_n)
    if (!rst_n) begin m_valid <= 1'b0; m_data <= '0; m_last <= 1'b0; end
    else if (s_valid && s_ready) begin m_valid <= 1'b1; m_data <= s_data; m_last <= s_last; end
    else if (m_ready)            m_valid <= 1'b0;
endmodule
