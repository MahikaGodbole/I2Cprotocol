
     
     
     
    ///////////////////////////////////////
    `include "i2c.sv"
    `include "mc.sv"

    module i2c_top101(
     input clk,
     input reset_n,
     input Master_EN,
     input wr_rdn_en,   
     input [7:0] Results,
     input [6:0] addr,
     output [7:0] data_out,
     output  done
    );
     
    wire sdac;
    wire sclc;
    wire ackc;
     
    eeprom_top e1 (clk,reset_n,Master_EN, ackc,wr_rdn_en,sclc, sdac, Results, addr, data_out,done);
     
    i2cmem_top m1 (clk,reset_n, sclc, sdac, ackc);
     
    endmodule
     
    //////////////////////////////////////////////////
     
     
    interface i2c_if;
      logic clk;
      logic reset_n;
      logic Master_EN;
      logic wr_rdn_en;   
      logic [7:0] Results;
      logic [6:0] addr;
      logic [7:0] data_out;
      logic  done;
      logic sclk_ref;
      
      
    endinterface
     


// Testbench Code:


