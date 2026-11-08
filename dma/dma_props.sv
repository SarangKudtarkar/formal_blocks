module dma_fv #(parameter W = 8, LW = 4, MAXC = 256) (
  input logic clk, rst_n,
  input logic start, input logic [LW-1:0] len,
  input logic rd_valid, input logic [W-1:0] rd_data, input logic wr_ready,   // in
  input logic busy, done, rd_req, wr_valid, input logic [W-1:0] wr_data      // out
);
  default clocking cb @(posedge clk); endclocking
  default disable iff (!rst_n);
  logic [W-1:0] color; logic hit, seen;
  logic [LW-1:0] len_q, wr_cnt;
  wire in_ev = rd_valid && rd_req, out_ev = wr_valid && wr_ready;
  color_trk #(W) trk (.clk, .rst_n, .in_ev, .in_data(rd_data), .out_ev, .color, .hit, .seen);
  always_ff @(posedge clk or negedge rst_n)
    if (!rst_n) begin len_q <= '0; wr_cnt <= '0; end
    else begin
      if (start && !busy) begin len_q <= len; wr_cnt <= '0; end
      else if (out_ev)    wr_cnt <= wr_cnt + 1'b1;
    end

  asm_len_small  : assume property (len inside {[1:2**LW-1]});
  asm_start_idle : assume property (start |-> !busy);
  asm_color_stab : assume property ($stable(color));
  asm_color_once : assume property ((in_ev && rd_data == color) |-> !seen);
  asm_rd_fair    : assume property (rd_req |-> ##[1:4] rd_valid);
  asm_wr_fair    : assume property (wr_valid |-> ##[0:4] wr_ready);

  ast_fwd_done   : assert property ((start && !busy && len != 0) |-> ##[1:MAXC] done);
  ast_spur_done  : assert property (done |-> (wr_cnt == len_q));
  ast_spur_wr    : assert property (wr_valid |-> busy);
  ast_di_color   : assert property ((out_ev && hit) |-> wr_data == color);
  cov_done       : cover  property (start ##[1:MAXC] done);
  cov_color_hit  : cover  property (out_ev && hit);
endmodule
bind dma dma_fv u_fv (.*);
