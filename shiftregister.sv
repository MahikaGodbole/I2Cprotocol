`include "dff.sv"
`include "mux8to1.sv"

module ShiftRegister(Q, Clock, Clear, D, S, MSBIn, LSBIn);
output [7:0] Q;
input Clock;
input Clear;
input [7:0] D;
input [2:0] S;
input MSBIn;
input LSBIn;

logic [7:0] Qtemp;
genvar i, j;

Mux8to1 mx0 (Qtemp[0], {1'b0, Q[1], Q[7], Q[1], LSBIn, Q[1], D[0], Q[0]}, S);
generate
    for (i = 0; i < 6; i++)
        begin: mxd
            Mux8to1 mxg(Qtemp[i+1], {Q[i], Q[i+2], Q[i], Q[i+2], Q[i], Q[i+2], D[i+1], Q[i+1]}, S);
        end
endgenerate
Mux8to1 mx7 (Qtemp[7], {Q[6], Q[7], Q[6], Q[0], Q[6], MSBIn, D[7], Q[7]}, S);

generate
    for (j = 0; j < 8; j++)
        begin: dfd
          DFF df(Q[j], Clock, Clear, Qtemp[j]);
        end
endgenerate

endmodule