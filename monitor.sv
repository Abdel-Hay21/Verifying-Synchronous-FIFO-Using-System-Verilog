// ---------------------------------------------------------------------------------------------------
// module: monitor
// function: sample the I/O in correct time and pass them to scoreboard & coverage
// ---------------------------------------------------------------------------------------------------
module monitor(IF.TEST if_monitor);

import shared_pkg::*;
import FIFO_transaction_pkg::*;
import FIFO_coverage_pkg::*;
import FIFO_scoreboard_pkg::*;

FIFO_coverage    coverage_object;
FIFO_transaction transaction_object;
FIFO_scoreboard  scoreboard_object;

initial begin
    coverage_object    = new();
    transaction_object = new();
    scoreboard_object  = new();

    forever begin
        // Sample inputs
        @(pass_inputs)
        transaction_object.data_in     = if_monitor.data_in;
        transaction_object.rst_n       = if_monitor.rst_n;
        transaction_object.wr_en       = if_monitor.wr_en;
        transaction_object.rd_en       = if_monitor.rd_en;

        // Sample ouputs
        @(negedge if_monitor.clk)
        transaction_object.data_out    = if_monitor.data_out;
        transaction_object.wr_ack      = if_monitor.wr_ack;
        transaction_object.overflow    = if_monitor.overflow;
        transaction_object.full        = if_monitor.full;
        transaction_object.empty       = if_monitor.empty;
        transaction_object.almostfull  = if_monitor.almostfull;
        transaction_object.almostempty = if_monitor.almostempty;
        transaction_object.underflow   = if_monitor.underflow;

        // turn on coverage and scoreboard
        fork 
            coverage_object.sample_data(transaction_object);
            scoreboard_object.check_data(transaction_object);
        join
      
        // Display corrct count and Error count
        if(test_finished)
          begin
            $display("Time:%0t, Finally, Correct count = %0d,   Error count = %0d",$time,correct_count,error_count);
            $finish;
          end
        
    end
end
endmodule


