// -------------------------------------------------------------------------------------------
// module: tb
// function: generate randmization and pass it to interface & start and finish the simulation
// -------------------------------------------------------------------------------------------
module tb(IF.TEST if_tb);

  import FIFO_transaction_pkg::*;
  import shared_pkg::*;


  // Number of Runs
  parameter NUM_TEST = 10_000_000;
  

  FIFO_transaction transaction_object;

  initial begin
    transaction_object = new();

    reset;
    
    for(int i=0; i< NUM_TEST; i++)
    begin
      @(negedge if_tb.clk);
      void'(transaction_object.randomize);
      pass_2_interface;
      -> pass_inputs;
    end
    test_finished = 1;


  end

  // assert of Reset
  task reset;
    begin
        if_tb.rst_n = 0;
        @(negedge if_tb.clk)
        if_tb.rst_n = 1;
    end
  endtask

  // pass transaction to interface
  task pass_2_interface;
    begin
        if_tb.rst_n   = transaction_object.rst_n;
        if_tb.wr_en   = transaction_object.wr_en;
        if_tb.rd_en   = transaction_object.rd_en;
        if_tb.data_in = transaction_object.data_in;
    end
  endtask
endmodule



