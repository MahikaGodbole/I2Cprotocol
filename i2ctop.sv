    ///////////////////////////////////////
    `include "i2c.sv"
    `include "mc.sv"
    `include "shiftregister.sv"

    module i2c_top(
     input clk,
     input reset_n,
     input Master_EN,
     input wr_rdn_en,   
     input [7:0] input_data,
     input [6:0] addr,
     input [2:0] S,
     input MSBIn,
     input LSBIn,
     output [7:0] data_out,
     output  done
    );
     
    wire sdac;
    logic sclc;
    logic ackc;
    logic [7:0] Results;
     
    ShiftRegister s1 (Results, clk, reset_n, input_data, S, MSBIn, LSBIn);

    eeprom_top e1 (clk, reset_n, Master_EN, ackc,wr_rdn_en, sclc, sdac, Results, addr, data_out, done);
     
    i2cmem_top m1 (clk, reset_n, sclc, sdac, ackc);
     
    endmodule
     
    //////////////////////////////////////////////////
     
     
    interface i2c_if;
      logic clk;
      logic rst;
      logic Master_EN;
      logic wr_rdn_en;   
      logic [7:0] input_data;
      logic [6:0] addr;
      logic [2:0] S; //
      logic MSBIn; // 
      logic LSBIn; //
      logic [7:0] data_out;
      logic  done;
      
      logic sclk_ref; //To give driver and the monitor the acess to a slower clock and also m
                      // and also monitor can sample from the edges of the sclk_ref
      
    endinterface