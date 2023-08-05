module top;

logic Y;
logic [7:0] V;
logic [2:0] S;

Mux8to1 m81 (Y, V, S);


initial begin
  V = 8'b01011100;
    #1; for (int i = 0; i < 8; i++) begin
        S = i[7:0];
        #1;
      if (Y != V[i])
            $display("Error when S = %d", S);
    end
    $display("-----------------The Test Bench Ends-----------------");
    $display("-----------------Author: Fardeen Wasey-----------------"); 
end

initial begin
    $display("-----------------The Test Bench Begins-----------------");
end

endmodule