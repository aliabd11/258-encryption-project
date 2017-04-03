 /****************************************************************************
 *			CIPHER MACHINE - A final project for CSC258	(Computer Org.)		*
 *																			*
 *				By Abdullah Ali and Mohamed Hammoud							*
 *							Winter 2017										*
 *																			*
 ****************************************************************************/

// Top level module for cipher machine.
module cipher_top(SW, KEY, CLOCK_50, LEDR);  	

	// SW[9] Verify (0 -> Verify, 1 -> No verify), SW[8] -> Encode/Decode, SW[7:6] -> Cipher Method.
	// SW[5] -> Reset, SW[4:0] -> data_in. 
	input [9:0] SW; 

	// KEY[3] -> Load Key. KEY[2] -> Load Char. KEY[1] -> Run Cipher (go). KEY[0] -> View next character.
	input [3:0] KEY;

	// 50ms clock. 
	input CLOCK_50;
	
	output [9:0] LEDR;

	// Output wire.
	wire [24:0] data_out;

	// Array for each character (each character is 5 bits). A character starts at 'a', (5'b00001) and ends at 'z' (5'b11010).
	reg [4:0] char1;
	reg [4:0] char2;
	reg [4:0] char3;
	reg [4:0] char4;
	reg [4:0] char5;

	// For the vigenere cipher, we require a key that is up to 5 characters long.
	reg [4:0] cipher_shift_1;
	reg [4:0] cipher_shift_2;
	reg [4:0] cipher_shift_3;
	reg [4:0] cipher_shift_4;
	reg [4:0] cipher_shift_5;


	// A completed string array, with each character taking up 5 bits.
	wire [24:0] char_array;

	// A completed vigenere cipher key. 
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

	// Cipher key. 
	assign cipher_shift[24:20] = cipher_shift_1;
	assign cipher_shift[19:15] = cipher_shift_2;
	assign cipher_shift[14:10] = cipher_shift_3;
	assign cipher_shift[9:5] = cipher_shift_4;
	assign cipher_shift[4:0] = cipher_shift_5;

    // Instantiate the cipher machine.
	cipher cm(
		.clk(CLOCK_50),
		.resetn(SW[5]),
		.data_in(char_array),
		.cipher_shift(cipher_shift),
		.decode(SW[8]),
		.cipher_method(SW[7:6]),
		.go(KEY[1]),
		.verify_in(KEY[2]),
		.data_out(data_out),
		.verify_out(verify_out));

	// Load in keys. 
	always @(posedge CLOCK_50)
	begin
		// Reset signal. Clear string registry.
		if (SW[5] == 1'b0)
		begin
			char1 <= 5'b00000;
			char2 <= 5'b00000;
			char3 <= 5'b00000;
			char4 <= 5'b00000;
			char5 <= 5'b00000;
			cipher_shift_1 <= 5'b00000;
			cipher_shift_2 <= 5'b00000;
			cipher_shift_3 <= 5'b00000;
			cipher_shift_4 <= 5'b00000;
			cipher_shift_5 <= 5'b00000;
			current_char_index <= 2'b00;
			current_cipher_shift_index <= 2'b00; 
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
			
			current_char_index <= current_char_index + 1'b1;

		end 
		// Load key. 
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
			current_cipher_shift_index <= current_cipher_shift_index + 1'b1;
		end

		// Load verify data in. Check against data_out.
			// todo

	end

	// If verify is high, display an image.
	/**always @(posedge clock)
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
	end**/

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

	output reg [24:0] data_out;
	output verify_out; 

	// Wires for the control and datapath.
	wire sig_done_caesar;
	wire sig_load_chars_caesar;
	wire sig_cipher_caesar;
	wire sig_set_out_caesar;
	wire [2:0] current_char_index_caesar;

	wire sig_done_vg;
	wire sig_load_chars_vg;
	wire sig_cipher_vg;
	wire sig_set_out_vg;
	wire [2:0] current_char_index_vg;


	// Output from datapath.
	wire [24:0] data_caesar;
	wire [24:0] data_vigenere;


	control_caesar cc(
		.clock(clk),
		.resetn(resetn),
		.go(go),
		.sig_load_chars(sig_load_chars_caesar),
		.sig_cipher(sig_cipher_caesar),
		.sig_set_out(sig_set_out_caesar),
		.curr_char_index(current_char_index_caesar));

	datapath_caesar cdp(
		.clock(clk),
		.resetn(resetn),
		.char_array(data_in),
		.cipher_shift(cipher_shift[24:20]),
		.decode(decode),
		.sig_load_chars(sig_load_chars_caesar),
		.sig_cipher(sig_cipher_caesar),
		.curr_char_index(current_char_index_caesar),
		.char_array_out(data_caesar),
		.sig_set_out(sig_set_out_caesar));


	control_vigenere cv(
		.clock(clk),
		.resetn(resetn),
		.go(go),
		.sig_load_chars(sig_load_chars_vg),
		.sig_cipher(sig_cipher_vg),
		.sig_set_out(sig_set_out_vg),
		.curr_char_index(current_char_index_vg));

	datapath_vigenere vdp(
		.clock(clk),
		.resetn(resetn),
		.char_array(data_in),
		.vigenere_shift(cipher_shift),
		.decode(decode),
		.sig_load_chars(sig_load_chars_vg),
		.sig_cipher(sig_cipher_vg),
		.curr_char_index(current_char_index_vg),
		.char_array_out(data_vigenere),
		.sig_set_out(sig_set_out_vg));


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
  wire [4:0] encode_out;
  wire [4:0] decode_out;

  // An array for each character of 5 bits.
  reg [4:0] char1;
  reg [4:0] char2;
  reg [4:0] char3;
  reg [4:0] char4;
  reg [4:0] char5;

  // Current char being ciphered.
  reg [4:0] curr_char;
  reg [4:0] curr_cipher_shift; 

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

  // Instantiate a caesar cipher for first char encode.
  encode_caesar_cipher ecc (
      .clk(clock),
      .data_in(curr_char),
      .cipher_shift(curr_cipher_shift),
      .encode_out(encode_out));

  // Instantiate a caesar cipher for first decode.
  decode_caesar_cipher dcc (
      .clk(clock),
      .data_in(curr_char),
      .cipher_shift(curr_cipher_shift),
      .decode_out(decode_out));

  // Begin datapath cases.
  always @(posedge clock)
  begin

  // CASE 1: RESET.
  if (resetn == 1'b0)
    begin
      curr_char <= 5'b00000;
      curr_cipher_shift <= 5'b00000; 
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

      // Set input for key.
      case (curr_char_index)
      	3'b000: curr_cipher_shift <= vigenere_shift[24:20];
      	3'b001: curr_cipher_shift <= vigenere_shift[19:15];
      	3'b010: curr_cipher_shift <= vigenere_shift[14:10];
      	3'b011: curr_cipher_shift <= vigenere_shift[9:5];
      	3'b100: curr_cipher_shift <= vigenere_shift[4:0];
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
			encode_out <= (data_in + cipher_shift) % 26;
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
		decode_out <= (data_in - cipher_shift) % 26;
	end

endmodule


