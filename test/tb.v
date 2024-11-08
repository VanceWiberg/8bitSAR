`timescale 1ns/1ns
`include "project.v"

module template_tb();

reg [7:0] ui_in;
wire [7:0] uo_out;
reg [7:0] uio_in;
wire [7:0] uio_out;
wire [7:0] uio_oe;
reg ena;
reg clk;
reg rst_n;

tt_um_VanceWiberg_top dut(.*);

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

//handle simulation
initial begin
  $dumpfile("sar8_tb.vcd");  
  $dumpvars(0, template_tb);
end	
	
endmodule
