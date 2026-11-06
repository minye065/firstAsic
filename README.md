SPI Math Slave

In layman's terms: A chip that does math operations.


Operation codes:

0 - Add
1 - Subtract 
2 - AND
3 - OR
4 - XOR
5 - NAND
6 - Left shift
7 - Right shift
8-255 - Returns 8'd0


Input 1, Input 2 and Operation code are all 8 bits
Output is also 8 bits

Mode 0 spi
Byte order:
opcode, input1, input2, dummy byte
Leftmost bit first
sck must be 10x slower than clk

cs_n info:
active is low, keep low for all 4 bytes
after lowering wait 4 clk cycles
after raising wait some clk cycles (in test I used 8)
if cs_n is raised mid-transaction, the sequence is aborted


Some explanations:
clk - The chip's clock
sck - The master's clock
cs_n - Chip select, low = chip is selected
mosi - Master out slave in, or the input into the chip
miso - Master in slave out, or the output from the chip

Every clk cycle we run the main block
We update sck_prev with the current sck
Then we check if we are on a rising edge.
Rising edge - The moment a signal goes from 0 to 1
We do this by using the if statement:
```      if(sck == 1 && sck_prev == 0)      ```
We take this bit into register via bit shifting left.
We increment bit counter, and check if bit counter is 7. If bit counter is 7, what we just put in the register would be the 8th bit. 
We increment bytestate as the opcode, input1 and input2 come in order.
After receiving all input bytes, we then send the output on falling edges, 1 bit at a time through miso. We send the left bit first.

Falling edge - Opposite of a rising edge, the moment a signal goes from 1 to 0

The result is computed continuously from the stored info.

Pins
```
  # Inputs
  ui[0]: "Serial clock"
  ui[1]: "Chip select (active low)"
  ui[2]: "Master out Slave in"

  # Outputs
  uo[0]: "Master in Slave out"
```

what i built

a math slave that has 8 logical operations, (viewer)[https://gds-viewer.tinytapeout.com/?pdk=gf180mcuD&model=https%3A%2F%2Fminye065.github.io%2FfirstAsic%2F%2Ftinytapeout.oas]

!(this)[https://cdn.hackclub.com/01a1af7c-cee1-7f94-87bf-e34eef6f520f/image.png]

how it works

first set the serial clock (ui 0) to 10x slower then the clk
you pick an input code and your 2 inputs, then you set chip select (pin 1) to low, then you pass the inputs to pin 2 in the order: operation, input 1, input 2, then an 8 bit filler (of anything), when you're done you set chip select to high
the chip will do the operation then return the output on pin 0

testing design

The design was tested through a python script that tested every operation, then used an assert to check if the result was correct

!(this)[https://content.instructables.com/F1G/MAQF/MVA0Z9V8/F1GMAQFMVA0Z9V8.png?auto=webp&width=1600&height=900&fit=bounds&md=MjAyNi0xMC0xNiAyMDozMDo0OS4w]

next steps

i really want to add multiplication, division, signs and floats
also want to use all pins to make this an actually viable chip to offload large amounts of math to