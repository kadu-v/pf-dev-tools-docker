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
// -- Synchronous ROM controller
module rom_sync #(

    // -- Parameters
    parameter WIDTH = 8,
    parameter DEPTH = 256,
    parameter INIT_FILE = "") (

    // -- Inputs
    input wire logic clock,
    input wire logic [$clog2(DEPTH)-1:0] addr,

    // -- Outputs
    output var logic [WIDTH-1:0] data);

    // -- Variables
    var logic [WIDTH-1:0] memory[DEPTH];

    // -- Initial part
    initial begin
        $readmemh(INIT_FILE, memory);
    end

    // -- Sequential part
    always_ff @(posedge clock) begin
        data <= memory[addr];
    end

endmodule
