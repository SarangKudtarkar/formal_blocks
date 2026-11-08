module credit_mgr #(parameter INIT = 8, CW = 4) (
  input  logic clk, rst_n,
  input  logic send_req, credit_ret,
  output logic send_grant, output logic [CW-1:0] credits
);
  assign send_grant = send_req && (credits != '0);
  always_ff @(posedge clk or negedge rst_n)
    if (!rst_n) credits <= CW'(INIT);
    else        credits <= credits - CW'(send_grant) + CW'(credit_ret);
endmodule
