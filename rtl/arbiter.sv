// Round-robin arbiter, combinational grant, registered pointer
module arbiter #(parameter N = 4) (
  input  logic clk, rst_n,
  input  logic [N-1:0] req,
  output logic [N-1:0] gnt
);
  localparam IW = $clog2(N);
  logic [IW-1:0] ptr;
  int idx;
  always_comb begin
    gnt = '0;
    for (int k = 0; k < N; k++) begin
      idx = (int'(ptr) + k) % N;
      if (req[idx] && gnt == '0) gnt[idx] = 1'b1;
    end
  end
  always_ff @(posedge clk or negedge rst_n)
    if (!rst_n) ptr <= '0;
    else for (int i = 0; i < N; i++) if (gnt[i]) ptr <= IW'((i + 1) % N);
endmodule
