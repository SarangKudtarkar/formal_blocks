// Core -> bus unit: writes ack on bus accept, reads ack on read data
module biu #(parameter W = 8) (
  input  logic clk, rst_n,
  input  logic c_req, c_wr, input logic [W-1:0] c_data,
  input  logic b_ready, b_rvalid, input logic [W-1:0] b_rdata,
  output logic c_ack, b_req, output logic [W-1:0] b_wdata,
  output logic c_rvalid, output logic [W-1:0] c_rdata
);
  typedef enum logic {IDLE, WAIT_R} st_t;
  st_t st;
  assign b_req    = (st == IDLE) && c_req;
  assign b_wdata  = c_data;
  assign c_rvalid = (st == WAIT_R) && b_rvalid;
  assign c_rdata  = b_rdata;
  assign c_ack    = ((st == IDLE) && c_req && c_wr && b_ready) || c_rvalid;
  always_ff @(posedge clk or negedge rst_n)
    if (!rst_n) st <= IDLE;
    else case (st)
      IDLE   : if (c_req && !c_wr && b_ready) st <= WAIT_R;
      WAIT_R : if (b_rvalid) st <= IDLE;
    endcase
endmodule
