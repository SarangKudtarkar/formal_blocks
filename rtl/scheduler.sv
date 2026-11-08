// Round-robin scheduler; selection locks while issue_valid && !issue_ready
module scheduler #(parameter N = 4) (
  input  logic clk, rst_n,
  input  logic [N-1:0] task_rdy, input logic issue_ready,
  output logic issue_valid, output logic [$clog2(N)-1:0] issue_id
);
  localparam IW = $clog2(N);
  logic [IW-1:0] ptr, pick_id, lock_id;
  logic pick_v, locked;
  int idx;
  always_comb begin
    pick_v = 1'b0; pick_id = '0;
    for (int k = 0; k < N; k++) begin
      idx = (int'(ptr) + k) % N;
      if (!pick_v && task_rdy[idx]) begin pick_v = 1'b1; pick_id = IW'(idx); end
    end
  end
  assign issue_valid = locked || pick_v;
  assign issue_id    = locked ? lock_id : pick_id;
  always_ff @(posedge clk or negedge rst_n)
    if (!rst_n) begin ptr <= '0; locked <= 1'b0; lock_id <= '0; end
    else if (issue_valid && issue_ready) begin
      locked <= 1'b0; ptr <= IW'((int'(issue_id) + 1) % N);
    end else if (issue_valid) begin
      locked <= 1'b1; lock_id <= issue_id;
    end
endmodule
