module part3(ClockIn, Resetn, Start, Letter, DotDashOut);
	input ClockIn, Resetn, Start;
	input [2:0] Letter;
	reg[11:0] shift;
	reg [7:0] Q;
	reg [3:0] C = 13;
	assign enable = (Q ==0)?1:0;
	assign count = (C ==0)?0:1;
	output reg DotDashOut;
	
	always@(posedge ClockIn, negedge Resetn)
	begin

	if(Resetn == 0)
	begin
	DotDashOut <= 0;
	shift <= 0;
	Q <= 0;
	end
	else if(Start == 1) //load the letter
	begin
		case(Letter)
		3'b000: shift <= 12'b000000011101;
		3'b001: shift <= 12'b000101010111;
		3'b010: shift <= 12'b010111010111;
		3'b011: shift <= 12'b000001010111;
		3'b100: shift <= 12'b000000000001;
		3'b101: shift <= 12'b000101110101;
		3'b110: shift <= 12'b000101110111;
		3'b111: shift <= 12'b000001010101;
		endcase
	end
	else if(count == 0 && Resetn == 1 && Start == 0) //repeat the cycle
	begin
		case(Letter)
		3'b000: shift <= 12'b000000011101;
		3'b001: shift <= 12'b000101010111;
		3'b010: shift <= 12'b010111010111;
		3'b011: shift <= 12'b000001010111;
		3'b100: shift <= 12'b000000000001;
		3'b101: shift <= 12'b000101110101;
		3'b110: shift <= 12'b000101110111;
		3'b111: shift <= 12'b000001010101;
		endcase
		C <= 13;
	end
	else if(enable == 1) //enables once every 250 clock cycles
	begin
		shift[10] <= shift[11];
		shift[9] <= shift[10];
		shift[8] <= shift[9];
		shift[7] <= shift[8];
		shift[6] <= shift[7];
		shift[5] <= shift[6];
		shift[4] <= shift[5];
		shift[3] <= shift[4];
		shift[2] <= shift[3];
		shift[1] <= shift[2];
		shift[0] <= shift[1];
		DotDashOut <= shift[0];
		Q <= 249;
		C <= C -1;
	end
	else 
	Q <= Q - 1;
	end
	
endmodule 

