// Copy len beats rd -> 1-entry buffer -> wr
module dma #(parameter W = 8, LW = 4) (
  input  logic clk, rst_n,
  input  logic start, input logic [LW-1:0] len,
  input  logic rd_valid, input logic [W-1:0] rd_data, input logic wr_ready,
  output logic busy, done, rd_req, wr_valid, output logic [W-1:0] wr_data
);
  logic [LW-1:0] len_q, rd_cnt, wr_cnt;
  logic buf_v;
  wire rd_acc = rd_valid && rd_req;
  wire wr_acc = wr_valid && wr_ready;
  assign rd_req   = busy && !buf_v && (rd_cnt != len_q);
  assign wr_valid = buf_v;
  always_ff @(posedge clk or negedge rst_n)
    if (!rst_n) begin
      busy <= 0; done <= 0; buf_v <= 0; wr_data <= '0;
      len_q <= '0; rd_cnt <= '0; wr_cnt <= '0;
    end else begin
      done <= 1'b0;
      if (start && !busy) begin
        busy <= 1'b1; len_q <= len; rd_cnt <= '0; wr_cnt <= '0;
      end else begin
        if (rd_acc) begin buf_v <= 1'b1; wr_data <= rd_data; rd_cnt <= rd_cnt + 1'b1; end
        if (wr_acc) begin
          buf_v <= 1'b0; wr_cnt <= wr_cnt + 1'b1;
          if (wr_cnt + 1'b1 == len_q) begin busy <= 1'b0; done <= 1'b1; end
        end
      end
    end
endmodule
