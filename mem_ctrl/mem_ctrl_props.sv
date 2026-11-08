module mem_ctrl_fv #(parameter AW = 6, W = 8, RL = 32) (
  input logic clk, rst_n,
  input logic cmd_valid, cmd_we, input logic [AW-1:0] cmd_addr, input logic [W-1:0] cmd_wdata, // in
  input logic cmd_ready, rd_valid, input logic [AW-1:0] rd_addr, input logic [W-1:0] rd_data   // out
);
  default clocking cb @(posedge clk); endclocking
  default disable iff (!rst_n);
  logic [AW-1:0] color_addr; logic [W-1:0] color;
  logic written; logic [7:0] rd_out;
  wire rd_acc = cmd_valid && cmd_ready && !cmd_we;
  wire wr_acc = cmd_valid && cmd_ready &&  cmd_we;
  always_ff @(posedge clk or negedge rst_n)
    if (!rst_n) begin written <= 0; rd_out <= 0; end
    else begin
      if (wr_acc && cmd_addr == color_addr) written <= 1;
      rd_out <= rd_out + 8'(rd_acc) - 8'(rd_valid);
    end

  asm_color_stab : assume property ($stable(color_addr) && $stable(color));
  asm_wr_color   : assume property ((cmd_valid && cmd_we && cmd_addr == color_addr) |-> (cmd_wdata == color && !written));
  asm_cmd_hold   : assume property ((cmd_valid && !cmd_ready) |=> cmd_valid && $stable(cmd_addr) && $stable(cmd_we));

  ast_fwd_rd     : assert property (rd_acc |-> ##[1:RL] rd_valid);
  ast_spur_rd    : assert property (rd_valid |-> (rd_out != 0));
  ast_di_color   : assert property ((rd_valid && rd_addr == color_addr && written) |-> rd_data == color);
  cov_rd_color   : cover  property (rd_valid && rd_addr == color_addr && written);
  cov_wr_color   : cover  property (wr_acc && cmd_addr == color_addr);
endmodule
bind mem_ctrl mem_ctrl_fv u_fv (.*);
