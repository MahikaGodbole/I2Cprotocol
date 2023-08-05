`timescale 1ns / 1ps

module top;

  
  logic Clock;
  logic Clear;
  logic [7:0] D;
  logic [2:0] S;
  logic MSBIn;
  logic LSBIn;

  
  logic [7:0] Q;

  
  bit [256:0] fib_array; 

  // Define enumerated type for Fibonacci results
  typedef enum bit { NOT_FIB, FIB } fib_t;

  // Function to compute Fibonacci sequence up to n bits
  function automatic void fibonacci(input integer n, output bit [256:0] fib_array);
    integer i;
    bit [256:0] fib;
    fib[0] = 1;
    fib[1] = 1;
    for (i = 2; i <= n; i++)
      fib[i] = fib[i-1] + fib[i-2];
    fib_array = fib;
  endfunction

  // Initialize fib_array with Fibonacci results up to 8 bits
  initial begin
    fibonacci(8, fib_array);
  end

  // ShiftRegister instantiation
  ShiftRegister sr(Q, Clock, Clear, D, S, MSBIn, LSBIn);

  // Clock generation
  always #5 Clock = ~Clock;

  // Test stimulus
  initial begin
    // Reset ShiftRegister
    Clear = 1;
    #10;
    Clear = 0;

    // Test shift left
    D = 8'b10101010;
    S = 3'b001;
    MSBIn = 0;
    LSBIn = 0;
    #20;

    // Test shift right
    S = 3'b010;
    MSBIn = 1;
    LSBIn = 1;
    #20;

    // Test load data
    D = 8'b11110000;
    S = 3'b000;
    #20;
    

 
    
    for (int i = 0; i < 256; i++) begin
      if (fib_array[i]) begin
        #5 $display("Fibonacci number detected in ShiftRegister: %d", i);
      end
    end

    #100 $finish;
  end

    initial begin
       $display("-----------------The Test Bench Begins-----------------");
      #200$display("-----------------The Test Bench Ends-----------------");
      #201$display("-----------------Author: Fardeen Wasey-----------------");
  end

endmodule