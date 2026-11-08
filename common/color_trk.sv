// Tracks ONE colored beat through an in-order channel.
//   in_ev / out_ev : accepted-beat events at input / output side
//   hit            : this output beat IS the colored beat
//   seen           : colored beat has already been injected (assume only once)
module color_trk #(parameter W = 8) (
  input  logic         clk, rst_n,
  input  logic         in_ev,
  input  logic [W-1:0] in_data,
  input  logic         out_ev,
  input  logic [W-1:0] color,
  output logic         hit,
  output logic         seen
);
  logic [15:0] outstanding, ahead;
  logic        active;
  wire new_col  = in_ev && (in_data == color) && !seen;
  wire pass_now = new_col && (outstanding == 0) && out_ev;  // same-cycle pass-through
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      outstanding <= '0; ahead <= '0; active <= 1'b0; seen <= 1'b0;
    end else begin
      outstanding <= outstanding + 16'(in_ev) - 16'(out_ev);
      if (new_col) begin
        seen <= 1'b1;
        if (!pass_now) begin
          active <= 1'b1;
          ahead  <= outstanding - 16'(out_ev);   // beats queued in front of it
        end
      end else if (active && out_ev) begin
        if (ahead == 0) active <= 1'b0; else ahead <= ahead - 1'b1;
      end
    end
  end
  assign hit = (active && out_ev && (ahead == 0)) || pass_now;
endmodule
