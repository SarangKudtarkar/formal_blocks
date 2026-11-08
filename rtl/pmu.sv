// Power sequencer: ON -> ISO -> SAVE -> SWOFF -> OFF -> WAKE -> ON
module pmu (
  input  logic clk, rst_n,
  input  logic pwr_down_req, pwr_up_req, dom_idle, sw_ack,
  output logic iso_en, sw_en, ret_save, pwr_on
);
  typedef enum logic [2:0] {ON, ISO, SAVE, SWOFF, OFF, WAKE} st_t;
  st_t st;
  assign iso_en   = (st == ISO) || (st == SAVE) || (st == SWOFF) || (st == WAKE);
  assign sw_en    = (st == SWOFF) || (st == WAKE);
  assign ret_save = (st == SAVE);
  assign pwr_on   = (st == ON) || (st == ISO) || (st == SAVE) || (st == SWOFF);
  always_ff @(posedge clk or negedge rst_n)
    if (!rst_n) st <= ON;
    else case (st)
      ON    : if (pwr_down_req && dom_idle) st <= ISO;
      ISO   : st <= SAVE;
      SAVE  : st <= SWOFF;
      SWOFF : if (sw_ack) st <= OFF;
      OFF   : if (pwr_up_req) st <= WAKE;
      WAKE  : if (sw_ack) st <= ON;
      default: st <= ON;
    endcase
endmodule
