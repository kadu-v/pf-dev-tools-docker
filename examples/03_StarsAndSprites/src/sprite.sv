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
// -- Hardware Sprite
module sprite #(

    // -- Parameters
    parameter WIDTH  = 8,                               // -- graphic width in pixels
    parameter HEIGHT = 8,                               // -- graphic height in pixels
    parameter SCALE_X = 1,                              // -- sprite width scale-factor
    parameter SCALE_Y = 1,                              // -- sprite height scale-factor
    parameter LSB= 1,                                   // -- first pixel in LSB
    parameter COORD_WIDTH = 16,                         // -- screen coordinate width in bits
    parameter ADDR_WIDTH = 9) (                         // -- width of graphic memory address bus
        
    // -- Inputs
    input wire logic reset_n,                           // -- reset on negative edge
    input wire logic pixel_clock,                       // -- pixel clock
    input wire logic start,                             // -- start control
    input wire logic dma_avail,                         // -- memory access control
    input wire logic signed [COORD_WIDTH-1:0] sx,       // -- horizontal screen position
    input wire logic signed [COORD_WIDTH-1:0] spr_x,    // -- horizontal sprite position
    input wire logic [WIDTH-1:0] data,                  // -- data from external memory
    
    // -- Outputs
    output var logic [ADDR_WIDTH-1:0] pos,              // -- sprite line position
    output wire logic pixel_on,                         // -- pixel draw enable (0 or 1)
    output wire logic drawing,                          // -- sprite is drawing
    output var logic done);                             // -- sprite drawing is complete
       
    // -- Local parameters
    localparam SCALE_X_WIDTH = (SCALE_X == 1) ? 1 : $clog2(SCALE_X); 
    localparam SCALE_Y_WIDTH = (SCALE_X == 1) ? 1 : $clog2(SCALE_X);
    localparam X_WIDTH = $clog2(WIDTH);
    localparam Y_WIDTH = $clog2(HEIGHT);
    
    // -- Variables
    var logic [WIDTH-1:0] spr_line;                     // -- local copy of sprite line
    
    var logic [X_WIDTH-1:0] ox;                         // -- position within sprite
    var logic [Y_WIDTH-1:0] oy;
    
    var logic [SCALE_X_WIDTH-1:0] cnt_x;                // -- scale counters
    var logic [SCALE_Y_WIDTH-1:0] cnt_y;
    
    var enum logic [3:0] {
        IDLE,       // -- awaiting start signal
        START,      // -- prepare for new sprite o_drawing
        AWAIT_DMA,  // -- await access to memory
        READ_MEM,   // -- read line of sprite from memory
        AWAIT_POS,  // -- await horizontal position
        DRAW,       // -- draw pixel
        NEXT_LINE,  // -- prepare for next sprite line
        DONE        // -- set done signal
    } state, state_next;

    // -- Signals
    wire logic last_pixel, load_line, last_line;        
    
    // -- Combinatorial part
    assign last_pixel = ({ 1'd0, ox } == WIDTH-1 && cnt_x == SCALE_X-1);    // -- create status signals
    assign last_line = ({ 1'd0, oy } == HEIGHT-1 && cnt_y == SCALE_Y-1);    
    assign load_line = (cnt_y == SCALE_Y-1);
    assign drawing = (state == DRAW);
    assign pixel_on = (state == DRAW) ? spr_line[ox] : 1'd0;                // -- output current pixel color when drawing
    
    always_comb begin
        // -- Determine next state
        case (state)
            IDLE:       state_next = start ? START : IDLE;
            START:      state_next = AWAIT_DMA;
            AWAIT_DMA:  state_next = dma_avail ? READ_MEM : AWAIT_DMA;
            READ_MEM:   state_next = AWAIT_POS;
            AWAIT_POS:  state_next = (sx == spr_x - 2) ? DRAW : AWAIT_POS;
            DRAW:       state_next = !last_pixel ? DRAW : (!last_line ? NEXT_LINE : DONE);
            NEXT_LINE:  state_next = load_line ? AWAIT_DMA : AWAIT_POS;
            DONE:       state_next = IDLE;
            default:    state_next = IDLE;
        endcase
    end
    
    // -- Sequential part
    always_ff @(posedge pixel_clock) begin
        if (~reset_n) begin
            state <= IDLE;
            ox <= 0;
            oy <= 0;
            cnt_x <= 0;
            cnt_y <= 0;
            spr_line <= 0;
            pos <= 0;
            done <= 0;
        end else begin
            // -- advance to next state
            state <= state_next;
    
            case (state)
                START: begin
                    done <= 0;
                    oy <= 0;
                    cnt_y <= 0;
                    pos <= 0;
                end
                READ_MEM: begin
                    if (LSB) begin
                        // -- assume read takes one clock cycle
                        spr_line <= data;
                    end else begin 
                        // -- reverse if MSB is left-most pixel
                        for (int i = 0; i < WIDTH; i = i + 1) begin
                            spr_line[i] <= data[(WIDTH-1) - i];
                        end
                    end
                end
                AWAIT_POS: begin
                    ox <= 0;
                    cnt_x <= 0;
                end
                DRAW: begin
                    if (SCALE_X <= 1 || cnt_x == SCALE_X-1) begin
                        ox <= ox + X_WIDTH'(1);
                        cnt_x <= 0;
                    end else begin
                        cnt_x <= cnt_x + SCALE_X_WIDTH'(1);
                    end
                end
                NEXT_LINE: begin
                    if (SCALE_Y <= 1 || cnt_y == SCALE_Y-1) begin
                        oy <= oy + Y_WIDTH'(1);
                        cnt_y <= 0;
                        pos <= pos + ADDR_WIDTH'(1);
                    end else begin
                        cnt_y <= cnt_y + SCALE_Y_WIDTH'(1);
                    end
                end
                DONE: begin
                    done <= 1;
                end
                default: begin
                end
            endcase
        end
    end

endmodule
