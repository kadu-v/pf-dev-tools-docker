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
// -- Starfield generator using LFSRs
module starfield #(

    // -- Parameters
    parameter WIDTH = 400,
    parameter HEIGHT = 512,
    parameter INC = -1,
    parameter SEED = 21'h1FFFFF,
    parameter MASK = 21'hFFF) (
    
    // -- Inputs
    input wire logic reset_n,                                   // -- reset on negative edge
    input wire logic pixel_clock,                               // -- pixel clock
    
    // -- Outputs
    output wire logic onoff,                                    // -- star on
    output wire logic [7:0] brightness);                        // -- star brightness
    
    // -- Local parameters
    localparam COUNTER_END = 21'(WIDTH * HEIGHT + INC - 1);     // -- counter starts at zero, so sub 1
    
    // -- Variables
    var logic [20:0] value, counter;
    
    // -- Combinatorial part
    assign onoff = &{value | MASK};                             // -- select some bits to form stars
    assign brightness = value[7:0];
    
    // -- Sequential part
    always_ff @(posedge pixel_clock) begin
        if(~reset_n) begin
            counter <= 0;
        end else begin
            counter <= counter + 21'd1;
    
            if (counter == COUNTER_END) begin
                counter <= 0;
            end
        end
    end
    
    // -----------------------------------------------------------------------------------
    // -- Modules
    
    lfsr #(
        // -- Parameters
        .LEN(21),
        .TAPS(21'b101000000000000000000)) lsfr_sf (
        
        // -- Inputs
        .clock(pixel_clock),
        .reset(counter == 21'b0),
        .seed(SEED),
        
        // -- Outputs
        .value(value)
    );

endmodule
