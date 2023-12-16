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
// -- handles putting all the screen elements togegther
module display (

    // -- Inputs
    input wire logic reset_n,           // -- reset on negative edge
    input wire logic pixel_clock,       // -- pixel clock
    
    // -- Outputs
    output var logic [23:0] video_rgb,  // -- pixel rgb value
    output var logic video_enable,      // -- video enable if high
    output var logic vsync_start,       // -- vsync if high
    output var logic hsync_start);      // -- hsync if high
    
    // -- Local parameters
    localparam COORD_WIDTH = 16;

    // -- With a ~12,288,000 hz pixel clock, we want our video mode of 400x360@50hz, this results in 245760 clocks per frame.
    // -- We need to add hblank and vblank times to this, so there will be a nondisplay area. It can be thought of as a border
    // -- around the visible area.
    //    
    // -- To make numbers simple, we can have 480 total clocks per line, and 400 visible. Dividing 204800 by 400 results in
    // -- 512 total lines per frame, and 400 visible. This pixel clock is fairly high for the relatively low resolution,
    // -- but that's fine. PLL output has a minimum output frequency anyway.
    
    localparam HORIZONTAL_TOTAL = 480;
    localparam VERTICAL_TOTAL = 512;

    localparam HORIZONTAL_RESOLUTION = 400;    
    localparam VERTICAL_RESOLUTION = 360;

    localparam SPRITES_Y_POSITION = 150;

    // -- Variables
    var logic signed [COORD_WIDTH-1:0] x, y;
    var logic [23:0] copper_rgb;

    // -- Signals
    wire logic [23:0] star_rgb;
    wire logic spr_pixel_on;

    // -- Combinational part
    always_comb begin
        // -- Inactive screen areas are black
        video_rgb = video_enable ? (spr_pixel_on ? copper_rgb : star_rgb) : { 8'd0, 8'd0, 8'd0 };
    end

    // -----------------------------------------------------------------------------------
    // -- Modules

    video_sync #(
        // -- Parameters
        .COORD_WIDTH(COORD_WIDTH),
        .HORIZONTAL_TOTAL(HORIZONTAL_TOTAL),
        .VERTICAL_TOTAL(VERTICAL_TOTAL),
        .HORIZONTAL_RESOLUTION(HORIZONTAL_RESOLUTION),
        .VERTICAL_RESOLUTION(VERTICAL_RESOLUTION),
        .HORIZONTAL_BACK_PORCH(10),
        .VERTICAL_BACK_PORCH(10)) vid (
        
        // -- Inputs
        .reset_n(reset_n),
        .pixel_clock(pixel_clock),
       
        // -- Outputs
        .x(x),
        .y(y),
        .video_enable(video_enable),
        .vsync_start(vsync_start),
        .hsync_start(hsync_start),
        /* verilator lint_off PINCONNECTEMPTY */
        .frame_count()
        /* verilator lint_on PINCONNECTEMPTY */
    );

    starfields #(
        // -- Parameters
        .WIDTH(HORIZONTAL_TOTAL),
        .HEIGHT(VERTICAL_TOTAL)) stars (
        
        // -- Inputs
        .reset_n(reset_n),
        
        // -- Outputs
        .pixel_clock(pixel_clock),
        .pixel_rgb(star_rgb)
    );

    copper #(
        // -- Parameters
        .COORD_WIDTH(COORD_WIDTH),
        .COLOR_A(24'h112255),
        .COLOR_B(24'h442211),
        .START_COLOR_A(SPRITES_Y_POSITION),
        .START_COLOR_B(SPRITES_Y_POSITION + 30),
        .LINE_INC(3)) cop (
        
        // -- Inputs
        .reset_n(reset_n),
        .hsync(hsync_start),
        .y(y),

        // -- Outputs
        .color_rgb(copper_rgb)
    );
    
    sprites #(
        // -- Parameters
        .COORD_WIDTH(COORD_WIDTH),
        .SPR_X(80),
        .SPR_Y(SPRITES_Y_POSITION)) sprs (
        
        // -- Inputs
        .reset_n(reset_n),
        .pixel_clock(pixel_clock),
        .hsync_start(hsync_start),
        .x(x),
        .y(y),

        // -- Outputs
        .pixel_on(spr_pixel_on)
    );

endmodule
