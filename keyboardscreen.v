module keyboard_to_led(SW, CLOCK_50, LEDR, PS2_DAT, PS2_CLK, reset);
  input [9:0] SW;
  input PS2_DAT;
  input PS2_CLK;
  input CLOCK_50;
  output [9:0] LEDR;

  keyboard_scancoderaw_driver k1(
    .CLOCK_50(CLOCK_50),
    .scan_ready(scan_ready_wire),
    .scan_code(keyboard_out),
    .PS2_DAT(PS2_DAT),
    .PS2_CLK(PS2_CLK)
    .reset(reset) //need to assign this to something
    );

    output reg [6:0] letter_out;

    always @(*)
        case (keyboard_out)
            8'b010011110: letter_out = 5'b00001; //a, 1
            8'b010110000: letter_out = 5'b00010; //b, 2
            8'b010101110: letter_out = 5'b00011; //c, 3
            8'b010100000: letter_out = 5'b00100; //d, 4
            8'b010010010: letter_out = 5'b00101; //e, 5
            8'b010100001: letter_out = 5'b00110; //f, 6
            8'b010100010: letter_out = 5'b00111; //g, 7
            8'b010100011: letter_out = 5'b01000; //h, 8
            8'b010010111: letter_out = 5'b01001; //i, 9
            8'b010100100: letter_out = 5'b01010; //j, 10
            8'b010100101: letter_out = 5'b01011; //k, 11
            8'b010100110: letter_out = 5'b01100; //l, 12
            8'b010110010: letter_out = 5'b01101; //m, 13
            8'b010110001: letter_out = 5'b01110; //n, 14
            8'b010011000: letter_out = 5'b01111; //o, 15
            8'b010011001: letter_out = 5'b10000; //p, 16
            8'b010010000: letter_out = 5'b10001; //q, 17
            8'b010010011: letter_out = 5'b10010; //r, 18
            8'b010011111: letter_out = 5'b10011; //s, 19
            8'b010010100: letter_out = 5'b10100; //t, 20
            8'b010010110: letter_out = 5'b10101; //u, 21
            8'b010101111: letter_out = 5'b10110; //v, 22
            8'b010010001: letter_out = 5'b10111; //w, 23
            8'b010101101: letter_out = 5'b11000; //x, 24
            8'b010010101: letter_out = 5'b11001; //y, 25
            8'b010101100: letter_out = 5'b11010; //y, 26
            default: letter_out = 5'b00000; //receive a key that isnt [a,z]
        endcase

output reg [6:0] led_reg;

assign
always @(*)
  if(scan_ready_wire <= 1'b1)
  begin
    assign LEDR = letter_out;
  end

endmodule


module keyboard_scancoderaw_driver(
  input  CLOCK_50,
  output scan_ready, // 1 when a scan_code arrives from the inner driver
  output [7:0] scan_code, // most recent byte scan_code
  input    PS2_DAT, // PS2 data line
  input    PS2_CLK, // PS2 clock line
  input reset
);

wire read;

// generates the read signal for the keyboard inner driver
oneshot pulser(
   .pulse_out(read),
   .trigger_in(scan_ready),
   .clk(CLOCK_50)
);

// inner driver that handles the PS2 keyboard protocol
// outputs a scan_ready signal accompanied with a new scan_code
keyboard_inner_driver kbd(
  .keyboard_clk(PS2_CLK),
  .keyboard_data(PS2_DAT),
  .clock50(CLOCK_50),
  .reset(reset),
  .read(read),
  .scan_ready(scan_ready),
  .scan_code(scan_code)
);

endmodule



module keyboard_inner_driver(keyboard_clk, keyboard_data, clock50, reset, read, scan_ready, scan_code);
input keyboard_clk;
input keyboard_data;
input clock50; // 50 Mhz system clock
input reset;
input read;
output scan_ready;
output [7:0] scan_code;
reg ready_set;
reg [7:0] scan_code;
reg scan_ready;
reg read_char;
reg clock; // 25 Mhz internal clock

reg [3:0] incnt;
reg [8:0] shiftin;

reg [7:0] filter;
reg keyboard_clk_filtered;

// scan_ready is set to 1 when scan_code is available.
// user should set read to 1 and then to 0 to clear scan_ready

always @ (posedge ready_set or posedge read)
if (read == 1) scan_ready <= 0;
else scan_ready <= 1;

// divide-by-two 50MHz to 25MHz
always @(posedge clock50)
    clock <= ~clock;



// This process filters the raw clock signal coming from the keyboard
// using an eight-bit shift register and two AND gates

always @(posedge clock)
begin
   filter <= {keyboard_clk, filter[7:1]};
   if (filter==8'b1111_1111) keyboard_clk_filtered <= 1;
   else if (filter==8'b0000_0000) keyboard_clk_filtered <= 0;
end


// This process reads in serial data coming from the terminal

always @(posedge keyboard_clk_filtered)
begin
   if (reset==1)
   begin
      incnt <= 4'b0000;
      read_char <= 0;
   end
   else if (keyboard_data==0 && read_char==0)
   begin
    read_char <= 1;
    ready_set <= 0;
   end
   else
   begin
       // shift in next 8 data bits to assemble a scan code
       if (read_char == 1)
           begin
              if (incnt < 9)
              begin
                incnt <= incnt + 1'b1;
                shiftin = { keyboard_data, shiftin[8:1]};
                ready_set <= 0;
            end
        else
            begin
                incnt <= 0;
                scan_code <= shiftin[7:0];
                read_char <= 0;
                ready_set <= 1;
            end
        end
    end
end

endmodule