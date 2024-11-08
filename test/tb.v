/*
`default_nettype none
`timescale 1ns / 1ps

module tb ();
  // Dump the signals to a VCD file. You can view it with gtkwave.
  initial begin
    $dumpfile("tb.vcd");
    $dumpvars(0, tb);
    #1;
  end
  // Wire up the inputs and outputs:
  reg clk;
  reg rst_n;
  reg ena;
  reg [7:0] ui_in;
  reg [7:0] uio_in;
  wire [7:0] uo_out;
  wire [7:0] uio_out;
  wire [7:0] uio_oe;
`ifdef GL_TEST
  wire VPWR = 1'b1;
  wire VGND = 1'b0;
`endif
  // Replace tt_um_example with your module name:
  tt_um_VanceWiberg_top project (
      // Include power ports for the Gate Level test:
`ifdef GL_TEST
      .VPWR(VPWR),
      .VGND(VGND),
`endif
      .ui_in  (ui_in),    // Dedicated inputs
      .uo_out (uo_out),   // Dedicated outputs
      .uio_in (uio_in),   // IOs: Input path
      .uio_out(uio_out),  // IOs: Output path
      .uio_oe (uio_oe),   // IOs: Enable path (active high: 0=input, 1=output)
      .ena    (ena),      // enable - goes high when design is selected
      .clk    (clk),      // clock
      .rst_n  (rst_n)     // not reset
  );
endmodule
	  
initial begin 
  ui_in = 8'b00000010;
  uio_in = 8'b0;
  clk = 1'b0;
  rst_n = 1'b1;
  ena = 1'b1;
	while(1) begin
  	#1 clk = ~clk;
	end
end

initial begin
	rst_n = 1'b0;
	repeat(2) @(posedge clk);
	rst_n = 1'b1;
	repeat(100) @(posedge clk);
	$finish(1);
end

reg [2:0] counter = 3'b111;
reg [7:0] compare = 8'b10000000;
reg overlap = 1'b1;
reg incorrect = 1'b0;

always @(posedge clk) begin
if (uio_out[0]) begin
	//$display("");
	//$display(uo_out, " THIS IS THE SAR         ", compare, " THIS IS THE TEST");
	if (uo_out == compare) begin
		//$display("Success");
	end
	else begin
		$display("***INCORRECT***");
		incorrect = 1'b1;
	end
	rst_n = 1'b0;
	counter = 3'b111;
	compare = 8'b10000000;
	overlap = 1'b1;
end
else begin
	
	incorrect = 1'b0;
	rst_n = 1'b1;
	ui_in [0] = $random;

	if((ui_in[0] == 1'b1) && (counter != 3'b0)) begin
		compare[counter - 1] = 1'b1;
	end
	else if (overlap == 1'b1) begin
		if (ui_in[0]) begin
		compare[counter] = 1'b1; end
		else begin
		compare[counter] = 1'b0; end
		if (counter != 3'b0) begin
			compare[counter - 1] = 1'b1;
		end
	end
	
	if(counter != 3'b0) begin
		counter = counter - 3'b001;
	end
	else begin
		overlap = 1'b0;
	end	
end
end

  );
endmodule
*/

`timescale 1ns/1ns

module tb();

//handle simulation
initial begin
  $dumpfile("tb.vcd");  
  $dumpvars(0, tb);
end	
	
reg [7:0] ui_in;
wire [7:0] uo_out;
reg [7:0] uio_in;
wire [7:0] uio_out;
wire [7:0] uio_oe;
reg ena;
reg clk;
reg rst_n;
	
`ifdef GL_TEST
  wire VPWR = 1'b1;
  wire VGND = 1'b0;
`endif
  // Replace tt_um_example with your module name:
  tt_um_VanceWiberg_top project (
      // Include power ports for the Gate Level test:
`ifdef GL_TEST
      .VPWR(VPWR),
      .VGND(VGND),
`endif
      .ui_in  (ui_in),    // Dedicated inputs
      .uo_out (uo_out),   // Dedicated outputs
      .uio_in (uio_in),   // IOs: Input path
      .uio_out(uio_out),  // IOs: Output path
      .uio_oe (uio_oe),   // IOs: Enable path (active high: 0=input, 1=output)
      .ena    (ena),      // enable - goes high when design is selected
      .clk    (clk),      // clock
      .rst_n  (rst_n)     // not reset
  );
endmodule	  
/*	
//tt_um_VanceWiberg_top dut(.*);

initial begin 
  ui_in = 8'b00000010;
  uio_in = 8'b0;
  clk = 1'b0;
  rst_n = 1'b1;
  ena = 1'b1;
	while(1) begin
  	#1 clk = ~clk;
	end
end

initial begin
	rst_n = 1'b0;
	repeat(2) @(posedge clk);
	rst_n = 1'b1;
	repeat(100) @(posedge clk);
	$finish(1);
end

reg [2:0] counter = 3'b111;
reg [7:0] compare = 8'b10000000;
reg overlap = 1'b1;
reg incorrect = 1'b0;

always @(posedge clk) begin
if (uio_out[0]) begin
	//$display("");
	//$display(uo_out, " THIS IS THE SAR         ", compare, " THIS IS THE TEST");
	if (uo_out == compare) begin
		//$display("Success");
	end
	else begin
		$display("***INCORRECT***");
		incorrect = 1'b1;
	end
	rst_n = 1'b0;
	counter = 3'b111;
	compare = 8'b10000000;
	overlap = 1'b1;
end
else begin
	
	incorrect = 1'b0;
	rst_n = 1'b1;
	ui_in [0] = $random;

	if((ui_in[0] == 1'b1) && (counter != 3'b0)) begin
		compare[counter - 1] = 1'b1;
	end
	else if (overlap == 1'b1) begin
		if (ui_in[0]) begin
		compare[counter] = 1'b1; end
		else begin
		compare[counter] = 1'b0; end
		if (counter != 3'b0) begin
			compare[counter - 1] = 1'b1;
		end
	end
	
	if(counter != 3'b0) begin
		counter = counter - 3'b001;
	end
	else begin
		overlap = 1'b0;
	end	
end
end


	
endmodule

