/*
 * Copyright (c) 2024 Your Name
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_7seg_snake
(
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

  reg [2:0]   head;     // Where the head of the snake is
  reg [2:0]   body;     // Where the body of the snake is
  reg [2:0]   tail;     // Where the body of the snake is
  reg         dp;
  reg         dir;      // 0 = clockwise, 1 = counter clockwise
  wire        move;     // 1'b1 when time for the snake to move 
  wire        move_bit;
  reg         move_p1;
  reg         move_p2;
  reg [25:0]  move_count; // Counter to tell when to move the snake
  reg [23:0]  lfsr;     // Or randomizer
  wire        tap;

  always @(posedge clk or negedge rst_n)
  begin
    if (!rst_n)
    begin
      head <= 3'h0;
      body <= 3'h5;
      tail <= 3'h4;
      dir  <= 1'b0;
      dp   <= 1'b0;
    end
    else
    begin
      if (move)
      begin
        // Make the body and tail follow 
        body <= head;
        tail <= body;

        case (dir)
        // Clockwise movement
        1'b0:
          begin
            case (head)
              // Top segment
              3'h0: head <= 3'h1;
              3'h1: head <= lfsr[0] ? 3'h2 : 3'h6;
              3'h2: head <= 3'h3;
              3'h4: head <= lfsr[0] ? 3'h5 : 3'h6;
              3'h5: head <= 3'h0;
              3'h6:
                begin
                  // Test for a change in direction
                  head <= lfsr[0] ? 3'h1 : 3'h2;
                  if (lfsr[0])
                    dir <= 1'b1;
                end
            endcase

            dp <= head == 3'h2 && lfsr[0];
          end

        // Counter-clockwise movement
        1'b1:
          begin
            case (head)
              3'h0: head <= 3'h5;
              3'h5: head <= lfsr[0] ? 3'h4 : 3'h6;
              3'h4: head <= 3'h3;
              3'h3: head <= lfsr[0] ? 3'h2 : 3'h6;
              3'h1: head <= 3'h0;
              3'h6:
                begin
                  // Test for a change in direction
                  head <= lfsr[0] ? 3'h5 : 3'h4;
                  if (lfsr[0])
                    dir <= 1'b0;
                end
            endcase

            dp <= head == 3'h3 && lfsr[0];
          end
        endcase
      end
    end
  end

  always @(posedge clk or negedge rst_n)
  begin
    if (!rst_n)
      lfsr <= 24'h1a037;
    else
      lfsr <= {lfsr[22:0], tap};
  end

  assign tap = lfsr[23] ^ lfsr[22] ^ lfsr[21] ^ lfsr[16];

  always @(posedge clk or negedge rst_n)
  begin
    if (!rst_n)
    begin
      move_count <= 26'h0;
      move_p1 <= 1'b0;
      move_p2 <= 1'b0;
    end
    else
    begin
      move_count <= move_count+1;
      move_p2 <= move_p1;
      move_p1 <= move_bit;
    end
  end

  assign move = move_p1 & !move_p2;

  always @*
  begin
    move_bit <= 1'b0;
    case (ui_in[3:0])
    4'h0:  move_bit <= move_count[25];
    4'h1:  move_bit <= move_count[24];
    4'h2:  move_bit <= move_count[23];
    4'h3:  move_bit <= move_count[22];
    4'h4:  move_bit <= move_count[21];
    4'h5:  move_bit <= move_count[20];
    4'h6:  move_bit <= move_count[19];
    4'h7:  move_bit <= move_count[18];
    4'h8:  move_bit <= move_count[17];
    4'h9:  move_bit <= move_count[16];
    4'ha:  move_bit <= move_count[15];
    4'hb:  move_bit <= move_count[14];
    4'hc:  move_bit <= move_count[13];
    4'hd:  move_bit <= move_count[12];
    4'he:  move_bit <= move_count[11];
    4'hf:  move_bit <= move_count[10];
    endcase
  end

  // All output pins must be assigned. If not used, assign to 0.
  assign uo_out[0] = head == 3'h0 || body == 3'h0 || tail == 3'h0;
  assign uo_out[1] = head == 3'h1 || body == 3'h1 || tail == 3'h1;
  assign uo_out[2] = head == 3'h2 || body == 3'h2 || tail == 3'h2;
  assign uo_out[3] = head == 3'h3 || body == 3'h3 || tail == 3'h3;
  assign uo_out[4] = head == 3'h4 || body == 3'h4 || tail == 3'h4;
  assign uo_out[5] = head == 3'h5 || body == 3'h5 || tail == 3'h5;
  assign uo_out[6] = head == 3'h6 || body == 3'h6 || tail == 3'h6;
  assign uo_out[7] = dp;
  assign uio_out = 0;
  assign uio_oe  = 0;

  // List all unused inputs to prevent warnings
  wire _unused = &{ena, 1'b0};

endmodule

// vim: et sw=2 ts=2
