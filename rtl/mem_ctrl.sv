// Simple memory controller: 1 cmd/cycle, read data one cycle later
module mem_ctrl #(parameter AW = 6, W = 8) (
  input  logic clk, rst_n,
  input  logic cmd_valid, cmd_we, input logic [AW-1:0] cmd_addr, input logic [W-1:0] cmd_wdata,
  output logic cmd_ready, rd_valid, output logic [AW-1:0] rd_addr, output logic [W-1:0] rd_data
);
  logic [W-1:0] mem [2**AW];
  assign cmd_ready = !rd_valid;
  always_ff @(posedge clk or negedge rst_n)
    if (!rst_n) begin rd_valid <= 1'b0; rd_addr <= '0; rd_data <= '0; end
    else begin
      rd_valid <= 1'b0;
      if (cmd_valid && cmd_ready) begin
        if (cmd_we) mem[cmd_addr] <= cmd_wdata;
        else begin rd_valid <= 1'b1; rd_addr <= cmd_addr; rd_data <= mem[cmd_addr]; end
      end
    end
endmodule
