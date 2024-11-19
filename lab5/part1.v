module part1(Clock, Enable, Clear_b, CounterValue);
	input Clock, Enable, Clear_b;
	output[7:0] CounterValue;
	
	t_flip_flop t0(.clock(Clock),.resetn(Clear_b),.T(Enable),.Q(CounterValue[0]));
	t_flip_flop t1(.clock(Clock),.resetn(Clear_b),.T((CounterValue[0] && Enable)),.Q(CounterValue[1]));
	t_flip_flop t2(.clock(Clock),.resetn(Clear_b),.T((CounterValue[1] && CounterValue[0] && Enable)),.Q(CounterValue[2]));
	t_flip_flop t3(.clock(Clock),.resetn(Clear_b),.T((CounterValue[2] && CounterValue[1] && CounterValue[0] && Enable)),.Q(CounterValue[3]));
	t_flip_flop t4(.clock(Clock),.resetn(Clear_b),.T((CounterValue[3] && CounterValue[2] && CounterValue[1] && CounterValue[0] && Enable)),.Q(CounterValue[4]));
	t_flip_flop t5(.clock(Clock),.resetn(Clear_b),.T((CounterValue[4] && CounterValue[3] && CounterValue[2] && CounterValue[1] && CounterValue[0] && Enable)),.Q(CounterValue[5]));
	t_flip_flop t6(.clock(Clock),.resetn(Clear_b),.T((CounterValue[5] && CounterValue[4] && CounterValue[3] && CounterValue[2] && CounterValue[1] && CounterValue[0] && Enable)),.Q(CounterValue[6]));
	t_flip_flop t7(.clock(Clock),.resetn(Clear_b),.T((CounterValue[6] && CounterValue[5] && CounterValue[4] && CounterValue[3] && CounterValue[2] && CounterValue[1] && CounterValue[0] && Enable)),.Q(CounterValue[7]));
	
	
endmodule
		
		
module t_flip_flop(clock, resetn, T, Q);
	input clock, resetn, T;
	output reg Q;
	always @(posedge clock, negedge resetn)
		begin
		
		if(resetn == 0)
		Q <= 0;
		
		else if(T)
		Q <= ~Q;
		
		else
		Q <= Q;
		
		end
		
endmodule