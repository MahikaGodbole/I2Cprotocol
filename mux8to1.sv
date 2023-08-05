module Mux8to1(Y, V, S);
output Y;
input [7:0] V;
input [2:0] S;

assign Y = V[S];

endmodule