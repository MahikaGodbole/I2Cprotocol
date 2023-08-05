module tb111;

     logic clk;
     logic reset_n;
     logic Master_EN;
     logic wr_rdn_en;   
     logic [7:0] input_data;
     logic [6:0] addr;
     logic [2:0] S;
     logic MSBIn;
     logic LSBIn;
     logic [7:0] data_out;
     logic  done;


    i2c_top dut (.*);

    reg [7:0] mem[128];
    bit err_flag;
    parameter clkd = 1000;

initial begin
  clk = 0; 
  forever #1 clk = ~clk; 
end


initial begin
  reset_n = 1; //2001
  #2001;
  reset_n = 0;
end

initial begin
  smode1 ();
 // smode2();
 #1000
  error_flag();
  $stop();
end


task smode1();
#2003;
Master_EN = 1;
wr_rdn_en = 1;
input_data = 8'b00010101;
addr = 7'b0010101;
S = 1;
#1000;
Master_EN = 0;
#100;
Master_EN = 1;
wr_rdn_en = 0;
addr = 7'b0010101;
S = 1;
#800;
Master_EN = 0;
#200;
if (data_out !== input_data) begin
  $error("mode1: The value should be %0b     Actual Value = %0b", input_data, data_out);
  err_flag = 1;
end

// done wr = 1 3057
// data_out = 4025
// done rd = 1 4113
endtask

task smode2();
#2003;
Master_EN = 1;
wr_rdn_en = 1;
input_data = 8'b00110111;
addr = 7'b1010101;
S = 2;
// #20;
// S = 0;
#1000;
Master_EN = 0;
#100;
Master_EN = 1;
wr_rdn_en = 0;
addr = 7'b1010101;
//S = 0;
#800;
Master_EN = 0;
#200;
if (data_out !== (input_data>>1)) begin
  $error("mode2: The value should be %0b     Actual Value = %0b", input_data, data_out);
  err_flag = 1;
end


endtask


//Checks the rst condition

  

  initial begin
   $monitor("%t      wr_rdn_en = %0b     data_out = %b      done = %0b    Master_EN = %0b    reset_n = %0b      input_data = %0b    addr = %0b  ", $time, wr_rdn_en, data_out, done, Master_EN, reset_n, input_data, addr);
  end

task error_flag();
if (err_flag !== 1)
  $display("There are no errors in this design");
endtask


endmodule