// ---------------------------------------------------------------------------------------------------
// module: top
// function: generate clk and pass it to interface and connect interface to design and monitor and tb
// ---------------------------------------------------------------------------------------------------
module top;
  bit clk_top;
  
  //connect clk
  IF top_if(clk_top);
  
  // connect interface to all modules
  monitor connect_if_2_monitor(top_if);
  FIFO    connect_if_2_DUT(top_if);
  tb      connect_if_2_testbench(top_if);


  initial begin
    clk_top = 0;
    forever begin
        #1
        clk_top = ~clk_top;
    end
  end

endmodule

