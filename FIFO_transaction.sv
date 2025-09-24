// -------------------------------------------------------
// class: FIFO_transaction
// function: Encapsulates all I/O signals with constrains
// -------------------------------------------------------

package FIFO_transaction_pkg;
    
  class FIFO_transaction;

    // characteristics of design
    parameter FIFO_WIDTH = 16;

    // probability distribution
    int RD_EN_ON_DIST;
    int WR_EN_ON_DIST;

    // Randamize the inputs
    rand logic [FIFO_WIDTH-1:0] data_in;
    rand logic                  rst_n;
    rand logic                  wr_en;
    rand logic                  rd_en;

    // Observed Outputs
    logic [FIFO_WIDTH-1:0] data_out;
    logic                  wr_ack;
    logic                  overflow;
    logic                  full;
    logic                  empty;
    logic                  almostfull;
    logic                  almostempty;
    logic                  underflow;

    // -----------------------------------------
    // Constructor
    // Default: WR_EN_ON_DIST = 70, RD_EN_ON_DIST = 30
    // -----------------------------------------
    function new(int value_wr = 70, int value_re = 30);
      this.WR_EN_ON_DIST = value_wr;
      this.RD_EN_ON_DIST = value_re;
    endfunction


    // constraints
    constraint FIFO_constrains {
        rst_n dist {0:=1, 1:=99};
        wr_en dist {1:=WR_EN_ON_DIST, 0:=(100-WR_EN_ON_DIST)};
        rd_en dist {1:=RD_EN_ON_DIST, 0:=(100-RD_EN_ON_DIST)};
    }

  endclass

endpackage
