module top;

logic Q, Clock, Clear, D;

DFF dff1(Q, Clock, Clear, D);

initial begin
    Clock = 0;
    forever #5 Clock = ~Clock;
end


  always @ (posedge Clock) begin
    $display(" Clear = %d  |  D = %d", Clear, D);
    #1; $display("Q = %d", Q);
    if (Clear == 0 && Q == 0)
        $display("The result is correct");
    else if (Clear == 0 && Q != 0)
        $display("The result is incorrect");
    else if (Clear == 1 && Q == D)
        $display("The result is correct");
    else if (Clear == 1 && Q != D)
        $display("The result is incorrect");
        
end

initial begin
    Clear = 0;
    D = 0;
    #10;
    D = 1;
    #10;
    Clear = 1;
    D = 0;
    #10;
    D = 1;
    #10;
 
end

initial begin
    $display("----------The Testbench Begins----------");
    #40; $display("----------The Testbench Ends----------");
    $display("----------Author: Fardeen Wasey----------");
    $stop();
end

endmodule