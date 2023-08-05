
module i2c_tb();
 
logic clk; //global clock
logic rst;
logic Master_EN; //Checks is new data is available from the functional unit(active high)
logic ackc;
logic wr_rdn_en; //active high write (wr_rdn_en? write : read)  
logic scl;
wire sda;
logic [7:0] Results; //stores the data from the functional unit required to be written
logic [6:0] addr;
logic [7:0] data_out; //stores the data from the memory controller required to be read
logic done;
int sample = 8'b10110011;
reg temp_write =0;

eeprom_top e1 (.clk(clk),
                .reset_n(rst),
                .Master_EN(Master_EN), 
                .ack(ackc),
                .wr_rdn_en(wr_rdn_en),
                .scl(scl),
                .sda(sda),
                .Results(Results),
                .addr(addr),
                .data_out(data_out),
                .done(done));



logic [6:0] memr [128];
logic sda_tmp;
logic [6:0] addr_tmp;


 















always #5 clk = ~clk;

initial begin
  clk =1'b1;;
  ackc=1'b1;
  rst = 1;
  repeat (40) @ (negedge clk); //was 400
  rst = 0;
  repeat (40) @ (negedge clk);  //was 400
  Master_EN = 1;
  wr_rdn_en = 1;
  Results = 8'b01011100;
  addr = 7'b0001111;

/*
  ackc=1'b1;
  rst = 1;
  repeat (40) @ (negedge clk); //was 400
  rst = 0;
  repeat (40) @ (negedge clk);  //was 400
  Master_EN = 1;
  wr_rdn_en = 0;
 // Results = 8'b01011100;
  addr = 7'b0001111;
    */
  /*  $display("Read write : %0d ", sda);
    repeat(90) @ (negedge clk);
    $display("ADDR: A0 %0d ", sda);
    repeat(90) @ (negedge clk);
    $display("ADDR: A1 %0d ", sda);
 repeat(90) @ (negedge clk);
    $display("ADDR: A2 %0d ", sda);
repeat(90) @ (negedge clk);
    $display("ADDR: A3 %0d ", sda);
repeat(90) @ (negedge clk);
    $display("ADDR: A4 %0d ", sda);
repeat(90) @ (negedge clk);
    $display("ADDR: A5 %0d ", sda);
repeat(90) @ (negedge clk);
    $display("ADDR: A6 %0d ", sda);
repeat(90) @ (negedge clk);
    $display("ADDR: A7 %0d ", sda);

repeat(180) @ (negedge clk);


*/
#5000
$finish;
 // S = 1;
  //MSBIn = 0;
 // LSBIn = 0;
  /*repeat (90) @ (negedge clk);
  wr_rdn_en = 0;
  addr = 7'b0001111;
  repeat (100) @ (negedge clk);
  repeat (10000) @ (negedge clk);
  $stop();
  */
  end

always_comb begin
if (done==1) begin
assign wr_rdn_en = temp_write; 
$display("Done danadone!");
end
end


always begin 
//#220
@(posedge scl)


$display("I2C TIME: %0t TB:SDA: %0d", $time, sda);

end

/*
  initial begin
   $monitor("I2C TB %t  rdata = %b   done = %b Master %0d sda: %0b", $time, data_out, done, Master_EN, sda);
  end
*/



endmodule