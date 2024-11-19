//
// This is the template for Part 2 of Lab 7.
//
// Paul Chow
// November 2021
//

module part2(iResetn,iPlotBox,iColour,iLoadX,iBlack, iXY_Coord,iClock,oX,oY,oColour,oPlot);
   parameter X_SCREEN_PIXELS = 8'd160;
   parameter Y_SCREEN_PIXELS = 7'd120;
   
   input wire iResetn, iPlotBox, iLoadX, iBlack;
   input wire [2:0] iColour;
   input wire [6:0] iXY_Coord;
   input wire 	    iClock;
   output wire [7:0] oX;         // VGA pixel coordinates
   output wire [6:0] oY;
   
   output wire [2:0] oColour;     // VGA pixel colour (0-7)
   output wire 	     oPlot;       // Pixel draw enable

	wire x_init_enable;
	wire y_enable;
	wire colour_enable;
	wire counter_enable;
	wire reset;
	wire [4:0] count;
	wire [13:0] b;
	
	control c1(.clk(iClock) , .resetn(iResetn), .iLoadX(iLoadX), .iBlack(iBlack), .iPlotBox(iPlotBox), .q(count), .b(b), .x_enable(x_init_enable), 
			.y_enable(y_enable),.colour_enable(colour_enable), .counter_enable(counter_enable),
			.reset_enable(reset), .oPlot(oPlot));
	
	datapath d1(.clk(iClock), .resetn(iResetn), .loadX(x_init_enable), .loadY(y_enable), .loadColour(colour_enable),
			.enable(counter_enable),.make_black(reset), .dataIn(iXY_Coord), .colourIn(iColour), .Qout(count), .Xout(oX), .Yout(oY), 
			.ColourOut(oColour), .black(b));

endmodule // part2

module control(clk, resetn, iLoadX, iBlack, iPlotBox, q, b, x_enable, y_enable, colour_enable, counter_enable, reset_enable, oPlot);

	input clk, resetn, iLoadX, iPlotBox, iBlack;
	input [4:0] q;
	input [13:0] b;
	output reg x_enable, y_enable, colour_enable, counter_enable, reset_enable, oPlot;

	reg [3:0] current_state, next_state;

	localparam	S_load_x = 		3'd0,
			S_load_x_wait =		3'd1,
			S_load_y_colour = 	3'd2,
			S_load_y_colour_wait = 	3'd3,
			S_draw = 		3'd4,
			S_reset = 		3'd5,
			S_clear_wait = 		3'd5,
			S_clear = 		3'd6;

	always@(*)
	begin //state_table
		case(current_state)
		S_reset: 
			begin 
			if(iLoadX == 1)
				next_state = S_load_x_wait;
			else if(iBlack == 1)
				next_state = S_clear_wait;
			else
				next_state = S_reset;
			end

		S_load_x_wait: next_state = (iLoadX == 0)? S_load_x : S_load_x_wait;
		S_load_x: next_state = S_load_y_colour;
		S_load_y_colour: next_state = (iPlotBox == 1)? S_load_y_colour_wait : S_load_y_colour;
		S_load_y_colour_wait: next_state = (iPlotBox == 0)? S_draw : S_load_y_colour_wait;
		S_draw: next_state = (q == 5'b10000) ? S_reset : S_draw;
		S_clear_wait: next_state = (iBlack == 0)? S_clear: S_clear_wait;
		S_clear: next_state = (b == 13'b111011110100000)? S_reset:S_clear;
		endcase
	end

	always@(*)
	begin //enable_signals
		x_enable = 0;
		y_enable = 0;
		colour_enable = 0;
		counter_enable = 0;
		oPlot = 0;
		reset_enable = 0;
		case(current_state)
			S_load_x: begin
				x_enable = 1;
				end
			S_load_y_colour_wait: begin
				y_enable = 1;
				colour_enable = 1;
				end
			S_draw: begin
				counter_enable = 1;
				oPlot = 1;
				end
			S_clear: begin
				reset_enable = 1;
				end
		endcase
	end

	//flip flop logic
	always@(posedge clk)
	begin //state_FFs
		if(resetn == 0)
		current_state <= S_load_x;
		else 
		current_state <= next_state;
	end

endmodule

module datapath(clk, resetn, loadX, loadY, loadColour, enable, make_black, dataIn, colourIn, Qout, Xout, Yout, ColourOut, black);

	input clk, resetn;
	input loadX, loadY, loadColour, enable, make_black;
	input [6:0] dataIn;
	input [2:0] colourIn;
	
	output reg [4:0] Qout;
	output reg [7:0] Xout;
	output reg [6:0] Yout;
	output reg [2:0] ColourOut;
	output reg [13:0] black;

	reg [7:0] x, y; //address registers
	
	always@(posedge clk) //loading value into registers
	begin
		if(resetn == 0) begin
			x <= 0;
			y <= 0;
		end
		else begin
		if(loadX)
			x <= dataIn; //store data in register
		if(loadY)
			y <= dataIn; //store data in register
		if(loadColour)
			ColourOut <= colourIn;
		if(make_black)
			ColourOut <= 3'b000;
		end
	end

	always@(posedge clk) //counter
	begin
		if(resetn == 0)
		Qout <= 0;
		else if(enable == 1) begin
		Xout <= x + Qout[1:0];
		Yout <= y + Qout[3:2];
		Qout <= Qout + 1;
		end
		else if(make_black) begin
		Xout <= black[6:0];
		Yout <= black[13:7];
		black <= black + 1;
		end
		else if(Qout <= 5'b01111)
		Qout <= 0;
	end 


endmodule	    