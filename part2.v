module mux2to1 (x,y,s,m);

	input x, y, s;
	output m;
	wire s1, a1, a2;
	
	v7404 inv( .pin1(s), .pin2(s1));
	v7408 and1( .pin1(s1), .pin2(x), .pin3(a1));
	v7408 and2( .pin1(s), .pin2(y), .pin3(a2));
	v7432 OR(.pin1(a1), .pin2(a2), .pin3(m));
	
endmodule 

module v7404 (pin1, pin3, pin5, pin9, pin11, pin13, pin2, pin4, pin6, pin8, pin10, pin12);
				
	input pin1, pin3, pin5, pin13, pin11, pin9;
	output pin2, pin4, pin6, pin12, pin10, pin8;
	
	assign pin2 = ~pin1;
	assign pin4 = ~pin3;
	assign pin6 = ~pin5;
	assign pin12 = ~pin13;
	assign pin10 = ~pin11;
	assign pin8 = ~pin9;
	
endmodule
	
	
module v7408 (pin1, pin3, pin5, pin9, pin11, pin13, pin2, pin4, pin6, pin8, pin10, pin12);
	
	input pin1, pin2, pin4, pin5, pin13, pin12, pin10, pin9;
	output pin3, pin6, pin11, pin8;
	
	assign pin3 = pin1 & pin2;
	assign pin6 = pin4 & pin5;
	assign pin11 = pin13 & pin12;
	assign pin8 = pin10 & pin9;

endmodule
	
	
module v7432 (pin1, pin3, pin5, pin9, pin11, pin13, pin2, pin4, pin6, pin8, pin10, pin12);

	input pin1, pin2, pin4, pin5, pin13, pin12, pin10, pin9;
	output pin3, pin6, pin11, pin8;
	
	assign pin3 = pin1 || pin2;
	assign pin6 = pin4 || pin5;
	assign pin11 = pin13 || pin12;
	assign pin8 = pin10 || pin9;
	
endmodule
