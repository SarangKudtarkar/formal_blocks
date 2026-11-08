// Single-line blocking MSI model (all requests target the one tracked line).
// Replace with your multi-line cache; checker assumes the single-line abstraction.
module cache_coh #(parameter NC = 2, AW = 4, W = 8) (
  input  logic clk, rst_n,
  input  logic req_valid, input logic [$clog2(NC)-1:0] req_core, input logic req_wr,
  input  logic [AW-1:0] req_addr, input logic [W-1:0] req_wdata,
  output logic req_ready, resp_valid, output logic [$clog2(NC)-1:0] resp_core,
  output logic [W-1:0] resp_data, output logic [1:0] st [NC]
);
  localparam CW = $clog2(NC);
  localparam logic [1:0] I = 2'd0, S = 2'd1, M = 2'd2;
  logic [W-1:0] cdata [NC];
  logic [W-1:0] mem_d, wdata_q;
  logic busy, wr_q, owner_v;
  logic [CW-1:0] core_q, owner;

  assign req_ready  = !busy;
  assign resp_valid = busy;
  assign resp_core  = core_q;

  always_comb begin
    owner_v = 1'b0; owner = '0;
    for (int j = 0; j < NC; j++)
      if (j != int'(core_q) && st[j] == M) begin owner_v = 1'b1; owner = CW'(j); end
  end
  always_comb begin
    if (wr_q)                      resp_data = wdata_q;
    else if (st[core_q] != I)      resp_data = cdata[core_q];
    else if (owner_v)              resp_data = cdata[owner];
    else                           resp_data = mem_d;
  end

  always_ff @(posedge clk or negedge rst_n)
    if (!rst_n) begin
      busy <= 1'b0; wr_q <= 1'b0; core_q <= '0; wdata_q <= '0; mem_d <= '0;
      for (int i = 0; i < NC; i++) begin st[i] <= I; cdata[i] <= '0; end
    end else if (!busy) begin
      if (req_valid) begin busy <= 1'b1; core_q <= req_core; wr_q <= req_wr; wdata_q <= req_wdata; end
    end else begin
      busy <= 1'b0;
      if (wr_q) begin
        for (int j = 0; j < NC; j++) if (j != int'(core_q)) st[j] <= I;
        st[core_q] <= M; cdata[core_q] <= wdata_q;
      end else if (st[core_q] == I) begin
        cdata[core_q] <= resp_data; st[core_q] <= S;
        if (owner_v) begin mem_d <= cdata[owner]; st[owner] <= S; end
      end
    end
endmodule
