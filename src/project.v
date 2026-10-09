`default_nettype none

module tt_um_math_module
(
  input  wire [7:0] ui_in,
  output wire [7:0] uo_out,
  input  wire [7:0] uio_in,
  output wire [7:0] uio_out,
  output wire [7:0] uio_oe,
  input wire ena,
  input wire clk,
  input wire rst_n
);


  wire sck = ui_in[0];
  wire cs_n = ui_in[1];
  wire mosi = ui_in[2];
  reg sck_prev;
  reg [7:0] register;
  reg[2:0] bitCounter;
  always@(posedge clk)
  begin
    sck_prev <= sck;
    if(sck == 1 && sck_prev == 0)
    begin
      register <= {register [6:0], mosi};
      bitCounter <= bitCounter + 1;
    end
    case(operation)
      4'0x00:
        input1 + input2
      4'0x01:
      input1 - input2
      4'0x02:
      4'0x03:
      4'0x04:
      4'0x05:
    endcase
  end

  

endmodule
