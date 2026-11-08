module cache_coh_fv #(parameter NC = 2, AW = 4, W = 8, LAT = 32) (
  input logic clk, rst_n,
  input logic req_valid, input logic [$clog2(NC)-1:0] req_core, input logic req_wr,
  input logic [AW-1:0] req_addr, input logic [W-1:0] req_wdata,               // in
  input logic req_ready, resp_valid, input logic [$clog2(NC)-1:0] resp_core,
  input logic [W-1:0] resp_data, input logic [1:0] st [NC]                   // out (st: 0=I 1=S 2=M)
);
  localparam I = 2'd0, S = 2'd1, M = 2'd2;
  default clocking cb @(posedge clk); endclocking
  default disable iff (!rst_n);
  logic [AW-1:0] color_addr; logic [W-1:0] color;
  logic col_latest; logic [7:0] outst;
  wire acc = req_valid && req_ready;
  always_ff @(posedge clk or negedge rst_n)
    if (!rst_n) begin col_latest <= 0; outst <= 0; end
    else begin
      outst <= outst + 8'(acc) - 8'(resp_valid);
      if (acc && req_wr) col_latest <= (req_wdata == color);
    end

  asm_color_stab : assume property ($stable(color_addr) && $stable(color));
  asm_one_line   : assume property (req_valid |-> req_addr == color_addr);      // abstraction
  asm_req_hold   : assume property ((req_valid && !req_ready) |=> req_valid && $stable(req_core) && $stable(req_wr));

  ast_fwd_resp   : assert property (acc |-> ##[1:LAT] resp_valid);
  ast_spur_resp  : assert property (resp_valid |-> (outst != 0));
  for (genvar i = 0; i < NC; i++) for (genvar j = 0; j < NC; j++) if (i != j) begin : swmr
    ast_spur_swmr : assert property ((st[i] == M) |-> (st[j] == I));            // SWMR
    ast_spur_shr  : assert property ((st[i] == S) |-> (st[j] != M));
  end
  ast_di_color   : assert property ((resp_valid && col_latest && outst == 1) |-> resp_data == color);
  cov_m_state    : cover  property (st[0] == M);
  cov_share      : cover  property (st[0] == S && st[1] == S);
  cov_color_rd   : cover  property (resp_valid && col_latest);
endmodule
bind cache_coh cache_coh_fv u_fv (.*);
