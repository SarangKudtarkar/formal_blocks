// Latching interrupt controller; lowest index = highest priority
module intc #(parameter N = 8) (
  input  logic clk, rst_n,
  input  logic [N-1:0] irq_src, mask, input logic ack,
  output logic irq_out, output logic [$clog2(N)-1:0] irq_id
);
  localparam IW = $clog2(N);
  logic [N-1:0] pend, act;
  assign act     = pend & ~mask;
  assign irq_out = |act;
  always_comb begin
    irq_id = '0;
    for (int i = N-1; i >= 0; i--) if (act[i]) irq_id = IW'(i);
  end
  always_ff @(posedge clk or negedge rst_n)
    if (!rst_n) pend <= '0;
    else begin
      pend <= pend | irq_src;
      if (ack) pend[irq_id] <= irq_src[irq_id];
    end
endmodule
