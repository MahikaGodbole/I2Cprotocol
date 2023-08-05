module DFF(Q, Clock, Clear, D);
output Q;
input Clock;
input Clear;
input D;

logic Q;

always_ff @(posedge Clock, negedge Clear)
begin
    if (Clear)
        Q <= 0;
    else 
        Q <= D;
end

endmodule