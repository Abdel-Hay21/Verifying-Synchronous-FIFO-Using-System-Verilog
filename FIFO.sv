////////////////////////////////////////////////////////////////////////////////
// Author: Kareem Waseem
// Course: Digital Verification using SV & UVM
//
// Description: FIFO Design 
// 
////////////////////////////////////////////////////////////////////////////////
module FIFO(IF.DUT Design);

parameter FIFO_WIDTH = 16;
parameter FIFO_DEPTH = 8;
 
localparam max_fifo_addr = $clog2(FIFO_DEPTH);

reg [FIFO_WIDTH-1:0] mem [FIFO_DEPTH-1:0];

reg [max_fifo_addr-1:0] wr_ptr, rd_ptr;
reg [max_fifo_addr:0] count;

always @(posedge Design.clk or negedge Design.rst_n) begin
	if (!Design.rst_n) begin  
		wr_ptr <= 0;
    //for clean code: In case reset, I should reset wr_ack & overflow also
    Design.wr_ack <= 0;
    Design.overflow <= 0;
	end
	else if (Design.wr_en && count < FIFO_DEPTH) begin
		mem[wr_ptr] <= Design.data_in;
		Design.wr_ack <= 1;
		wr_ptr <= wr_ptr + 1;
	end
	else begin 
		Design.wr_ack <= 0; 
		if (Design.full && Design.wr_en) // to get coverage 100% you should use (&&) not (&)
			Design.overflow <= 1;
		else
			Design.overflow <= 0;
	end
end

always @(posedge Design.clk or negedge Design.rst_n) begin
	if (!Design.rst_n) begin 
		rd_ptr <= 0;
    // for clean code: In case reset, I should reset data_out & underflow also
    Design.data_out <= 0;
    Design.underflow <= 0;
	end
	else if (Design.rd_en && count != 0) begin
		Design.data_out <= mem[rd_ptr];
		rd_ptr <= rd_ptr + 1;
    Design.underflow <= 0;
	end
  else begin
    if (Design.empty && Design.rd_en)  // Bug: from specs underflow must be sequential not compinational
			Design.underflow <= 1;
		else
			Design.underflow <= 0;
  end
end

always @(posedge Design.clk or negedge Design.rst_n) begin
	if (!Design.rst_n) begin
		count <= 0;
	end
	else begin 
    // Bug: this (if_statement) don't cover corner case -> write and read in same time
		if	( (({Design.wr_en, Design.rd_en} == 2'b10) && !Design.full ) || (({Design.wr_en, Design.rd_en} == 2'b11) && Design.empty )) 
			count <= count + 1;
		else if ( (({Design.wr_en, Design.rd_en} == 2'b01) && !Design.empty ) || (({Design.wr_en, Design.rd_en} == 2'b11) && Design.full ))
			count <= count - 1;
	end
end

assign Design.full = (count == FIFO_DEPTH)? 1 : 0;
assign Design.empty = (count == 0)? 1 : 0;
assign Design.almostfull = (count == FIFO_DEPTH-1)? 1 : 0;  // BUG: FIFO_DEPTH-1 not FIFO_DEPTH-2
assign Design.almostempty = (count == 1)? 1 : 0;




`ifdef SIM

////////////////////////////////////////////////// ************************ concurrent Assertion ****************    ////////////////////////////////////////////////////

//\\*//\\*//\\    write_enable(high) && Not full && read_enable(high) && Not empty  ------>   rd_ptr(+1) && wr_ptr(+1) && count(constant)    //\\*//\\*//\\
property No_Change_count_property;
@(posedge Design.clk) disable iff(!Design.rst_n)
(Design.wr_en && Design.rd_en && !Design.full && !Design.empty)
|=> $stable(count) && 
    ((rd_ptr == $past(rd_ptr) + 1) || (($past(rd_ptr) == FIFO_DEPTH-1) && rd_ptr == 0)) && 
    ((wr_ptr == $past(wr_ptr) + 1) || (($past(wr_ptr) == FIFO_DEPTH-1) && wr_ptr == 0))
endproperty



//\\*//\\*//\\   write_enable(high) && Not full && read_enable(low)  ------>   wr_ptr(+1) && count(+1)    //\\*//\\*//\\
property yes_write_no_read_property;
@(posedge Design.clk) disable iff(!Design.rst_n)
(Design.wr_en && !Design.rd_en && !Design.full)
|=> $stable(rd_ptr) &&
    (count == $past(count) + 1) &&
    ((wr_ptr == $past(wr_ptr) + 1) || (($past(wr_ptr) == FIFO_DEPTH-1) && wr_ptr == 0))
endproperty



//\\*//\\*//\\    read_enable(high) && Not empty && write_enable(low)  ------>   rd_ptr(+1) && count(-1)    //\\*//\\*//\\
property yes_read_no_write_property;
@(posedge Design.clk) disable iff(!Design.rst_n)
(!Design.wr_en && Design.rd_en && !Design.empty)
|=> $stable(wr_ptr) &&
    (count == $past(count) - 1) &&
    ((rd_ptr == $past(rd_ptr) + 1) || (($past(rd_ptr) == FIFO_DEPTH-1) && rd_ptr == 0))
endproperty



//\\*//\\*//\\    write_enable(high) && full  ------>   wr_ptr(constant)    //\\*//\\*//\\
property yes_write_but_full_property;
@(posedge Design.clk) disable iff(!Design.rst_n)
(Design.wr_en && Design.full)
|=> $stable(wr_ptr)
endproperty



//\\*//\\*//\\    read_enable(high) && empty  ------>   rd_ptr(constant)    //\\*//\\*//\\
property yes_read_but_empty_property;
@(posedge Design.clk) disable iff(!Design.rst_n)
(Design.rd_en && Design.empty)
|=> $stable(rd_ptr)
endproperty


No_Change_count:    assert property(No_Change_count_property);
yes_write_no_read:  assert property(yes_write_no_read_property);
yes_read_no_write:  assert property(yes_read_no_write_property);
yes_write_but_full: assert property(yes_write_but_full_property);
yes_read_but_empty: assert property(yes_read_but_empty_property);




////////////////////////////////////////////////// ************************ Combinational Assertion ****************    ////////////////////////////////////////////////////
//\\*//\\*//\\    reset asserted  ------>   reset all outputs    //\\*//\\*//\\
always_comb begin 
    if(Design.rst_n == 0) 
    begin
      Reset_Behavior_property_counter:     assert final(count == 0);
      Reset_Behavior_property_wr_ptr:      assert final(wr_ptr == 0);
      Reset_Behavior_property_rd_ptr:      assert final(rd_ptr == 0);
      Reset_Behavior_property_full:        assert final(Design.full == 0);
      Reset_Behavior_property_empty:       assert final(Design.empty == 1);
      Reset_Behavior_property_almostfull:  assert final(Design.almostfull == 0);
      Reset_Behavior_property_almostempty: assert final(Design.almostempty == 0);
      Reset_Behavior_property_underflow:   assert final(Design.underflow == 0);
      Reset_Behavior_property_overflow:    assert final(Design.overflow == 0);
    end
end

//\\*//\\*//\\    full flag work correct            //\\*//\\*//\\
always_comb begin 
    if(count == FIFO_DEPTH) 
    Full_Flag_Assertion: assert final(Design.full);
end 

//\\*//\\*//\\    empty flag work correct           //\\*//\\*//\\
always_comb begin 
    if(count == 0) 
    Empty_Flag_Assertion: assert final(Design.empty);
end 

//\\*//\\*//\\    almostfull flag work correct      //\\*//\\*//\\
always_comb begin 
    if(count == FIFO_DEPTH - 1) 
    Almost_Full_Condition: assert final(Design.almostfull);
end 

//\\*//\\*//\\    almostempty flag work correct     //\\*//\\*//\\
always_comb begin 
    if(count == 1) 
    Almost_empty_Condition: assert final(Design.almostempty);
end 





////////////////////////////////////////////////// ************************ Sequential Assertion ****************    ////////////////////////////////////////////////////


  //\\*//\\*//\\    wr_ack flag work correct         //\\*//\\*//\\
  property Write_Acknowledge_property;
   @(posedge Design.clk) disable iff(!Design.rst_n)
   (Design.wr_en && !Design.full) 
   |=> (Design.wr_ack)
  endproperty

  //\\*//\\*//\\    overflow flag work correct       //\\*//\\*//\\
  property Overflow_Detection_property;
   @(posedge Design.clk) disable iff(!Design.rst_n)
   (Design.wr_en && Design.full)
   |=> (Design.overflow)
  endproperty

  //\\*//\\*//\\    underflow flag work correct      //\\*//\\*//\\
  property Underflow_Detection_property;
   @(posedge Design.clk) disable iff(!Design.rst_n)
   (Design.rd_en && Design.empty)
   |=> (Design.underflow)
  endproperty

  //\\*//\\*//\\    write pointer wraparound         //\\*//\\*//\\
  property Pointer_Wraparound_property_write;
   @(posedge Design.clk)
   (wr_ptr == FIFO_DEPTH - 1 && Design.wr_en && !Design.full)
   |=> (wr_ptr == 0)
  endproperty

  //\\*//\\*//\\    read pointer wraparound          //\\*//\\*//\\
  property Pointer_Wraparound_property_read;
   @(posedge Design.clk)
   (rd_ptr == FIFO_DEPTH - 1 && Design.rd_en && !Design.empty)
   |=> (rd_ptr == 0)
  endproperty

  //\\*//\\*//\\    counter not exceed FIFO_Depth    //\\*//\\*//\\
  property Pointer_Wraparound_property_counter_reset;
   @(posedge Design.clk)
   (count == FIFO_DEPTH) ##2 (!Design.rst_n)
   |-> (count == 0)
  endproperty

  //\\*//\\*//\\    counter && write_pointer && read_pointer not exceed avaliable range     //\\*//\\*//\\
  property Pointer_threshold_property;
   @(posedge Design.clk)
   (count < FIFO_DEPTH + 1) && (rd_ptr < FIFO_DEPTH) && (wr_ptr < FIFO_DEPTH)
  endproperty


  Write_Acknowledge:          assert property(Write_Acknowledge_property);
  Overflow_Detection:         assert property(Overflow_Detection_property);
  Underflow_Detection:        assert property(Underflow_Detection_property);
  Pointer_Wraparound_write:   assert property(Pointer_Wraparound_property_write);
  Pointer_Wraparound_read:    assert property(Pointer_Wraparound_property_read);
  Pointer_Wraparound_counter: assert property(Pointer_Wraparound_property_counter_reset);
  Pointer_threshold:          assert property(Pointer_threshold_property);

`endif
endmodule