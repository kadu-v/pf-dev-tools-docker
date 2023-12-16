//
// Copyright (c) 2023-present Didier Malenfant
//
// This file is part of openFPGA-Tutorials.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//

`default_nettype none

// -----------------------------------------------------------------------------------
// -- Linear Feedback Shift Register
module lfsr #(

    // -- Parameters
    parameter LEN = 8,                  // -- shift register length
    parameter TAPS = 8'b10111000) (     // -- XOR taps
    
    // -- Inputs
    input wire logic clock,             // -- clock
    input wire logic reset,             // -- reset if high
    input wire logic [LEN-1:0] seed,    // -- seed (uses default seed if zero)
    
    // -- Outputs
    output var logic [LEN-1:0] value);
    
    // -- Sequential part
    always_ff @(posedge clock) begin
        if (reset) begin
            value <= (seed != 0) ? seed : { LEN{1'b1} };
        end else begin
            value <= {1'b0, value[LEN-1:1]} ^ (value[0] ? TAPS : { LEN{1'b0} });
        end
    end

endmodule
