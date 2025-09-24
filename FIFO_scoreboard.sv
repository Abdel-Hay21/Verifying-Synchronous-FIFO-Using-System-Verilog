// -----------------------------------------------------------------------------------
// class: FIFO_scoreboard
// function: compare the golden model with DUT
// -----------------------------------------------------------------------------------

package FIFO_scoreboard_pkg;

 // Import transaction & shared package
 import shared_pkg::*;
 import FIFO_transaction_pkg::*;

  class FIFO_scoreboard;

    // Characteristics of design
    parameter FIFO_WIDTH = 16;
    parameter FIFO_DEPTH = 8;

    
    

    // queue to simulate the functionality of fifo
    logic [FIFO_WIDTH-1:0] fifo [$];

    logic [FIFO_WIDTH-1:0] data_out_ref;
    bit                    full_ref;
    bit                    empty_ref;

    // Check Function
    function void check_data(FIFO_transaction monitor_data);
      reference_model(monitor_data);

      if(monitor_data.rst_n && monitor_data.rd_en && (data_out_ref === monitor_data.data_out))
        correct_count++;

      if(monitor_data.rst_n && monitor_data.rd_en && (data_out_ref !== monitor_data.data_out))
      begin
        error_count++;
        $display("Time:%0t, Error: At WrEn= %0b & RdEn= %0b ----> Data_out_golden = %0h   Data_out_DUT = %0h",$time ,monitor_data.wr_en ,monitor_data.rd_en ,data_out_ref ,monitor_data.data_out);
      end

    endfunction

    // Reference model: ensure the correctness of data_out
    function void reference_model(FIFO_transaction monitor_data);
      if(!monitor_data.rst_n)
      begin
        fifo.delete();
        data_out_ref = 0;
      end

      else begin
        if(monitor_data.wr_en && !full_ref)
          fifo.push_back(monitor_data.data_in);

        if(monitor_data.rd_en && !empty_ref)
          data_out_ref = fifo.pop_front;
      end

      if(fifo.size() == 0)
        empty_ref = 1;
      else
        empty_ref = 0;
      
      if(fifo.size() == FIFO_DEPTH)
        full_ref = 1;
      else
        full_ref = 0;;
        
    endfunction

    function new();
      data_out_ref  = 0;
      full_ref      = 0;
      empty_ref     = 1;
    endfunction
    
  endclass
endpackage