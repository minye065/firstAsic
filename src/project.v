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
  reg [1:0] sckSync, csSync, mosiSync;
  wire sck = sckSync[1];
  wire cs_n = csSync[1];
  wire mosi = mosiSync[1];
  reg sck_prev, misoReg;
  reg [7:0] register, opCode, operandA, operandB;
  reg[2:0] bitCounter;
  reg[1:0] byteState;
  reg[7:0] result;


  always@(posedge clk)
  begin
    sckSync <= {sckSync[0], ui_in[0]};
    csSync <= {csSync[0], ui_in[1]};
    mosiSync <= {mosiSync[0], ui_in[2]};
  end
  always@(posedge clk)
  begin
    sck_prev <= sck;
    if(rst_n == 0)
    begin
      register <= 0;
      opCode <= 0;
      operandA <= 0;
      operandB <= 0;
      bitCounter <= 0;
      byteState <= 0;
      misoReg <= 0;
    end
    else if(cs_n == 1)
    begin
      bitCounter <= 0;
      byteState <= 0;
      misoReg <= 0;
    end
    else
    begin
      if(sck == 1 && sck_prev == 0)
      begin
        register <= {register [6:0], mosi};
        bitCounter <= bitCounter + 1;
        if(bitCounter == 7)
        begin
          byteState <= byteState + 1;
          case(byteState)
          0: opCode <= {register[6:0], mosi};
          1: operandA <= {register[6:0], mosi};
          2: operandB <= {register[6:0], mosi};
          endcase
        end
      end
      if(sck == 0 && sck_prev == 1)
      begin
        if(byteState == 3)
        begin
          misoReg <= result[7 - bitCounter];
        end
      end
    end
  end
  always@(*)
  begin
    case(opCode)
      0: result = operandA + operandB;
      1: result = operandA - operandB;
      2: result = operandA & operandB;
      3: result = operandA | operandB;
      4: result = operandA ^ operandB;
      5: result = ~operandA;
      6: result = operandA << operandB;
      7: result = operandA >> operandB;
      default: result = 8'd0;
    endcase
  end
  assign uo_out = { 7'b0, misoReg};
  assign uio_out = 8'b0;
  assign uio_oe = 8'b0;
  wire _unused = &{ena, uio_in, 1'b0};
endmodule