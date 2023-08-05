//-----------memory_controller-----------------
     
module i2cmem_top (
input clk, reset_n,
input scl,
inout sda,
output logic ack
);

logic [7:0] memory [127:0]; 
logic [7:0] addr_store, data_temp, rd_temp; 
logic sda_en = 0;
logic sda_temp = 0;
  
int i = 0;
int count = 0; 
logic sclk_ref = 0;

assign sda = sda_en ? 1'bz : sda_temp;

  always@(posedge clk)
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
    
    
  
typedef enum {START, ADDR_STORE, ADDR_ACK_WAITE, DATA_STORE, DATA_ACK_WAITE, STOP, DATA_SEND} state_type;
state_type state;
  
  
always_ff @ (posedge sclk_ref, posedge reset_n)
    begin 
      if(reset_n) begin
        for(int j =0; j < 127 ; j++) begin 
          memory[j] <= 8'h00;
        end
        sda_en <= 1;        
        end 
         
      else
      begin
        case(state)
          START: begin
            sda_en <= 1;  ///read data
          if ((scl) && (~sda)) begin //checking for start condition from i2c
                state <= ADDR_STORE;
                end
            else
              state <= START;         
          end
          
          ADDR_STORE: begin
            sda_en <= 1; ///read data
            if(i <= 7) begin
            i <= i + 1;
            addr_store[i] <= sda;
          end
          else begin
              state <= ADDR_ACK_WAITE;
              rd_temp <= memory[addr_store[7:1]]; 
              ack <= 1; 
              i <= 0;
              end
          end
          
          ADDR_ACK_WAITE: begin
            ack <= 1'b0;
                  
          if(addr_store[0]) begin
              state <= DATA_STORE;
              sda_en <= 1; 
              end
          else begin
              state <= DATA_SEND;
              i <= 1;
              sda_en <= 1'b0;  //
              sda_temp <= rd_temp[0];
            end
          end
          
          DATA_STORE : 
          begin
          
          if(i <= 7) begin
            i <= i + 1;
            data_temp[i] <= sda;
          end
          else begin
              state <= DATA_ACK_WAITE; 
              ack <= 1;
              i <= 0;
              end   
          end
          
          DATA_ACK_WAITE : begin
            ack <= 1'b0;
            memory[addr_store[7:1]] <= data_temp;
            state <= STOP;    
          end
          
          STOP: begin
            sda_en <= 1;
          if( (scl) && (sda) )
            state <= START;
            else
            state <= STOP; 
          end
          
          DATA_SEND : begin
            sda_en <= 1'b0;
          if(i <= 7) begin
            i <= i + 1;
            sda_temp <= rd_temp[i];
            end
          else begin
              state <= STOP; 
              i <= 0;
              sda_en <= 1;
              end 
          end
          
          default : state <= START;
        endcase
      end
    end
     
    endmodule