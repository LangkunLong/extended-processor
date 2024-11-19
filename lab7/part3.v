//
// This is the template for Part 3 of Lab 7.
//
// Paul Chow
// November 2021
//

// iColour is the colour for the box
//
// oX, oY, oColour and oPlot should be wired to the appropriate ports on the VGA controller
//

// Some constants are set as parameters to accommodate the different implementations
// X_SCREENSIZE, Y_SCREENSIZE are the dimensions of the screen
//       Default is 160 x 120, which is size for fake_fpga and baseline for the DE1_SoC vga controller
// CLOCKS_PER_SECOND should be the frequency of the clock being used.

module part3(iColour,iResetn,iClock,oX,oY,oColour,oPlot);
   input wire [2:0] iColour;
   input wire 	    iResetn;
   input wire 	    iClock;
   output wire [7:0] oX;         // VGA pixel coordinates
   output wire [6:0] oY;
   
   output wire [2:0] oColour;     // VGA pixel colour (0-7)
   output wire 	     oPlot;       // Pixel drawn enable

	wire [14:0] count;
	wire [4:0] drawCount;
	wire colour_select;
	wire x_y_counter_enable;
	wire hor_sel;
	wire ver_sel;
	wire go;

   parameter
     X_SCREENSIZE = 160,  // X screen width for starting resolution and fake_fpga
     Y_SCREENSIZE = 120,  // Y screen height for starting resolution and fake_fpga
     CLOCKS_PER_SECOND = 5000, // 5 KHZ for fake_fpga
     X_BOXSIZE = 8'd4,   // Box X dimension
     Y_BOXSIZE = 7'd4,   // Box Y dimension
     X_MAX = X_SCREENSIZE - 1 - X_BOXSIZE, // 0-based and account for box width
     Y_MAX = Y_SCREENSIZE - 1 - Y_BOXSIZE,
     PULSES_PER_SIXTIETH_SECOND = CLOCKS_PER_SECOND / 60
	       ;

	//wire [7:0] xsize = X_MAX;
	//wire [6:0] ysize = Y_MAX;
	//wire [5:0] pulse = PULSES_PER_SIXTIETH_SECOND;

	control #(.X_MAX(X_MAX), .Y_MAX(Y_MAX), .CLOCKS_PER_SECOND(CLOCKS_PER_SECOND)) c1(.clk(iClock), .reset(iResetn),.drawCount(drawCount), .count(count), .colour_select(colour_select), .x_y_counter_enable(x_y_counter_enable),
			.hor_sel(hor_sel), .ver_sel(ver_sel), .go(go), .oplot(oPlot));

	datapath d1(.clk(iClock), .reset(iResetn), .colourIn(iColour), .colsel(colour_select), .update(x_y_counter_enable), 
			.selectHor(hor_sel), .selectVer(ver_sel), .draw4(go), .Xout(oX), .Yout(oY), .Qout(count), .colourOut(oColour), .count(drawCount));


endmodule // part3

module control(clk, reset, drawCount, count, colour_select, x_y_counter_enable, hor_sel, ver_sel, go, oplot);
	input clk, reset;
	
	input [4:0] drawCount;
	input [14:0] count;
	output reg colour_select, x_y_counter_enable, hor_sel, ver_sel, go, oplot;

	reg[3:0] current_state, next_state;
	reg delay_counter;
	reg[6:0] q;

	parameter X_MAX;
	parameter Y_MAX;
	parameter CLOCKS_PER_SECOND;
	assign delay_enable = (q ==0)?1:0;

	localparam	S_reset = 		3'd0,
			S_draw = 		3'd1,
			S_wait = 		3'd2,
			S_wait_load = 		3'd3,
			S_erase = 		3'd4,
			S_update = 		3'd5;
	
	always@(*)
	begin //state logic
		case(current_state)
		S_reset: next_state = S_draw;
		S_draw: next_state = (drawCount == 5'b10000)? S_wait: S_draw; //continue drawing until 4x4 box is drawn 
		S_wait: next_state = S_wait_load;
		S_wait_load: next_state = (delay_enable)? S_erase: S_wait_load;
		S_erase: next_state = (drawCount == 5'b10000)? S_update: S_erase;
		S_update: next_state = S_draw;
		endcase
	end

	always@(*)
	begin //enable signals
		colour_select = 0;
		x_y_counter_enable = 0;
		delay_counter = 0;
		hor_sel = 0; //initially going to the right
		ver_sel = 0; //initiailly going down 
		go = 0;
		oplot = 0;
		case(current_state)
			S_draw:	begin
				colour_select = 0;
				go = 1;
				oplot = 1;
				end
			S_wait: begin
				delay_counter = 1; //activates the countdown 
				end
			S_erase: begin
				 colour_select = 1;
				 go = 1;
				 oplot = 1;
				 end
			S_update: begin
				x_y_counter_enable = 1;
				begin
				if(count[14:8] == Y_MAX)
					ver_sel = 1;
				else if(count[7:0] == X_MAX)
					hor_sel = 1;
				else if(count[14:8] == 0 && count[7:0] != 0)
					ver_sel = ~ver_sel;
				else if(count[14:8] != 0 && count[7:0] == 0)
					hor_sel = ~hor_sel;
				end
				end
		endcase
	end

	//flip flop logic
	always@(posedge clk)
	begin //state_FFs
		if(reset == 0)
		current_state <= S_reset;
		else 
		current_state <= next_state;
	end

	//delay_counter
	always@(posedge clk)
	begin
		if(reset == 0)
		q <= 0;
		else if(delay_counter)
		q <= CLOCKS_PER_SECOND *60;
		else 
		q <= q - 1;
	end 


endmodule
					

module datapath(clk, reset, colourIn, colsel, update, selectHor, selectVer, draw4, Xout, Yout, Qout, colourOut, count); //draw4 is go
	input clk, reset;
	input [2:0] colourIn;
	input colsel, update, selectHor, selectVer, draw4;

	output reg [14:0] Qout;
	output reg [4:0] count;
	output reg [7:0] Xout;
	output reg [6:0] Yout;
	output reg [2:0] colourOut;

	reg hor_direction, ver_direction;

	always@(posedge clk) //loading value into registers
	begin
		if(reset == 0) begin
			Qout[7:0] <= 0;
			Qout[14:8] <= 0;
		end
		else begin
		if(update) 
			begin
			Qout[7:0] <= Qout[7:0] + hor_direction; //looping through x direction
			Qout[14:8] <= Qout[14:8] + ver_direction; //store data in register
			end
		if(!colsel)
			colourOut <= colourIn;
		if(colsel)
			colourOut <= 3'b000; //draw black
		end
	end
		

	always@(posedge clk) //counter to draw 4x4 box
	begin
		if(reset == 0)
		count <= 0;
		else if(count == 5'b10000) //draw 4x4 box
		count <= 0;
		else if(draw4) begin
		Xout <= Qout[7:0] + count[1:0];
		Yout <= Qout[14:8] + count[3:2];
		count <= count + 1;
		end
	end

	always@(*)
	begin 
		case(selectHor)
		0: hor_direction = 1;
		1: hor_direction = -1;
		endcase
		
		case(selectVer)
		0: ver_direction = 1;
		1: ver_direction = -1;
		endcase
	end

endmodule

