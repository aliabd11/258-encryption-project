/****************************************************************************
 *			CIPHER MACHINE - A final project for CSC258	(Computer Org.)		*
 *																			*
 *				By Abdullah Ali and Mohamed Hammoud							*
 *							Winter 2017										*
 *																			*
 ****************************************************************************/

// Top level module for cipher machine.
module cipher_top(SW, KEY, CLOCK_50, LEDR, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, HEX6,
		VGA_CLK,   						//	VGA Clock
		VGA_HS,							//	VGA H_SYNC
		VGA_VS,							//	VGA V_SYNC
		VGA_BLANK_N,						//	VGA BLANK
		VGA_SYNC_N,						//	VGA SYNC
		VGA_R,   						//	VGA Red[9:0]
		VGA_G,	 						//	VGA Green[9:0]
		VGA_B );  						//	VGA Blue[9:0]);
	/**
	 * SW[9] -> Verify -> If on, verify.
	 * SW[8] -> Encode/Decode swich -> on for decode, off for encode.
	 * SW[7:6] -> cipher method: 00 (just display), 01 (caesar cipher), 10 (vigenère cipher), 11
	 * SW[4:0] -> data_in
	 *
	 * KEY[3] -> Load Key
	 * KEY[2] -> Load char
	 * KEY[1] -> Run Cipher (go)
	 * KEY[0] -> Reset
	**/

	input [9:0] SW;
	input [3:0] KEY;
	input CLOCK_50;

	// Outputs for HEX.

	output [9:0] LEDR;
	output [6:0] HEX0;
	output [6:0] HEX1;
	output [6:0] HEX2;
	output [6:0] HEX3;
	output [6:0] HEX4;
	output [6:0] HEX5;
	output [6:0] HEX6;

	// Declare your inputs and outputs here
	// Do not change the following outputs
	output			VGA_CLK;   				//	VGA Clock
	output			VGA_HS;					//	VGA H_SYNC
	output			VGA_VS;					//	VGA V_SYNC
	output			VGA_BLANK_N;				//	VGA BLANK
	output			VGA_SYNC_N;				//	VGA SYNC
	output	[9:0]	VGA_R;   				//	VGA Red[9:0]
	output	[9:0]	VGA_G;	 				//	VGA Green[9:0]
	output	[9:0]	VGA_B;   				//	VGA Blue[9:0]

	reg background_image;

	 VGA_verification_output vga
	(
		.CLOCK_50(CLOCK_50),						//	On Board 50 MHz
		// Your inputs and outputs here
        .KEY(KEY),
        .SW(SW),
        .background_image(background_image),
		// The ports below are for the VGA output.  Do not change.
		.VGA_CLK(VGA_CLK),   						//	VGA Clock
		.VGA_HS(VGA_HS),							//	VGA H_SYNC
		.VGA_VS(VGA_VS),							//	VGA V_SYNC
		.VGA_BLANK_N(VGA_BLANK_N),						//	VGA BLANK
		.VGA_SYNC_N(VGA_SYNC_N),						//	VGA SYNC
		.VGA_R(VGA_R),   						//	VGA Red[9:0]
		.VGA_G(VGA_G),	 						//	VGA Green[9:0]
		.VGA_B(VGA_B)   						//	VGA Blue[9:0]
	);

	// Output wire.
	wire [24:0] data_out;
	wire verify_out;


	// Array for each character (each character is 5 bits). A character starts at 'a', (5'b00001) and ends at 'z' (5'b11010).
	reg [4:0] char1;
	reg [4:0] char2;
	reg [4:0] char3;
	reg [4:0] char4;
	reg [4:0] char5;

	reg [4:0] cipher_shift_1;
	reg [4:0] cipher_shift_2;
	reg [4:0] cipher_shift_3;
	reg [4:0] cipher_shift_4;
	reg [4:0] cipher_shift_5;


	// A completed string array, with each character taking up 5 bits.
	wire [24:0] char_array;
	wire [24:0] cipher_shift;

	// The k'th position of the character we are waiting for input on.
	reg [2:0] current_char_index;
	reg [2:0] current_cipher_shift_index;

	// Set the string array to each character provided in the input.
	assign char_array[24:20] = char1;
	assign char_array[19:15] = char2;
	assign char_array[14:10] = char3;
	assign char_array[9:5] = char4;
	assign char_array[4:0] = char5;

	assign cipher_shift[24:20] = cipher_shift_1;
	assign cipher_shift[19:15] = cipher_shift_2;
	assign cipher_shift[14:10] = cipher_shift_3;
	assign cipher_shift[9:5] = cipher_shift_4;
	assign cipher_shift[4:0] = cipher_shift_5;

    // Instantiate the cipher machine.
	cipher cm(
		.clk(CLOCK_50),
		.resetn(KEY[0]),
		.data_in(char_array),
		.cipher_shift(cipher_shift),
		.decode(SW[8]),
		.cipher_method(SW[7:6]),
		.go(KEY[1]),
		.verify_in(KEY[2]),
		.data_out(data_out),
		.verify_out(verify_out));

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

		if (KEY[3] == 1'b0)
		begin
			case (current_cipher_shift_index)
				3'b000: cipher_shift_1 <= SW[4:0];
				3'b001: cipher_shift_2 <= SW[4:0];
				3'b010: cipher_shift_3 <= SW[4:0];
				3'b011: cipher_shift_4 <= SW[4:0];
				3'b100: cipher_shift_5 <= SW[4:0];
			endcase

			// Increment to the next index for the character's input we are waiting for.
			current_char_index <= current_char_index + 1'b1;
			current_cipher_shift_index <= current_cipher_shift_index + 1'b1;
		end

		// Load verify data in. Check against data_out.
			// todo

	end

	// If verify is high, display an image.
	always @(posedge clock)
	begin
		if (verify == 1'b1)
			begin
				// success
				if (verify_out == 1'b0)
					background_image <= "success.colour.mif";
					// audio...
				// failure.
				if (verify_out == 1'b1)
					background_image <= "failure.colour.mif";
					// audio...
			end

		// Blank screen if veirfy is off.
		if (verify == 1'b0)
			background_image <= "black.mif";
	end

endmodule

module control_caesar(clock, resetn, go, sig_load_chars, sig_cipher, sig_set_out, curr_char_index);

		input clock;
		input resetn;
		input go;

		// Outputs to the datapath.
		output reg sig_load_chars;
		output reg sig_cipher;
		output reg sig_set_out;
		output reg [2:0] curr_char_index;

		reg [5:0] current_state, next_state;

		reg found;

		localparam  WAIT_INPUT		= 5'd0,
					CIPHER_CHAR		= 5'd1,
					SET_OUTPUT		= 5'd2,
					LOAD_CHAR		= 5'd3;


		// STATE MACHINE
		always @(posedge clock)
		begin: state_table
			case(current_state)

				// WAIT for Input from User.
				WAIT_INPUT: begin

					// If go signal is sent, load input.
					if (go == 1'b0)
						begin
							// Initialize index.
							curr_char_index <= 3'b000;

							// Send a signal to load all of the characters into the registers in the datapath.
							sig_load_chars <= 1'b1;

							next_state <= CIPHER_CHAR;
						end

					// Otherwise, loop until we receive a go signal.
					else
						next_state <= WAIT_INPUT;
				end


				// Cipher the current character.
				CIPHER_CHAR: begin
					sig_load_chars <= 1'b0;
					sig_cipher <= 1'b1;

					next_state <= SET_OUTPUT;
				end

				// Set output from the cipher.
				SET_OUTPUT: begin
					sig_cipher <= 1'b0;
					sig_set_out <= 1'b1;
					next_state <= LOAD_CHAR;
				end

				// Load the next character.
				LOAD_CHAR: begin

					sig_set_out <= 1'b0;
					found <= 1'b0; // We only want to move the index once per FSM cycle, once we've "found" the appropriate case.

					// If we're currently on the 1st character, move current to 2nd character.
					if ((curr_char_index == 3'b000) && (found == 1'b0))
						begin
							curr_char_index <= 3'b001;
							found <= 1'b1;
							next_state <= CIPHER_CHAR;
						end

					// If we're currently on the 2nd character, move current to 3rd character.
					else if ((curr_char_index == 3'b001) && (found == 1'b0))
						begin
						curr_char_index <= 3'b010;
						found <= 1'b1;
						next_state <= CIPHER_CHAR;
						end

					// If we're currently on the 3rd character, move current to 4th character.
					else if ((curr_char_index == 3'b010) && (found == 1'b0))
						begin
						curr_char_index <= 3'b011;
						found <= 1'b1;
						next_state <= CIPHER_CHAR;
						end

					// If we're currently on the 4th character, move current to 5th character.
					else if ((curr_char_index == 3'b011) && (found == 1'b0))
						begin
						curr_char_index <= 3'b100;
						found <= 1'b1;
						next_state <= CIPHER_CHAR;
						end

					// If we're currently on the 5th character, we're done.
					else if ((curr_char_index == 3'b100) && (found == 1'b0))
						begin
						curr_char_index <= 3'b000;
						found <= 1'b1;
						next_state <= WAIT_INPUT;
						end

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

module datapath_caesar(clock, resetn, char_array, cipher_shift, decode, sig_load_chars, char_array_out, sig_cipher, sig_set_out, curr_char_index);
	input clock;
	input resetn;
	input [24:0] char_array;
	input [4:0] cipher_shift;
	input decode;

	// Inputs from the FSM.
	input sig_load_chars;
	input sig_cipher;
	input sig_set_out;
	input [2:0] curr_char_index;


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

	// CASE 2: Load in each character
	if (sig_load_chars == 1'b1)
		begin
			char1 <= char_array[24:20];
			char2 <= char_array[19:15];
			char3 <= char_array[14:10];
			char4 <= char_array[9:5];
			char5 <= char_array[4:0];
		end

	// CASE 3: Set the cipher for each character.
	if (sig_cipher == 1'b1)
		begin
			// Set input for cipher.
			case (curr_char_index)
				3'b000: curr_char <= char1; // First character
				3'b001: curr_char <= char2; // Second character
				3'b010: curr_char <= char3; // Third character
				3'b011: curr_char <= char4; // Fourth character
				3'b100: curr_char <= char5; // Fifth character.
			endcase


		end

	// CASE 4: Set the output from the cipher.
	if (sig_set_out == 1'b1)
		begin
			// Set output, based on if we are decoding or encoding.
			if (decode == 1'b0)
				begin

					// Set output.
					case (curr_char_index)
						3'b000: char1_out <= decode_out; // First character
						3'b001: char2_out <= decode_out; // Second character
						3'b010: char3_out <= decode_out; // Third character
						3'b011: char4_out <= decode_out; // Fourth character
						3'b100: char5_out <= decode_out; // Fifth character.
					endcase
				end

			// We are decoding instead.
			if (decode == 1'b1)
				begin
					// Set output.
					case (curr_char_index)
						3'b000: char1_out <= encode_out; // First character
						3'b001: char2_out <= encode_out; // Second character
						3'b010: char3_out <= encode_out; // Third character
						3'b011: char4_out <= encode_out; // Fourth character
						3'b100: char5_out <= encode_out; // Fifth character.
					endcase
				end
		end
	end

endmodule

module cipher(clk, resetn, data_in, cipher_shift, decode, cipher_method, go, verify_in, data_out, verify_out);

	input clk;
	input resetn;
	input [24:0] data_in;
	input [24:0] cipher_shift;
	input decode; // 0 for decode, 1 for encode.
	input [1:0] cipher_method;
	input go;
	input verify_in;

	// 0 if success, 1 if failure. verify_out is set from a verification circuit.
	output verify_out;

	output reg [24:0] data_out;

	wire [24:0] cipher_shift_vg;

	// Creates a vigenere key by repeating the caesar cipher key 5 times.

	assign cipher_shift_vg = {5{cipher_shift}};

	wire sig_done;
	wire sig_load_chars;
	wire sig_cipher;
	wire sig_set_out;
	wire [2:0] current_char_index;

	wire [24:0] data_caesar;
	wire [24:0] data_vigenere;

	control_caesar cc(
		.clock(clk),
		.resetn(resetn),
		.go(go),
		.sig_load_chars(sig_load_chars),
		.sig_cipher(sig_cipher),
		.sig_set_out(sig_set_out),
		.curr_char_index(current_char_index));

	datapath_caesar cdp(
		.clock(clk),
		.resetn(resetn),
		.char_array(data_in),
		.cipher_shift(cipher_shift[24:20]),
		.decode(decode),
		.sig_load_chars(sig_load_chars),
		.sig_cipher(sig_cipher),
		.curr_char_index(current_char_index),
		.char_array_out(data_caesar),
		.sig_set_out(sig_set_out));

	datapath_vigenere data_vig(
		.clock(clk),
		.resetn(resetn),
		.char_array(data_in),
		.vigenere_shift(data_vigenere),
		.decode(decode),
		.sig_load_chars(sig_load_chars),
		.sig_cipher(sig_cipher),
		.curr_char_index(current_char_index),
		.char_array_out(data_caesar),
		.sig_set_out(sig_set_out));

	control_vigenere contro_vig(
		.clock(clk),
		.resetn(resetn),
		.go(go),
		.sig_load_chars(sig_load_chars),
		.sig_cipher(sig_cipher),
		.sig_set_out(sig_set_out),
		.curr_char_index(current_char_index));
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

//Need to implement with verification feature
module VGA_verification_output
	(
		CLOCK_50,						//	On Board 50 MHz
		// Your inputs and outputs here
        KEY,
        SW,
        background_image,
		// The ports below are for the VGA output.  Do not change.
		VGA_CLK,   						//	VGA Clock
		VGA_HS,							//	VGA H_SYNC
		VGA_VS,							//	VGA V_SYNC
		VGA_BLANK_N,						//	VGA BLANK
		VGA_SYNC_N,						//	VGA SYNC
		VGA_R,   						//	VGA Red[9:0]
		VGA_G,	 						//	VGA Green[9:0]
		VGA_B   						//	VGA Blue[9:0]
	);

	input			CLOCK_50;				//	50 MHz
	input   [9:0]   SW;
	input   [3:0]   KEY;
	input background_image;

	// Declare your inputs and outputs here
	// Do not change the following outputs
	output			VGA_CLK;   				//	VGA Clock
	output			VGA_HS;					//	VGA H_SYNC
	output			VGA_VS;					//	VGA V_SYNC
	output			VGA_BLANK_N;				//	VGA BLANK
	output			VGA_SYNC_N;				//	VGA SYNC
	output	[9:0]	VGA_R;   				//	VGA Red[9:0]
	output	[9:0]	VGA_G;	 				//	VGA Green[9:0]
	output	[9:0]	VGA_B;   				//	VGA Blue[9:0]

	wire resetn;
	assign resetn = KEY[0];

	// Create the colour, x, y and writeEn wires that are inputs to the controller.
	wire [2:0] colour;
	wire [7:0] x;
	wire [6:0] y;
	wire writeEn;

	// Create an Instance of a VGA controller - there can be only one!
	// Define the number of colours as well as the initial background
	// image file (.MIF) for the controller.
	vga_adapter VGA(
			.resetn(resetn),
			.clock(CLOCK_50),
			.colour(colour),
			.x(x),
			.y(y),
			.plot(writeEn),
			/* Signals for the DAC to drive the monitor. */
			.VGA_R(VGA_R),
			.VGA_G(VGA_G),
			.VGA_B(VGA_B),
			.VGA_HS(VGA_HS),
			.VGA_VS(VGA_VS),
			.VGA_BLANK(VGA_BLANK_N),
			.VGA_SYNC(VGA_SYNC_N),
			.VGA_CLK(VGA_CLK));
		defparam VGA.RESOLUTION = "160x120";
		defparam VGA.MONOCHROME = "FALSE";
		defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
		defparam VGA.BACKGROUND_IMAGE = background_image; //either success.colour.mif or failure.colour.mif

	// Put your code here. Your code should produce signals x,y,colour and writeEn/plot
	// for the VGA controller, in addition to any other functionality your design may require.

    // Instansiate datapath
	// datapath d0(...);

    // Instansiate FSM control
    // control c0(...);

endmodule

module verifier(char_array_in, KEY, CLOCK_50, LEDR, verify);
	/**
	 * KEY[2] -> Load char
	 * KEY[0] -> Reset
	 * char_array_in -> our encrypted char array already stored in
	**/

	input [9:0] SW;
	input [3:0] KEY;
	input CLOCK_50;
	input [24:0] char_array_in;


	output [9:0] LEDR;
	output [1:0] verify;

	wire [24:0] data_out;

	// Array for each character (each character is 5 bits). A character starts at 'a', (5'b00001) and ends at 'z' (5'b11010).
	reg [4:0] char1;
	reg [4:0] char2;
	reg [4:0] char3;
	reg [4:0] char4;
	reg [4:0] char5;

	// The string array the user wants to test
	wire [24:0] char_array;

	reg [2:0] current_char_index;

	assign char_array[24:20] = char1;
	assign char_array[19:15] = char2;
	assign char_array[14:10] = char3;
	assign char_array[9:5] = char4;
	assign char_array[4:0] = char5;

	always @(posedge CLOCK_50)
	begin
		// Reset.
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

	always @(posedge CLOCK_50)
	begin
		if (KEY[3] == 1'b0)
			//If the user's string array matches the encrypted string stored, return a success output
			if (char_array_in == char_array)
				verify <= 1'b0
			else //Else user's string doesn't match, return failure
				verify <= 0'b0
			end
	end

endmodule

module control_vigenere(clock, resetn, go, sig_load_chars, sig_cipher, sig_set_out, curr_char_index);

    input clock;
    input resetn;
    input go;

    // Outputs to the datapath.
    output reg sig_load_chars;
    output reg sig_cipher;
    output reg sig_set_out;
    output reg [2:0] curr_char_index;

    reg [5:0] current_state, next_state;

    reg found;

    localparam  WAIT_INPUT    = 5'd0,
          CIPHER_CHAR   = 5'd1,
          SET_OUTPUT    = 5'd2,
          LOAD_CHAR   = 5'd3;


    // STATE MACHINE
    always @(posedge clock)
    begin: state_table
      case(current_state)

        // WAIT for Input from User.
        WAIT_INPUT: begin

          // If go signal is sent, load input.
          if (go == 1'b0)
            begin
              // Initialize index.
              curr_char_index <= 3'b000;

              // Send a signal to load all of the characters into the registers in the datapath.
              sig_load_chars <= 1'b1;

              next_state <= CIPHER_CHAR;
            end

          // Otherwise, loop until we receive a go signal.
          else
            next_state <= WAIT_INPUT;
        end


        // Cipher the current character.
        CIPHER_CHAR: begin
          sig_load_chars <= 1'b0;
          sig_cipher <= 1'b1;

          next_state <= SET_OUTPUT;
        end

        // Set output from the cipher.
        SET_OUTPUT: begin
          sig_cipher <= 1'b0;
          sig_set_out <= 1'b1;
          next_state <= LOAD_CHAR;
        end

        // Load the next character.
        LOAD_CHAR: begin

          sig_set_out <= 1'b0;
          found <= 1'b0; // We only want to move the index once per FSM cycle, once we've "found" the appropriate case.

          // If we're currently on the 1st character, move current to 2nd character.
          if ((curr_char_index == 3'b000) && (found == 1'b0))
            begin
              curr_char_index <= 3'b001;
              found <= 1'b1;
              next_state <= CIPHER_CHAR;
            end

          // If we're currently on the 2nd character, move current to 3rd character.
          else if ((curr_char_index == 3'b001) && (found == 1'b0))
            begin
            curr_char_index <= 3'b010;
            found <= 1'b1;
            next_state <= CIPHER_CHAR;
            end

          // If we're currently on the 3rd character, move current to 4th character.
          else if ((curr_char_index == 3'b010) && (found == 1'b0))
            begin
            curr_char_index <= 3'b011;
            found <= 1'b1;
            next_state <= CIPHER_CHAR;
            end

          // If we're currently on the 4th character, move current to 5th character.
          else if ((curr_char_index == 3'b011) && (found == 1'b0))
            begin
            curr_char_index <= 3'b100;
            found <= 1'b1;
            next_state <= CIPHER_CHAR;
            end

          // If we're currently on the 5th character, we're done.
          else if ((curr_char_index == 3'b100) && (found == 1'b0))
            begin
            curr_char_index <= 3'b000;
            found <= 1'b1;
            next_state <= WAIT_INPUT;
            end

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

module datapath_vigenere(clock, resetn, char_array, vigenere_shift, decode, sig_load_chars, char_array_out, sig_cipher, sig_set_out, curr_char_index);
  input clock;
  input resetn;
  input [24:0] char_array;
  input [24:0] vigenere_shift;
  input decode;

  // Inputs from the FSM.
  input sig_load_chars;
  input sig_cipher;
  input sig_set_out;
  input [2:0] curr_char_index;

  // Output from caesar cipher.
  wire [4:0] encode_out_1;
  wire [4:0] decode_out_1;
  wire [4:0] encode_out_2;
  wire [4:0] decode_out_2;
  wire [4:0] encode_out_3;
  wire [4:0] decode_out_3;
  wire [4:0] encode_out_4;
  wire [4:0] decode_out_4;
  wire [4:0] encode_out_5;
  wire [4:0] decode_out_5;

  // An array for each character of 5 bits.
  reg [4:0] char1;
  reg [4:0] char2;
  reg [4:0] char3;
  reg [4:0] char4;
  reg [4:0] char5;

  // Current char being ciphered.
  reg [4:0] curr_char;


  // Encrypted output
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

  // Split the vigenere key individually so we can utilize caesar ciphers (modularizing it)
  assign char_array_out[24:20] = shift_val_1;
  assign char_array_out[19:15] = shift_val_2;
  assign char_array_out[14:10] = shift_val_3;
  assign char_array_out[9:5] = shift_val_4;
  assign char_array_out[4:0] = shift_val_5;


  // Instantiate a caesar cipher for first char encode.
  encode_caesar_cipher ecc (
      .clk(clock),
      .data_in(curr_char),
      .cipher_shift(cipher_shift),
      .encode_out(encode_out_1));

  // Instantiate a caesar cipher for first decode.
  decode_caesar_cipher dcc (
      .clk(clock),
      .data_in(curr_char),
      .cipher_shift(cipher_shift),
      .decode_out(decode_out_1));

  // Instantiate a caesar cipher for second encode.
  encode_caesar_cipher ecc (
      .clk(clock),
      .data_in(curr_char),
      .cipher_shift(cipher_shift),
      .encode_out(encode_out_2));

  // Instantiate a caesar cipher for second decode.
  decode_caesar_cipher dcc (
      .clk(clock),
      .data_in(curr_char),
      .cipher_shift(cipher_shift),
      .decode_out(decode_out_2));

    // Instantiate a caesar cipher for third encode.
  encode_caesar_cipher ecc (
      .clk(clock),
      .data_in(curr_char),
      .cipher_shift(cipher_shift),
      .encode_out(encode_out_3));

  // Instantiate a caesar cipher for third decode.
  decode_caesar_cipher dcc (
      .clk(clock),
      .data_in(curr_char),
      .cipher_shift(cipher_shift),
      .decode_out(decode_out_3));

    // Instantiate a caesar cipher for fourth encode.
  encode_caesar_cipher ecc (
      .clk(clock),
      .data_in(curr_char),
      .cipher_shift(cipher_shift),
      .encode_out(encode_out_4));

  // Instantiate a caesar cipher for fourth decode.
  decode_caesar_cipher dcc (
      .clk(clock),
      .data_in(curr_char),
      .cipher_shift(cipher_shift),
      .decode_out(decode_out_4));

    // Instantiate a caesar cipher for fifth encode.
  encode_caesar_cipher ecc (
      .clk(clock),
      .data_in(curr_char),
      .cipher_shift(cipher_shift),
      .encode_out(encode_out_5));

  // Instantiate a caesar cipher for fifth decode.
  decode_caesar_cipher dcc (
      .clk(clock),
      .data_in(curr_char),
      .cipher_shift(cipher_shift),
      .decode_out(decode_out_5));


  // Begin datapath cases.
  always @(posedge clock)
  begin

  // CASE 1: RESET.
  if (resetn == 1'b0)
    begin
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

  // CASE 2: Load in each character
  if (sig_load_chars == 1'b1)
    begin
      char1 <= char_array[24:20];
      char2 <= char_array[19:15];
      char3 <= char_array[14:10];
      char4 <= char_array[9:5];
      char5 <= char_array[4:0];
    end

  // CASE 3: Set the cipher for each character.
  if (sig_cipher == 1'b1)
    begin
      // Set input for cipher.
      case (curr_char_index)
        3'b000: curr_char <= char1; // First character
        3'b001: curr_char <= char2; // Second character
        3'b010: curr_char <= char3; // Third character
        3'b011: curr_char <= char4; // Fourth character
        3'b100: curr_char <= char5; // Fifth character.
      endcase


    end

  // CASE 4: Set the output from the cipher.
  if (sig_set_out == 1'b1)
    begin
      // Set output, based on if we are decoding or encoding.
      if (decode == 1'b0)
        begin

          // Set output.
          case (curr_char_index)
            3'b000: char1_out <= decode_out_1; // First character
            3'b001: char2_out <= decode_out_2; // Second character
            3'b010: char3_out <= decode_out_3; // Third character
            3'b011: char4_out <= decode_out_4; // Fourth character
            3'b100: char5_out <= decode_out_5; // Fifth character.
          endcase
        end

      // We are decoding instead.
      if (decode == 1'b1)
        begin
          // Set output.
          case (curr_char_index)
            3'b000: char1_out <= encode_out_1; // First character
            3'b001: char2_out <= encode_out_2; // Second character
            3'b010: char3_out <= encode_out_3; // Third character
            3'b011: char4_out <= encode_out_4; // Fourth character
            3'b100: char5_out <= encode_out_5; // Fifth character.
          endcase
        end
    end
  end

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