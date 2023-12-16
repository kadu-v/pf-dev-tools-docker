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
// -- Starfields
module starfields #(

    // -- Parameters
    parameter WIDTH = 400,
    parameter HEIGHT = 512) (

    // -- Inputs
    input wire logic reset_n,               // -- reset on negative edge
    input wire logic pixel_clock,           // -- pixel clock
    
    // -- Outputs
    output wire logic [23:0] pixel_rgb);    // -- pixel rgb value
    
    // -- Signald
    wire logic sf1_on, sf2_on, sf3_on;
    wire logic [7:0] sf1_star, sf2_star, sf3_star;
    wire logic [7:0] starlight;
    
    // -- Combinatorial part
    assign starlight = (sf1_on) ? sf1_star[7:0] :
                       (sf2_on) ? sf2_star[7:0] :
                       (sf3_on) ? sf3_star[7:0] : 8'h0;
    assign pixel_rgb = { starlight, starlight, starlight };
    
    // -----------------------------------------------------------------------------------
    // -- Modules
    
    starfield #(
        // -- Parameters
        .WIDTH(WIDTH),
        .HEIGHT(HEIGHT),
        .INC(-1),
        .SEED(21'h9A9A9)) sf1 (
        
        // -- Inputs
        .reset_n(reset_n),
        .pixel_clock(pixel_clock),
        
        // -- Outputs
        .onoff(sf1_on),
        .brightness(sf1_star)
    );

    starfield #(
        // -- Parameters
        .WIDTH(WIDTH),
        .HEIGHT(HEIGHT),
        .INC(-2),
        .SEED(21'hA9A9A)) sf2 (
        
        // -- Inputs
        .reset_n(reset_n),
        .pixel_clock(pixel_clock),
        
        // -- Outputs
        .onoff(sf2_on),
        .brightness(sf2_star)
    );
    
    starfield #(
        // -- Parameters
        .WIDTH(WIDTH),
        .HEIGHT(HEIGHT),
        .INC(-4),
        .MASK(21'h7FF)) sf3 (
        
        // -- Inputs
        .reset_n(reset_n),
        .pixel_clock(pixel_clock),
        
        // -- Outputs
        .onoff(sf3_on),
        .brightness(sf3_star)
    );

endmodule
