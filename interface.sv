// -----------------------------------------------------------------------------------
// interface: IF
// function: Define all inputs and outputs used in design module and verificaiton environment
// -----------------------------------------------------------------------------------

interface IF(clk);

parameter FIFO_WIDTH = 16;
parameter FIFO_DEPTH = 8;

input bit clk;

logic [FIFO_WIDTH-1:0] data_in;
logic [FIFO_WIDTH-1:0] data_out;
logic                  rst_n;
logic                  wr_en;
logic                  rd_en;
logic                  wr_ack;
logic                  overflow;
logic                  underflow;
logic                  full;
logic                  empty;
logic                  almostfull;
logic                  almostempty;

// Port will passed to design
modport DUT(
    input  clk,
    input  rst_n,
    input  wr_en,
    input  rd_en,
    input  data_in,
    output data_out,
    output wr_ack,
    output overflow,
    output underflow,
    output full,
    output empty,
    output almostfull,
    output almostempty
  );

// Port will passed to verification environment
  modport TEST(
    output  clk,
    output  rst_n,
    output  wr_en,
    output  rd_en,
    output  data_in,
    input data_out,
    input wr_ack,
    input overflow,
    input underflow,
    input full,
    input empty,
    input almostfull,
    input almostempty
  );

endinterface