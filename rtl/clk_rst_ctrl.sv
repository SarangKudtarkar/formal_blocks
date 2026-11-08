// async-assert / sync-deassert reset + clock gate enabled after PLL lock
module clk_rst_ctrl (
  input  logic clk, rst_n,
  input  logic pll_lock, clk_en_req,
  output logic clk_gate_en, rst_out_n
);
  logic sync1, rst_q;
  assign rst_out_n = rst_q & rst_n;
  always_ff @(posedge clk or negedge rst_n)
    if (!rst_n) begin sync1 <= 1'b0; rst_q <= 1'b0; clk_gate_en <= 1'b0; end
    else begin
      sync1       <= pll_lock;
      rst_q       <= sync1;
      clk_gate_en <= rst_q && pll_lock && clk_en_req;
    end
endmodule
