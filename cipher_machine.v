// Top level module for cipher machine.
module cipher_top(SW, KEY, CLOCK_50, LEDR, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, HEX6);
	/**
	 * SW[9] -> Verify -> If on, verify. 
	 * SW[8] -> Encode/Decode swich -> on for decode, off for encode. 
	 * SW[7:6] -> cipher method: 00 (just display), 01 (caesar cipher), 10 (TBD), 11 
	 * SW[3:0] -> data_in 
	 *
	 * KEY[3] -> 
	 * KEY[2] ->
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
	
	wire [3:0] data_out; 
	
    // Instantiate the cipher machine. 
	cipher(
		.clk(CLOCK_50),
		.resetn(KEY[0])
		.data_in(SW[3:0])
		.decode(SW[8]),
		.cipher_method(SW[7:6]),
		.go(KEY[1]),
		.verify(KEY[2]),
		.data_out(data_out));


endmodule

module cipher(clk, resetn, data_in, decode, cipher_method, go, verify, data_out);

	input clk;
	input [3:0] data_in;
	input decode; // 0 for decode, 1 for encode. 
	input [1:0] cipher_method;
	input go;
	input verify;  
	
	output reg [3:0] data_out; 
	
	wire [3:0] decode_caesar_out; 
	wire [3:0] encode_caesar_out; 
	
	// Sub-level module for CAESAR CIPHER (for decoding).
	decode_caesar_ciper dcc (
			.clk(clk),
			.data_in(data_in),
			.decrypt_out(decode_caesar_out))
	
	// Sub-level module for CAESAR CIPHER (for encoding).
	encode_caesar_cipher eco (
			.clk(clk),
			.data_in(data_in),
			.encode_out(encode_caesar_out));
			
		
	// Set output of cipher based on their decode and cipher method. 
    always @(*)
	begin
		// 3-bit number denoted as dcc - if d is 0, we decode, if d is 1, we encode. cc represents the cipher type. 
		case ({decode, cipher_method})
			3'b000: data_out = data_in; // Case: 000 - print directly to out. 
			3'b001: data_out = decode_caesar_out; // Case: 001 - Caesar Cipher by method of decoding. 
			3'b010: data_out = 4'b0010; // Case: 010 - TBD cipher b method of decoding. 
			3'b011: data_out = 4'b011; // Case: 011 - Free Mux Slot. 
			3'b100: data_out = data_in; // Case: 100 - print directly to out. 
			3'b101: data_out = encode_caesar_out; // Case: 101 - Caesar cipher by method of encoding. 
			3'b110: data_out = 4'b0110; // Case: 110 - TBD cipher by method of encoding. 
			default: data_out = 4'b1111; // If this happens, something went wrong. Display F.
		endcase
	end

endmodule

/** Given a 4-bit data input that has been encoded by a caesar cipher, this will decode the data, returning a decrypted letter. **/
module decode_caesar_cipher(clk, data_in, decrypt_out);

endmodule

/** Given a 4-bit data input, this will encode the data using caesar cipher algorithm. **/
module encode_caesar_cipher(clk, data_in, encode_out);

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

