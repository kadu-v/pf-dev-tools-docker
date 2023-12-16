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
// -- Video syncing signals generator
module video_sync #(

    // -- Parameters
    parameter COORD_WIDTH = 16,                         // -- screen coordinate width in bits

    parameter HORIZONTAL_TOTAL = 400,
    parameter VERTICAL_TOTAL = 512,

    parameter HORIZONTAL_RESOLUTION = 320,
    parameter VERTICAL_RESOLUTION = 240,

    parameter HORIZONTAL_BACK_PORCH = 15,
    parameter VERTICAL_BACK_PORCH = 15) (

    // -- Inputs
    input wire logic reset_n,                           // -- reset on negative edge
    input wire logic pixel_clock,                       // -- pixel clock
    
    // -- Outputs
    output var logic signed [COORD_WIDTH-1:0] x, y,
    output var logic [15:0] frame_count,

    output var logic video_enable,                      // -- video enable if high
    output var logic vsync_start,                       // -- vsync if high
    output var logic hsync_start);                      // -- hsync if high
    
    // -- Local parameters
    localparam signed HORIZONTAL_START = -HORIZONTAL_BACK_PORCH;
    localparam signed HORIZONTAL_END = HORIZONTAL_START + HORIZONTAL_TOTAL - 1;

    localparam signed VERTICAL_START = -VERTICAL_BACK_PORCH;
    localparam signed VERTICAL_END = VERTICAL_START + VERTICAL_TOTAL - 1;
    
    // -- Sequential part
    always_ff @(posedge pixel_clock) begin
        if (~reset_n) begin
            x <= HORIZONTAL_START;
            y <= VERTICAL_START;
    
            video_enable <= 0;
            vsync_start <= 0;
            hsync_start <= 0;
        end else begin
            video_enable <= 0;
            vsync_start <= 0;
            hsync_start <= 0;
            
            x <= x + 1'b1;
            if (x == HORIZONTAL_END) begin
                x <= HORIZONTAL_START;
    
                y <= y + 1'b1;
                if (y == VERTICAL_END) begin
                    y <= VERTICAL_START;
    
                    // -- generate Vsync signal in back porch
                    vsync_start <= 1;
    
                    // -- new frame
                    frame_count <= frame_count + 1'b1;
                end
            end else begin
                // -- generate HSync to occur a bit after VS, not on the same cycle
                if (x == (HORIZONTAL_START + 3)) begin
                    hsync_start <= 1;
                end
            end

            // -- generate active video
            if (x >= 0 && x < HORIZONTAL_RESOLUTION) begin
                if (y >= 0 && y < VERTICAL_RESOLUTION) begin
                    // -- video enable. this is the active region of the line
                    video_enable <= 1;
                end 
            end
        end
    end

endmodule
