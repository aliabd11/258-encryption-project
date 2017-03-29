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

	wire [24:0] data_out;

	/**
	*		Characters start at 'a' (0 dec, 5'b0001) and end at 'z'(26 dec, 5'b11010)
	**/
	reg [24:0] char_array;

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
			char_array <= 25'b0000000000000000000000000; 
		end

		// Load character into string.
		if (KEY[2] == 1'b0)
		begin
			char_array[24:0] <= {char_array, SW[4:0]}; // Concatenate the new character to the START of the char array. 
		end
	end



endmodule

module control_caesar(clock, resetn, go, sig_done, sig_load_char, sig_concat_str, sig_load_str);
		input clock;
		input resetn;
		input go;
		input sig_done;

		reg [5:0] current_state, next_state;

		reg first_iteration; 
		
		output reg sig_load_char; 
		output reg sig_concat_str; 
		output reg sig_load_str; 

		localparam  WAIT_INPUT	= 5'd0,
					LOAD_STR	= 5'd1,
					LOAD_CHAR	= 5'd2,
					CONCAT_STR 	= 5'd3;

		always @(posedge clock)
		begin: state_table 
			case(current_state)

				// Wait until a go signal.
				WAIT_INPUT: begin
					next_state <= (~go) ? LOAD_STR : WAIT_INPUT;
					first_iteration <= 1'b0; 
					sig_concat_str <= 1'b0; 
				end 

				// Once the input has been determined, load the string into the register of the datapath.
				LOAD_STR: begin 
					sig_load_str <= 1'b1; 
					next_state <= LOAD_CHAR;
				end 

				// Load a single character from the string into the cipher machine.
				LOAD_CHAR: begin 
					sig_load_str <= 1'b0; 
					sig_concat_str <= 1'b0;

					// We don't need to shift anything if this is the first iteration. (First character is located
					// at [4:0]).
					if (first_iteration == 1'b1)
					begin
						sig_load_char <= 1'b1; 
					end 
					
					first_iteration <= 1'b1; 
					next_state <= CONCAT_STR;
				end

				// Concatenate the output of the encode/decoded character to the overall output of the cipher.
				CONCAT_STR: begin 
					
					// Turn off signals.
					sig_load_char <= 1'b0;

					// Turn on concat str signal. 
					sig_concat_str <= 1'b1;
					
					// Check if we've received a signal from the datapath telling us that there are no more 
					// characters.
					if (sig_done == 1'b0)
					begin 
						next_state <= LOAD_CHAR; 
					end 
					
					// If that is the case, then we re done.
					if (sig_done == 1'b1)
					begin
						next_state <= WAIT_INPUT;
					end 		
				end 
			endcase
		end

	// current_state registers
    always@(posedge clock)
    begin: state_FFs
        if(!resetn)
            current_state <= WAIT_INPUT;
        else
            current_state <= next_state;
    end // state_FFS

endmodule

module datapath_caesar(clock, resetn, char_array, cipher_shift, decode, sig_load_char, sig_load_str, sig_concat_str, char_array_out, sig_done);
	input clock;
	input resetn;
	input [24:0] char_array; 
	input [4:0] cipher_shift; 
	input decode;
	input sig_concat_str; // Signal from Control.
	input sig_load_char; // Signal from Control.
	input sig_load_str; // Signal from control.

	// Output from caesar cipher.
	wire [4:0] encode_out;
	wire [4:0] decode_out; 

	// An array for each character of 5 bits.
	reg [4:0] char1;
	reg [4:0] char2;
	reg [4:0] char3;
	reg [4:0] char4;
	reg [4:0] char5;

	reg [1:0] current_char_index; // which character we are currently working on.
 	
 	// An array of characters, the string, is what will be outputed upon completion of the cipher machine.
	output reg [24:0] char_array_out;
	
	// Goes high if the cipher mine is done (no more characters left to work on)
	output reg sig_done; 
	
	// Register storing the string from data_in.
	reg [24:0] reg_char; 
	
	// Instantiate a caesar cipher for encoding.
	encode_caesar_cipher ecc (
			.clk(clock), 
			.enable(1'b1), 
			.data_in(char_array), 
			.cipher_shift(cipher_shift), 
			.encode_out(encode_out));
	
	// Begin datapath cases.
	always @(posedge clock)
	begin

	// CASE 1: RESET.
	if (resetn == 1'b0)
		begin
			char_array_out <= 25'b0000000000000000000000000;
			sig_done <= 1'b0;
			current_char_index <= 2'b00;
			char1 <= 5'b00000;
			char2 <= 5'b00000;
			char3 <= 5'b00000;
			char4 <= 5'b00000;
			char5 <= 5'b00000;
			char_array_out <= {char1, char2, char3, char5, char5}; 
		end
	
	// CASE 2: LOAD STRING. In this step, the string from data_in is loaded into the registers.	
	if (sig_load_str == 1'b1)
	begin
		reg_char <= char_array;
	end 
	
	// CASE 3: LOAD_STR. This will pop a character off of the string and send it to the cipher.
	if (sig_load_char == 1'b1)
		begin
			reg_char <= reg_char >> 5; 
			// If what we popped is the 0 bits, then we are done.
			if (reg_char[4:0] == 5'b00000)
			begin
				sig_done <= 1'b1; 
			end 
		end 

	// CASE 4 CONCAT_STR. This will set the output from the cipher for each character in the
	// appropriate position in the final character array.	
	if (sig_concat_str == 1'b1)
	begin
		// If we are decoding.
		if (decode == 1'b0)
		begin
			// Set the current character's register to the output of decode.
			case (current_char_index)
				2'b00: char1 <= decode_out;
				2'b01: char2 <= decode_out;
				2'b10: char3 <= decode_out;
				2'b11: char4 <= decode_out; 
			endcase
		end 
		
		// Otherwise, encoding.
		if (decode == 1'b1)
		begin
			// Set the current character's register to the input of the encode.
			case (current_char_index)
				2'b00: char1 = encode_out;
				2'b01: char2 = encode_out;
				2'b10: char3 = encode_out;
				2'b11: char4 = encode_out; 
			endcase 
		end 
		// Increment the current character counter.
		current_char_index <= current_char_index + 1'b1;
	end 
	
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

	wire sig_done;
	wire sig_load_char;
	wire sig_concat_str;
	wire sig_load_str;

	output [24:0] data_out;  
	
	wire [24:0] data_o;
	
	assign data_out = data_o;
	
	
	control_caesar cc(
		.clock(clk), 
		.resetn(resetn), 
		.go(go), 
		.sig_done(sig_done), 
		.sig_load_char(sig_load_char), 
		.sig_concat_str(sig_concat_str),
		.sig_load_str(sig_load_str));


	datapath_caesar dc(
		.clock(clk), 
		.resetn(resetn), 
		.char_array(data_in), 
		.cipher_shift(cipher_shift), 
		.decode(decode),
		.sig_load_char(sig_load_char),
		.sig_concat_str(sig_concat_str),
		.sig_load_str(sig_load_str),
		.char_array_out(data_o), 
		.sig_done(sig_done));

	// Set output of cipher based on their decode and cipher method.
   /** always @(*)
	begin
		// 3-bit number denoted as dcc - if d is 0, we decode, if d is 1, we encode. cc represents the cipher type.
		case ({decode, cipher_method})
			3'b000: data_out = data_in; // Case: 000 - print directly to out.
			3'b001: data_out = data_out; // Case: 001 - Caesar Cipher by method of decoding.
			3'b010: data_out = 4'b0010; // Case: 010 - Vigenère Cipher method of decoding.
			3'b011: data_out = 4'b011; // Case: 011 - Free Mux Slot.
			3'b100: data_out = data_in; // Case: 100 - print directly to out.
			3'b101: data_out = encode_caesar_out; // Case: 101 - Caesar cipher by method of encoding.
			3'b110: data_out = 4'b0110; // Case: 110 - Vigenère Cipher by method of encoding.
			default: data_out = 4'b1111; // If this happens, something went wrong. Display F.
		endcase
	end**/

endmodule

/** Given a 4-bit data input that has been encoded by a caesar cipher, this will decode the data, returning a decrypted letter. **/
module decode_caesar_cipher(clk, data_in, cipher_shift, decrypt_out);

	input clk;
	input [4:0] data_in;
	input [4:0] cipher_shift;

	output reg [4:0] decrypt_out;

	reg [4:0] offset;


	// To decode the data with the key, we subtract the key from the data in.
	// Check if we need to loop around (that is, if the key will cause us to return to the start of the alphabet)
	always @(posedge clk)
	begin
		if ((data_in - cipher_shift) > 5'b11010)
		begin
			decrypt_out <= data_in - cipher_shift;
		end

		// If we do need to loop around
		if ((data_in - cipher_shift) <= 5'b11010)
		begin
			// Compute the offset by subtracting from the key how far we are away from the z character.
			offset <= cipher_shift - (5'b11010 - data_in);

			// Our encrypted character will be the character at position corresponding to the char 'a' - offset.
			decrypt_out <= 5'b00001 - offset;
		end
	end

endmodule

/** Given a 4-bit data input, this will encode the data using caesar cipher algorithm. **/
module encode_caesar_cipher(clk, enable, data_in, cipher_shift, encode_out);

	input clk;
	input enable;
	input [24:0] data_in;
	input [4:0] cipher_shift;

	reg [4:0] offset;

	output reg [4:0] encode_out;

	// To encode the data with the key, we add the key to the data in.
	// Check if we need to loop around (that is, if the key will cause us to return to the start of the alphabet)
	always @(posedge clk)
	begin

			// If we do not need to loop around, proceed as normal by adding the key to the data_in to get an encoded letter.
			if ((data_in[4:0] + cipher_shift) <= 5'b11010)
			begin
				encode_out <= data_in + cipher_shift;
			end

			// If we do need to loop around
			if ((data_in[4:0] + cipher_shift) > 5'b11010)
			begin
				// Compute the offset by subtracting from the key how far we are away from the z character.
				offset <= cipher_shift - (5'b11010 - data_in[4:0]);

				// Our encrypted character will be the character at position corresponding to the char 'a' + offset.
				encode_out <= 5'b00001 + offset;

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

