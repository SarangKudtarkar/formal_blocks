module token_gen #(parameter MAX = 15, CW = 4) (
  input  logic clk, rst_n,
  input  logic tick, consume,
  output logic token_valid, output logic [CW-1:0] token_cnt
);
  assign token_valid = (token_cnt != '0);
  always_ff @(posedge clk or negedge rst_n)
    if (!rst_n) token_cnt <= '0;
    else case ({(tick && token_cnt < MAX), (consume && token_valid)})
      2'b10:   token_cnt <= token_cnt + 1'b1;
      2'b01:   token_cnt <= token_cnt - 1'b1;
      default: ;
    endcase
endmodule
