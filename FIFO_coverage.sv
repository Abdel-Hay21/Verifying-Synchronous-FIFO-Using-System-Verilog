// -----------------------------------------------------------------------------------
// class: FIFO_coverage
// function: Define Functional Coverage &
//           Trigger the sampling of the covergroup by calling function (sample_data) 
// -----------------------------------------------------------------------------------

package FIFO_coverage_pkg;

  //import transaction pakage
  import FIFO_transaction_pkg::*;
  

  class FIFO_coverage;

    //create an object (holds sampled values)
    FIFO_transaction F_cvg_txn;

    // define coverage group
    // Cross coverage between wr_en, rd_en and each output control signal
    covergroup g1;
        // Inputs
        Wr_Enable:      coverpoint F_cvg_txn.wr_en;
        Rd_Enable:      coverpoint F_cvg_txn.rd_en;
        
        // Outputs
        Write_ACK:      coverpoint F_cvg_txn.wr_ack;
        Over_Flow:      coverpoint F_cvg_txn.overflow;
        Full_Flag:      coverpoint F_cvg_txn.full;
        Empty_Flag:     coverpoint F_cvg_txn.empty;
        Almost_Full:    coverpoint F_cvg_txn.almostfull;
        Almost_Empty:   coverpoint F_cvg_txn.almostempty;
        Under_Flow:     coverpoint F_cvg_txn.underflow;

        Cross_With_Write_ACK:     cross Wr_Enable, Rd_Enable, Write_ACK{
          ignore_bins case_not_happen_in_write_ACK_Flag = binsof(Wr_Enable) intersect {0} && binsof(Write_ACK) intersect {1};
        }
        Cross_With_Over_Flow:     cross Wr_Enable, Rd_Enable, Over_Flow{
          ignore_bins case_not_happen_in_write_ACK_Flag = binsof(Wr_Enable) intersect {0} && binsof(Over_Flow) intersect {1};
        }
        Cross_With_Full_Flag:     cross Wr_Enable, Rd_Enable, Full_Flag{
          ignore_bins case_not_happen_in_Full_Flag = binsof(Rd_Enable) intersect {1} && binsof(Full_Flag) intersect {1};
        }
        Cross_With_Under_Flow:    cross Wr_Enable, Rd_Enable, Under_Flow{
          ignore_bins case_not_happen_in_Under_Flow= binsof(Rd_Enable) intersect {0} && binsof(Under_Flow) intersect {1};
        }
        Cross_With_Empty_Flag:    cross Wr_Enable, Rd_Enable, Empty_Flag;
        Cross_With_Almost_Full:   cross Wr_Enable, Rd_Enable, Almost_Full;
        Cross_With_Almost_Empty:  cross Wr_Enable, Rd_Enable, Almost_Empty;
        
    endgroup


    // constructor function
    function new;
      F_cvg_txn = new(); // create a transaction object
      g1 = new();        // create a covergroup instance
    endfunction

    // save sampled transation from outter object to local object
    // trigger a sampling
    function void sample_data(FIFO_transaction F_txn);
      F_cvg_txn.data_in     = F_txn.data_in;
      F_cvg_txn.rst_n       = F_txn.rst_n;
      F_cvg_txn.wr_en       = F_txn.wr_en;
      F_cvg_txn.rd_en       = F_txn.rd_en;
      F_cvg_txn.data_out    = F_txn.data_out;
      F_cvg_txn.wr_ack      = F_txn.wr_ack;
      F_cvg_txn.overflow    = F_txn.overflow;
      F_cvg_txn.full        = F_txn.full;
      F_cvg_txn.empty       = F_txn.empty;
      F_cvg_txn.almostfull  = F_txn.almostfull;
      F_cvg_txn.almostempty = F_txn.almostempty;
      F_cvg_txn.underflow   = F_txn.underflow;

      g1.sample();

    endfunction
 endclass

endpackage
