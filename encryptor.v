// Top level module for encryption function
module encryptor_top(SW, KEY, LEDR, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, HEX6);
    input [7:0] SW; //work on utilizing the keyboard later 
    input [3:0] KEY; //key 
    input CLOCK_50; //clock for potential future use
    output [9:0] LEDR;
    output [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, HEX6;

    //we will be implementing a caesar cipher
    //user will be able to enter shift amount through keys [6:7] (0, 1 or 2)
    //user can specify the letter they want to enter by entering the right binary input
    //write the first letter on the switches, then press a key, and enter next letter until done
    //ex. 


endmodule

module encryptor(
	input [7:0] data_input //[6:7] is shift value (0, 1 or 2), [0:5] is the word we want to shift 
	input clk,
	input resetn,
	input go,
	output [7:0] data_result,
	);
	
	control C0()
	datapath D0()

endmodule

module control(
    input clk,
    input resetn,
    input go,

    output reg blahblahblah,
    );

	reg [3:0] current_state, next_state;

	localparam  LETTER1_LOAD_1        = 8'd0,
				LETTER2_LOAD_2        = 8'd0,
				LETTER3_LOAD_3        = 8'd0,
				LETTER4_LOAD_4        = 8'd0,
				LETTER5_LOAD_5        = 8'd0,
				LETTER6_LOAD_6        = 8'd0,
				LETTER1_SHIFTED       = 8'd0,
				LETTER2_SHIFTED       = 8'd0,
				LETTER3_SHIFTED       = 8'd0,
				LETTER4_SHIFTED       = 8'd0,
				LETTER5_SHIFTED       = 8'd0,
				LETTER6_SHIFTED       = 8'd0,
    );

    // Next state logic aka our state table
    always@(*)
    begin: state_table 
            case (current_state)
				LETTER1_LOAD_1: load in letter 1
				LETTER2_LOAD_2 : ..
				LETTER3_LOAD_3 : ..
				LETTER4_LOAD_4 : ..
				LETTER5_LOAD_5 : ..
				LETTER6_LOAD_6 : ..
				LETTER1_SHIFTED : ..
				LETTER2_SHIFTED : ..
				LETTER3_SHIFTED : ..
				LETTER4_SHIFTED : ..
				LETTER5_SHIFTED : ..
				LETTER6_SHIFTED : ..

            default:     
        endcase
    end // state_table

   // Output logic aka all of our datapath control signals
    always @(*)
    begin: enable_signals
        //blah
        case (current_state)
            //blah
            end
        endcase
    end // enable_signals
   
    // current_state registers
    always@(posedge clk)
    begin: state_FFs
        if(!resetn)
            current_state <= LETTER1_LOAD_1;
        else
            current_state <= next_state;
    end 
endmodule

module datapath(
    input clk,
    input resetn,
    input [7:0] data_in,
    //blah
endmodule

module hex_decoder(hex_digit, segments);
    input [3:0] hex_digit;
    output reg [6:0] segments;
   
    always @(*)
        case (hex_digit)
            4'h0: segments = 7'b100_0000;
            4'h1: segments = 7'b111_1001;
            4'h2: segments = 7'b010_0100;
            4'h3: segments = 7'b011_0000;
            4'h4: segments = 7'b001_1001;
            4'h5: segments = 7'b001_0010;
            4'h6: segments = 7'b000_0010;
            4'h7: segments = 7'b111_1000;
            4'h8: segments = 7'b000_0000;
            4'h9: segments = 7'b001_1000;
            4'hA: segments = 7'b000_1000;
            4'hB: segments = 7'b000_0011;
            4'hC: segments = 7'b100_0110;
            4'hD: segments = 7'b010_0001;
            4'hE: segments = 7'b000_0110;
            4'hF: segments = 7'b000_1110;   
            default: segments = 7'h7f;
        endcase
endmodule
