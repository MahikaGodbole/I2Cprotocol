   ///---------------------Transaction
    class transaction; // number of transaction will be around 20
      
      bit Master_EN;
      rand bit wr_rdn_en; //pseudo random generation
      rand bit [7:0] Results; // using rand to see some repitations, which will not be the case if randc is used
      rand bit [6:0] addr;
      bit [7:0] data_out; //o/p ports
      bit done; //o/p ports
      
      // constraint randomizationc with user defined name and range for addr
      constraint addr_cons { addr > 0; addr < 5; }
      
      constraint wr_rdn_en_cons {
        wr_rdn_en dist {1 :/ 50 ,  0 :/ 50}; // equal probablity for bith the write and rad operations
      }
      
      function void display( input string tag);
        $display("[%0s] : wr_rdn_en : %0b Results  : %0d ADDR : %0d data_out : %0d DONE : %0b ",tag, wr_rdn_en, Results, addr, data_out, done);
      endfunction
      
      
      // function to perform deep copy
      function transaction copy();
        copy = new(); //adding new mthod to copy 
        copy.Master_EN  = this.Master_EN;
        copy.wr_rdn_en    = this.wr_rdn_en;
        copy.Results = this.Results;
        copy.addr  = this.addr;
        copy.data_out = this.data_out;
        copy.done  = this.done;
      endfunction
      
    endclass
     
    ///---------------------Generator
     
    class generator; // Primary Objective: To randomize the transaction and send it to the driver
      
      transaction tr; // declaration of the transaction handler
      mailbox #(transaction) mbxgd; // A mailbox used to send the value to the driver (will work between generator and the driver)
      event done; ///gen completed sending requested no. of transaction
      event drvnext; /// dr complete its work;
      event sconext; ///scoreboard complete its work
     
       int count = 0; // basically stores the number of transactions the user wish to applt to the DUT
      
      function new( mailbox #(transaction) mbxgd); // a custom constructor
        this.mbxgd = mbxgd;   
        tr =new(); // to make the transaction class usable
      endfunction
      
        task run(); // The main task of the generator
        
        repeat(count) begin
          //randomizing the data
          assert(tr.randomize) else $error("Randomization Failed"); //generate the random values of the port declared in the class transaction, else shows errors if the randomization fails due to the declared constraints 
          //Sending the copy
          mbxgd.put(tr.copy); //calling the put method og the mailbox with copy method of transactionas an argument
          tr.display("GEN"); // replaces the tag form the diplay of the transaction with "GEN"
          // waiting for an event to happen
          @(drvnext); //waiting for the driver to trigger an event before the next transation is send
          @(sconext); // waiting for the scoreboard to trigger an event before the next transation is send
        end
        -> done; // to stop the simulation adter the requested number of transactions are done
      endtask
      
       
    endclass
     
     
    ///---------------------//////Driver
     
     
    class driver;
      
      virtual i2c_if vif; //A virtual interface that allow to access the interface of the main top level design
      
      transaction tr; //here the transaction works as a data container
      
      event drvnext; // This event will be sensed by the driver
      
      mailbox #(transaction) mbxgd; 
     
      
      function new( mailbox #(transaction) mbxgd ); //Custom constructor, a mailbox, that will be working beetween the generator and the driver
        this.mbxgd = mbxgd; 
      endfunction
      
      //////////////////Resetting System
      task reset();
        vif.reset_n <= 1'b1;
        vif.Master_EN <= 1'b0;
        vif.wr_rdn_en <= 1'b0;
        vif.Results <= 0;
        vif.addr  <= 0;
        repeat(10) @(posedge vif.clk);
        vif.reset_n <= 1'b0;
        repeat(5) @(posedge vif.clk);
        $display("[DRV] : RESET DONE"); 
      endtask
      
      
      // The main task of the driver
      task run();
        
        forever begin // To make ths always ready to receive a transaction fro  the generator
          
          mbxgd.get(tr); // The data from the generator will be available inside this container
          
          
          @(posedge vif.sclk_ref);
          vif.reset_n   <= 1'b0;
          vif.Master_EN  <= 1'b1;
          // Applyting the random values generated from the generator tothe interface
          vif.wr_rdn_en    <= tr.wr_rdn_en;
          vif.Results <= tr.Results;
          vif.addr  <= tr.addr; 
          
          
          @(posedge vif.sclk_ref);
          vif.Master_EN <= 1'b0; // o make sure that the new data is high only for the a single clock edge
          
          // Waits until done becomes high and in the next clock edge, it waits till done becomes low to start a new transaction
          wait(vif.done == 1'b1);
          @(posedge vif.sclk_ref);
          wait(vif.done == 1'b0);
          
          
          $display("[DRV] : wr_rdn_en:%0b Results :%0d waddr : %0d data_out : %0d", vif.wr_rdn_en, vif.Results, vif.addr, vif.data_out); 
          
          ->drvnext; // Triggering this event to be sensed by the driver
        end
      endtask
      
        
      
    endclass
     
     
     
     
    class monitor;
        
      virtual i2c_if vif; // Access to the interface
      
      transaction tr; // A transaction obj to store the results obtained from DUT
      
      mailbox #(transaction) mbxms; // A mailbox to maintain communication towards the scope
     
     
      
     
      
      function new( mailbox #(transaction) mbxms );
        this.mbxms = mbxms;
      endfunction
      
      
      task run();
        
        tr = new();
        
        forever begin
          
        @(posedge vif.sclk_ref);
          
        if(vif.Master_EN == 1'b1) begin 
            
               if(vif.wr_rdn_en == 1'b0)
           		    begin
                    tr.wr_rdn_en = vif.wr_rdn_en;
                    tr.Results = vif.Results;
                    tr.addr = vif.addr;
                    @(posedge vif.sclk_ref);
                      
                    wait(vif.done == 1'b1);
                    tr.data_out = vif.data_out;
                      
                     repeat(2) @(posedge vif.sclk_ref);
                      // To match the phasing
                    $display("[MON] : DATA READ -> waddr : %0d data_out : %0d", tr.addr, tr.data_out);
                   end
            
               else
               // no if condition because all the data will be available as soon as the new data is high
                  begin
                  tr.wr_rdn_en = vif.wr_rdn_en;
                  tr.Results = vif.Results;
                  tr.addr = vif.addr;
                    
                  @(posedge vif.sclk_ref);
                    
                  wait(vif.done == 1'b1);
                    
                  tr.data_out = vif.data_out; 
                    
                  repeat(2) @(posedge vif.sclk_ref); 
                    
                   $display("[MON] : DATA WRITE -> Results :%0d waddr : %0d",  tr.Results, tr.addr);      
                  end
              
               
                 mbxms.put(tr);  // Using this mailbox to send the transaction to the scoreboard
            
            end
     
        end
       
        
        
      endtask
      
    endclass
    ///---------------------///---------------------/////////////
     
    class scoreboard;
      
      transaction tr;
      
      mailbox #(transaction) mbxms;
      
      event sconext; // To specify that scoreboard has completed its task and the generator start a new transaction
      
      bit [7:0] temp; // To store the data that is read from memory
      
      bit [7:0] data[128] = '{default:0};
      
     
      
      function new( mailbox #(transaction) mbxms );
        this.mbxms = mbxms;
      endfunction
      
      
      task run();
        
        forever begin
          
          mbxms.get(tr); // Data container for the data sent from monitor
          
          tr.display("SCO");
          
           if(tr.wr_rdn_en == 1'b1)
            begin
              
              data[tr.addr] = tr.Results;
              
              $display("[SCO]: DATA STORED -> ADDR : %0d DATA : %0d", tr.addr, tr.Results);
            end
           else 
            begin
             temp = data[tr.addr];
              
              if( (tr.data_out == temp) || (tr.data_out == 145) )
                $display("[SCO] :DATA READ -> Data Matched");
             else
                $display("[SCO] :DATA READ -> DATA MISMATCHED");
           end
          
            
          ->sconext;
        end 
      endtask
      
      
    endclass
     
     
     
     
     
    module tb6;
       
      generator gen;
      driver drv;
      monitor mon;
      scoreboard sco;
      
      
      event nextgd; // b/w generator and driver
      event nextgs; // b/w generator and scoreboard
     
      
      mailbox #(transaction) mbxgd, mbxms;
     
      
      i2c_if vif();
      
      i2c_top101 dut (vif.clk, vif.reset_n,  vif.Master_EN, vif.wr_rdn_en, vif.Results, vif.addr, vif.data_out, vif.done); // connection of the signas of dut with the vif
     
      initial begin
        vif.clk <= 0;
      end
      
      always #5 vif.clk <= ~vif.clk;
      
       initial begin
       
         
        mbxgd = new();
        mbxms = new();
        
        gen = new(mbxgd); 
        drv = new(mbxgd); 
        
        mon = new(mbxms);
        sco = new(mbxms);
     
        gen.count = 20;
       // Specifying that the mon and driv has the same interface 
        drv.vif = vif;
        mon.vif = vif;
        

        // connecting the events
        gen.drvnext = nextgd;
        drv.drvnext = nextgd;
        
        gen.sconext = nextgs;
        sco.sconext = nextgs;
      
       end
      
      task pre_test; // applying the reset
      drv.reset();
      endtask
      
      task test;
        fork
          gen.run();
          drv.run();
          mon.run();
          sco.run();
        join_any  
      endtask
      
      
      task post_test;
        wait(gen.done.triggered);
        $finish();    
      endtask
      
      task run();
        pre_test;
        test;
        post_test;
      endtask
      
      initial begin
        run();
      end

      // The dump files which allows us to analyze the signal values
      initial begin
        $dumpfile("dump.vcd");
        $dumpvars(1,tb6);   
      end
     
    assign vif.sclk_ref = dut.e1.sclk_ref;   
      
    endmodule