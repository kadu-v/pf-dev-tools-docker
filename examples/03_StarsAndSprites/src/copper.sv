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
// -- Simple copper
module copper #(

    // -- Parameters
    parameter COORD_WIDTH = 16,                     // -- screen coordinate width in bits

    parameter COLOR_A = 24'h112255,                 // -- initial color A
    parameter COLOR_B = 24'h442211,                 // -- initial color B

    parameter START_COLOR_A = 0,                    // -- 1st line of color A
    parameter START_COLOR_B = 80,                   // -- 1st line of color B

    parameter LINE_INC = 2) (                       // -- lines of each color

    // -- Inputs
    input wire logic reset_n,                       // -- reset on negative edge
    input wire logic hsync,                         // -- horizontal sync if high
    input wire logic signed [COORD_WIDTH-1:0] y,    // -- current vertical screen position
    
    // -- Outputs
    output var logic [23:0] color_rgb);             // -- 24 bit color (8-bit per channel)
       
    // -- Local parameters
    localparam LINE_INC_WIDTH = $clog2(LINE_INC);
    
    // -- Variables
    var logic [LINE_INC_WIDTH-1:0] line_counter;

    // -- Sequential part
    always_ff @(posedge hsync) begin
        if (~reset_n) begin
            line_counter <= 0;
            
            color_rgb <= COLOR_A;
        end else begin
            if (y == START_COLOR_A) begin
                line_counter <= 0;
                
                color_rgb <= COLOR_A;
            end else if (y == START_COLOR_B) begin
                line_counter <= 0;
                
                color_rgb <= COLOR_B;
            end else begin
                line_counter <= line_counter + 1;

                if (line_counter == LINE_INC_WIDTH'(LINE_INC-1)) begin
                    line_counter <= 0;
                    
                    color_rgb <= color_rgb + 24'h111111;
                end
            end
        end
    end

endmodule
