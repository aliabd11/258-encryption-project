/****************************************************************************
 *			CIPHER MACHINE - A final project for CSC258	(Computer Org.)		*
 *																			*
 *				By Abdullah Ali and Mohamed Hammoud							*
 *							Winter 2017										*
 *																			*
 ****************************************************************************/

// Top level module for cipher machine.
module cipher_top(SW, KEY, CLOCK_50, LEDR, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, HEX6);
	/**
	 * SW[9] -> Verify -> If on, verify.
	 * SW[8] -> Encode/Decode swich -> on for decode, off for encode.
	 * SW[7:6] -> cipher method: 00 (just display), 01 (caesar cipher), 10 (vigenère cipher), 11
	 * SW[4:0] -> data_in
	 *
	 * KEY[3]
	 * KEY[2] -> Load char
	 * KEY[1] -> Run Cipher (go)
	 * KEY[0] -> Reset
	**/

	input [9:0] SW;
	input [3:0] KEY;
	input CLOCK_50;

	output [9:0] LEDR;
	output [6:0] HEX0;
	output [6:0] HEX1;
	output [6:0] HEX2;
	output [6:0] HEX3;
	output [6:0] HEX4;
	output [6:0] HEX5;
	output [6:0] HEX6;
	
	// Output wire.
	wire [24:0] data_out;
	
	// Array for each character (each character is 5 bits). A character starts at 'a', (5'b00001) and ends at 'z' (5'b11010). 
	reg [4:0] char1;
	reg [4:0] char2;
	reg [4:0] char3;
	reg [4:0] char4;
	reg [4:0] char5;
	
	// A completed string array, with each character taking up 5 bits.
	wire [24:0] char_array;
	
	// The k'th position of the character we are waiting for input on.
	reg [2:0] current_char_index; 
	
	// Set the string array to each character provided in the input.
	assign char_array[24:20] = char1;
	assign char_array[19:15] = char2;
	assign char_array[14:10] = char3;
	assign char_array[9:5] = char4;
	assign char_array[4:0] = char5;

    // Instantiate the cipher machine.
	cipher cm(
		.clk(CLOCK_50),
		.resetn(KEY[0]),
		.data_in(char_array),
		.cipher_shift(SW[4:0]),
		.decode(SW[8]),
		.cipher_method(SW[7:6]),
		.go(KEY[1]),
		.verify(KEY[2]),
		.data_out(data_out));

	// Load in character if key2 has been pressed. This is temporary, until we implement the keyboard.
	always @(posedge CLOCK_50)
	begin
		// Reset signal. Clear string registry.
		if (KEY[0] == 1'b0)
		begin
			char1 <= 5'b00000;
			char2 <= 5'b00000;
			char3 <= 5'b00000;
			char4 <= 5'b00000;
			char5 <= 5'b00000;
			current_char_index <= 2'b00;
		end

		// Load character into string.
		if (KEY[2] == 1'b0)
		begin
			case(current_char_index)
				3'b000: char1 <= SW[4:0];
				3'b001: char2 <= SW[4:0];
				3'b010: char3 <= SW[4:0];
				3'b011: char4 <= SW[4:0]; 
				3'b100: char5 <= SW[4:0];
			endcase
			
			// Increment to the next index for the character's input we are waiting for. 
			current_char_index <= current_char_index + 1'b1;
		end
		
		
	end



endmodule

module control_caesar(clock, resetn, go, sig_load_str, sig_do_char1, sig_do_char2, sig_do_char3, sig_do_char4, sig_do_char5);
		
		input clock;
		input resetn;
		input go;
		
		
		// Outputs to the datapath.
		output reg sig_load_str; // If high, load string into character registers.
		output reg sig_do_char1; // If high, cipher this character.
		output reg sig_do_char2; // If high, cipher this character. 
		output reg sig_do_char3; // If high, cipher this character.
		output reg sig_do_char4; // If high, cipher this character.
		output reg sig_do_char5; // If high, cipher this character. 

		reg [5:0] current_state, next_state;


		localparam  WAIT_INPUT	= 5'd0,
					LOAD_STR	= 5'd1,
					LOAD_STR2	= 5'd2,
					LOAD_CHAR1	= 5'd3,
					DO_CHAR1	= 5'd4,
					LOAD_CHAR2	= 5'd5,
					DO_CHAR2	= 5'd6,
					LOAD_CHAR3	= 5'd7,
					DO_CHAR3	= 5'd8,
					LOAD_CHAR4	= 5'd9,
					DO_CHAR4	= 5'd10,
					LOAD_CHAR5	= 5'd11,
					DO_CHAR5	= 5'd12,
					DONE		= 5'd13;
					
		
		// STATE MACHINE
		always @(posedge clock)
		begin: state_table 
			case(current_state)

				// WAIT for Input from User. 
				WAIT_INPUT: begin
					// Need to turn off enable for the 5th character if we've looped back here from the end.
					sig_do_char5 <= 1'b0;
					
					// Wait for the GO signal. 
					next_state <= (~go) ? LOAD_STR : WAIT_INPUT;
				end
				
				// LOAD_STR: Load in string to the register. 
				LOAD_STR: begin 
					sig_load_str <= 1'b1; 
					next_state <= LOAD_CHAR1; 
				end 
				
				// Take the first character from the string and put it in its own character register. 
				LOAD_CHAR1: begin 
					sig_load_str <= 1'b0;
					sig_do_char1 <= 1'b1; 
					next_state <= DO_CHAR1; 
				end 
				
				// Cipher the first character.
				DO_CHAR1: begin				
					next_state <= LOAD_CHAR2;
				end
				
				// Take the second character from the string and put it in its own character register. 
				LOAD_CHAR2: begin  
					sig_do_char1 <= 1'b0; 
					sig_do_char2 <= 1'b1; 
					next_state <= DO_CHAR2; 
				end 
				
				// Cipher the second character. 
				DO_CHAR2: begin
					next_state <= LOAD_CHAR3;
				end
				// See logic above... as it is the same.
				LOAD_CHAR3: begin  
					sig_do_char2 <= 1'b0; 
					sig_do_char3 <= 1'b1; 
					next_state <= DO_CHAR3; 
				end 
				
				DO_CHAR3: begin			
					next_state <= LOAD_CHAR4;
				end
				
				LOAD_CHAR4: begin  
					sig_do_char3 <= 1'b0; 
					sig_do_char4 <= 1'b1; 
					next_state <= DO_CHAR4; 
				end 
				
				DO_CHAR4: begin			
					next_state <= LOAD_CHAR5;
				end
				
				LOAD_CHAR5: begin  
					sig_do_char4 <= 1'b0; 
					sig_do_char5 <= 1'b1; 
					next_state <= DO_CHAR5; 
				end 
				
				// After ciphering the last character, return to waiting for input. 
				DO_CHAR5: begin			
					next_state <= DONE;
				end
				
				DONE: begin
					sig_do_char5 = 1'b0; 
					next_state <= DONE;
				end 
				
					
			endcase 
		end 


	// current_state registers
    always@(posedge clock)
    begin: state_FFs
        if(!resetn)
		begin
            current_state <= WAIT_INPUT;
		end 
        else
            current_state <= next_state;
    end // state_FFS

endmodule

module datapath_caesar(clock, resetn, char_array, cipher_shift, decode, sig_load_str, sig_do_char1, sig_do_char2, sig_do_char3, sig_do_char4, sig_do_char5, char_array_out);
	input clock;
	input resetn;
	input [24:0] char_array; 
	input [4:0] cipher_shift;
	input decode;

	// Signals from control. When high, we are working on this character. 
	input sig_do_char1;
	input sig_do_char2; 
	input sig_do_char3; 
	input sig_do_char4; 
	input sig_do_char5; 
	input sig_load_str; 

	// Output from caesar cipher.
	wire [4:0] encode_out;
	wire [4:0] decode_out; 

	// An array for each character of 5 bits.
	reg [4:0] char1;
	reg [4:0] char2;
	reg [4:0] char3;
	reg [4:0] char4;
	reg [4:0] char5;
	
	// The current character we are ciphering.
	reg [4:0] curr_char;
	reg [1:0] current_char_index; 
 	
 	// An array of characters, the string, is what will be outputed upon completion of the cipher machine.
	output [24:0] char_array_out;


	// Outputs from the cipher machines.
	reg [4:0] char1_out;
	reg [4:0] char2_out;
	reg [4:0] char3_out;
	reg [4:0] char4_out;
	reg [4:0] char5_out;
	
	// Build the output string. 
	assign char_array_out[24:20] = char1_out; 
	assign char_array_out[19:15] = char2_out; 
	assign char_array_out[14:10] = char3_out; 
	assign char_array_out[9:5] = char4_out; 
	assign char_array_out[4:0] = char5_out; 
	
	
	// Instantiate a caesar cipher for encoding.
	encode_caesar_cipher ecc (
			.clk(clock), 
			.data_in(curr_char), 
			.cipher_shift(cipher_shift), 
			.encode_out(encode_out));
			
	// Instantiate a caesar cipher for encoding.
	decode_caesar_cipher dcc (
			.clk(clock), 
			.data_in(curr_char), 
			.cipher_shift(cipher_shift), 
			.decode_out(decode_out));
	
	// Begin datapath cases.
	always @(posedge clock)
	begin

	// CASE 1: RESET.
	if (resetn == 1'b0)
		begin
			current_char_index <= 2'b00;
			curr_char <= 5'b00000; 
			char1 <= 5'b00000;
			char2 <= 5'b00000;
			char3 <= 5'b00000;
			char4 <= 5'b00000;
			char5 <= 5'b00000;
			char1_out <= 5'b00000;
			char2_out <= 5'b00000;
			char3_out <= 5'b00000;
			char4_out <= 5'b00000;
			char5_out <= 5'b00000; 
		end
	
	// CASE 2: LOAD STRING. In this step, the string from data_in is loaded into the register for EACH character.	
	if (sig_load_str == 1'b1)
		begin
			char1 <= char_array[24:20];
			char2 <= char_array[19:15];
			char3 <= char_array[14:10];
			char4 <= char_array[9:5];
			char5 <= char_array[4:0];
		end 
	
	// CASE 3 (char 1): Load and process the first character. 
	if (sig_do_char1 == 1'b1)
		begin
			// Load character
			curr_char <= char1; 
			
			// Only process if this character is between [a-z],
			if (curr_char > 5'b00000)
				begin 
					if (decode == 1'b0)
						begin 
							char1_out <= decode_out; 
						end
						
					if (decode == 1'b1)
						begin 
							char1_out <= encode_out; 
						end
				end 	
		end //end case char1.
	
	// CASE 3 (char 2): Load and process the second character.
	if (sig_do_char2 == 1'b1)
		begin
			// Load character.
			curr_char <= char2; 
			
			// Only process if this character is between [a-z],
			if (curr_char > 5'b00000)
				begin 
					if (decode == 1'b0)
						begin 
							char2_out <= decode_out; 
						end
						
					if (decode == 1'b1)
						begin 
							char2_out <= encode_out; 
						end
				end 	
		end //end case char2.
		
	// CASE 3 (char 3): Load and process the third character. 
	if (sig_do_char3 == 1'b1)
		begin
			// Load character
			curr_char <= char3; 
			
			// Only process if this character is between [a-z],
			if (curr_char > 5'b00000)
				begin 
					if (decode == 1'b0)
						begin 
							char3_out <= decode_out; 
						end
						
					if (decode == 1'b1)
						begin 
							char3_out <= encode_out; 
						end
				end 	
		end //end case char3.
		
	// CASE 3 (char 4): Load and process the fourth character. 
	if (sig_do_char4 == 1'b1)
		begin
			// Load character.
			curr_char <= char4; 
			
			// Only process if this character is between [a-z],
			if (curr_char > 5'b00000)
				begin 
					if (decode == 1'b0)
						begin 
							char4_out <= decode_out; 
						end
						
					if (decode == 1'b1)
						begin 
							char4_out <= encode_out; 
						end
				end 	
		end //end case char4.
			
	// CASE 3 (char 5): Load and process the fifth character.   
	if (sig_do_char5 == 1'b1)
		begin
			// Load character. 
			curr_char <= char5; 
			
			// Only process if this character is between [a-z],
			if (curr_char > 5'b00000)
				begin 
					if (decode == 1'b0)
						begin 
							char5_out <= decode_out; 
						end
						
					if (decode == 1'b1)
						begin 
							char5_out <= encode_out; 
						end
				end 	
		end //end case char5.
	end 
	

endmodule

module cipher(clk, resetn, data_in, cipher_shift, decode, cipher_method, go, verify, data_out);

	input clk;
	input resetn;
	input [24:0] data_in;
	input [4:0] cipher_shift; 
	input decode; // 0 for decode, 1 for encode.
	input [1:0] cipher_method;
	input go;
	input verify;
	
	output reg [24:0] data_out; 
	
	wire [24:0] cipher_shift_vg; 
	
	// Creates a vigenere key by repeating the caesar cipher key 5 times. 
	
	assign cipher_shift_vg = {5{cipher_shift}};

	// Wires from the caesar control to caesar datapath. 
	wire sig_load_str_cr;
	wire sig_do_char1_cr;
	wire sig_do_char2_cr;
	wire sig_do_char3_cr;
	wire sig_do_char4_cr;
	wire sig_do_char5_cr;

	wire [24:0] data_caesar;
	
	wire [24:0] data_vigenere; 
	
	
	// INSTANTIATE CONTROL PATH for CAESAR CIPHER.
	control_caesar cc(
		.clock(clk), 
		.resetn(resetn), 
		.go(go), 
		.sig_load_str(sig_load_str_cr), 
		.sig_do_char1(sig_do_char1_cr), 
		.sig_do_char2(sig_do_char2_cr), 
		.sig_do_char3(sig_do_char3_cr), 
		.sig_do_char4(sig_do_char4_cr), 
		.sig_do_char5(sig_do_char5_cr));
	
	// INSTANTIATE DATA PATH for CAESAR CIPHER.
	datapath_caesar dpcc(
		.clock(clk), 
		.resetn(resetn), 
		.char_array(data_in), 
		.cipher_shift(cipher_shift), 
		.decode(decode), 
		.sig_load_str(sig_load_str_cr), 
		.sig_do_char1(sig_do_char1_cr), 
		.sig_do_char2(sig_do_char2_cr), 
		.sig_do_char3(sig_do_char3_cr), 
		.sig_do_char4(sig_do_char4_cr), 
		.sig_do_char5(sig_do_char5_cr), 
		.char_array_out(data_caesar));
		
	// INSTANTIATE CONTROL PATH for VIGENERE CIPHER.
		// todo
	
	// INSTANTIATE DATA PATH for VIGENERE CIPHER.
		// todo 

	// Set output. 
    always @(*)
	begin
		// Output machine based on if they are doing a caesar cipher or vigenere cipher, or simply printing. 
		case (cipher_method)
			2'b00: data_out <= data_in; 
			2'b01: data_out <= data_caesar; 
			2'b10: data_out <= data_vigenere; 
			2'b11: data_out <= data_in; 
		endcase
	end

endmodule

/** Given a 4-bit data input that has been encoded by a caesar cipher, this will decode the data, returning a decrypted letter. **/
module decode_caesar_cipher(clk, data_in, cipher_shift, decode_out);

	input clk;
	input [4:0] data_in;
	input [4:0] cipher_shift;

	output reg [4:0] decode_out;

	reg [4:0] offset;


	// To decode the data with the key, we subtract the key from the data in.
	// Check if we need to loop around (that is, if the key will cause us to return to the start of the alphabet)
	always @(posedge clk)
	begin
		if ((data_in - cipher_shift) > 5'b11010)
		begin
			decode_out <= data_in - cipher_shift;
		end

		// If we do need to loop around
		if ((data_in - cipher_shift) <= 5'b11010)
		begin
			// Compute the offset by subtracting from the key how far we are away from the z character.
			offset <= cipher_shift - (5'b11010 - data_in);

			// Our encrypted character will be the character at position corresponding to the char 'a' - offset.
			decode_out <= 5'b00000 - offset;
		end
	end

endmodule

/** Given a 4-bit data input, this will encode the data using caesar cipher algorithm. **/
module encode_caesar_cipher(clk, data_in, cipher_shift, encode_out);

	input clk;
	input [4:0] data_in;
	input [4:0] cipher_shift;

	reg [4:0] offset;

	output reg [4:0] encode_out;

	// To encode the data with the key, we add the key to the data in.
	// Check if we need to loop around (that is, if the key will cause us to return to the start of the alphabet)
	always @(posedge clk)
	begin

			// If we do not need to loop around, proceed as normal by adding the key to the data_in to get an encoded letter.
			if ((data_in + cipher_shift) <= 5'b11010)
			begin
				encode_out <= data_in + cipher_shift;
			end

			// If we do need to loop around
			if ((data_in + cipher_shift) > 5'b11010)
			begin
				// Compute the offset by subtracting from the key how far we are away from the z character.
				offset <= cipher_shift - (5'b11010 - data_in);

				// Our encrypted character will be the character at position corresponding to the char 'a' + offset.
				encode_out <= 5'b00000 + offset;

			end

	end

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

