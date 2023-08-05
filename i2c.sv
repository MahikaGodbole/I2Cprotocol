// i2c interface design

module eeprom_top
(
input clk, //global clock
input reset_n,
input Master_EN, //Checks is new data is available from the functional unit(active high)
input ack,
input wr_rdn_en, //active high write (wr_rdn_en? write : read)  
output scl,
inout sda,
input [7:0] Results, //stores the data from the functional unit required to be written
input [6:0] addr,
output logic [7:0] data_out, //stores the data from the memory controller required to be read
output logic done
);

// logic wr = address[0];
// logic addr = address[7:1];

// for write operation: the Master_EN should be high. On the same time, wr_rdn_en should be high
// after the data is written, done should be high

logic scl_temp, sda_temp, done_temp; //temp vars used to hold the value to the scl, sda, and done 
//logic [7:0] data_outt; 
logic [7:0] addr_temp; // temp addr var to store the 7 bit addr + the wr signal to the LSB
logic sda_en = 0;

typedef enum {IDLE, CHECK_WR_RD, START, WR_ADDR_SEND, WR_ADDR_ACK_WAITE, WR_DATA_SEND, WR_DATA_ACK_WAITE, RD_ADDR_SEND, RD_DATA_ACK_WAITE, RD_DATA_SEND, STOP } state_t;
state_t state;


assign sda = sda_en ? sda_temp : 1'bz; //will get tristated if reading form mem ctrlr

logic sclk_ref = 0;
int count = 0;
int i = 0; // will in transmission of data and addrs serially

assign scl = (( state == START) || ( state == STOP)) ? scl_temp : sclk_ref;

always_ff @(posedge clk) //generation of the ref clk which has a lower freq as compared to the global clk
  begin
    if(count < 10) 
      begin
          count <= count + 1;     
      end
    else
        begin
          count     <= 0; 
          sclk_ref  <= ~sclk_ref;
        end	      
  end


always_ff @(posedge sclk_ref, posedge reset_n)
  begin 
    if(reset_n)
        begin
          scl_temp  <= 0;
          sda_temp  <= 0;
          done_temp <= 0;
        end
    
else           
    begin
    case(state)
      IDLE : 
      begin
        sda_temp <= 0;
        done <= 0;
        sda_en  <= 1;
        scl_temp <= 1;
        sda_temp <= 1;
        if(Master_EN == 1) 
          state  <= START;
        else 
            state <= IDLE;         
      end
    
      START: 
      begin
        sda_temp  <= 0;// |This is the    | 
        scl_temp  <= 1;// |start condition|
        state <= CHECK_WR_RD;
        addr_temp <= {addr,wr_rdn_en}; //append the wr_rdn_en signal to the lsb of the addrs and giving it to the tmp addr var
      end
      
      
      
      CHECK_WR_RD: begin
        if(wr_rdn_en) 
            begin
            state <= WR_ADDR_SEND;
            sda_temp <= addr_temp[0];
            i <= 1;
            end
          else 
            begin
            state <= RD_ADDR_SEND;
            sda_temp <= addr_temp[0];
            i <= 1;
            end
      end
    
              


  // States for wr_rdn_en operation 
    
      WR_ADDR_SEND : begin                
                if(i <= 7) begin
                sda_temp  <= addr_temp[i]; 
                i <= i + 1;
                end
                else
                  begin
                    i <= 0;
                    state <= WR_ADDR_ACK_WAITE; 
                  end   
              end
    
    
      WR_ADDR_ACK_WAITE : begin // waits for the ack from the mc side
        if(ack) begin
          state <= WR_DATA_SEND;
          sda_temp  <= Results[0]; 
          i <= i + 1;
          end
        else
          state <= WR_ADDR_ACK_WAITE;
      end
    
    WR_DATA_SEND : begin
      if(i <= 7) begin
        i     <= i + 1;
        sda_temp  <= Results[i]; 
      end
      else begin
        i     <= 0;
        state <= WR_DATA_ACK_WAITE;
      end
    end
    
    WR_DATA_ACK_WAITE : begin
        if(ack) begin
          state <= STOP;
          sda_temp <= 0; 
          scl_temp <= 1; 
          end
        else begin
          state <= WR_DATA_ACK_WAITE;
        end 
      end
    
    
    RD_ADDR_SEND : begin
                if(i <= 7) begin
                sda_temp  <= addr_temp[i];
                i <= i + 1;
                end
                else
                  begin
                    i <= 0;
                    state <= RD_DATA_ACK_WAITE; 
                  end   
              end
    
    
      RD_DATA_ACK_WAITE : begin
        if(ack) begin
          state  <= RD_DATA_SEND;
          sda_en <= 0;
        end
        else
          state <= RD_DATA_ACK_WAITE;
      end
    
    RD_DATA_SEND : begin
              if(i <= 7) begin
                    i <= i + 1;
                    state <= RD_DATA_SEND;
                    data_out[i] <= sda; // reading the data coming via sda line from mc
                end
                else
                  begin
                    i <= 0;
                    state <= STOP;
                    scl_temp <= 1;
                    sda_temp <= 0;  
                  end         
    end 
    
  
    
    
    STOP: begin
        sda_temp  <=  1;
        state <=  IDLE;
        done  <=  1;  
        end
    
    
    default : state <= IDLE;
    
        endcase
  end

  end

endmodule