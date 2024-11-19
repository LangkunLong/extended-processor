module part2(ClockIn, Reset, Speed, CounterValue);
	input ClockIn, Reset;
	input [1:0]Speed;
	output reg [3:0] CounterValue;
	wire enableDC;

	RateDivider R1(.clk(ClockIn),.resetn(Reset),.x(Speed),.enable(enableDC));

	always@(posedge ClockIn)
	begin 
	
	if(Reset == 1)
	CounterValue <= 0;
	else if(enableDC == 1)
	CounterValue <= CounterValue +1;
	else if(CounterValue == 4'b1111)
	CounterValue <= 0;
	
	end

endmodule


module RateDivider(clk, resetn, x, enable);
	input clk, resetn;
	input [1:0]x;
	reg[11:0] q;
	output enable;
	
	always@(posedge clk)
	begin
	if(resetn == 1)
	q <= 0;
	else if(q == 0)
	begin 
		case(x)
		2'b00: q <= 0; //sets enable to be 0 and can produce an output right away
		2'b01: q <= 499;
		2'b10: q <= 999;
		2'b11: q <= 1999;
		default: q <= 0;
		endcase
	end
	else
	q <= q-1;
	
	end

	assign enable = (q==0)?1:0;

endmodule
