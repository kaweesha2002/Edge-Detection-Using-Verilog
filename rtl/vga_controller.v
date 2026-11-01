`timescale 1ns / 1ps

module vga_controller (
    input wire clk_25MHz,
    input wire reset,
    output reg hsync,
    output reg vsync,
    output wire video_on,
    output wire [9:0] x_loc,
    output wire [9:0] y_loc
);
    // 640x480 @ 60Hz Timing Parameters
    parameter H_DISPLAY = 640;
    parameter H_FRONT   = 16;
    parameter H_SYNC    = 96;
    parameter H_BACK    = 48;
    parameter H_TOTAL   = 800;

    parameter V_DISPLAY = 480;
    parameter V_FRONT   = 10;
    parameter V_SYNC    = 2;
    parameter V_BACK    = 33;
    parameter V_TOTAL   = 525;

    reg [9:0] h_count = 0;
    reg [9:0] v_count = 0;

    // Horizontal Pixel Counter
    always @(posedge clk_25MHz or posedge reset) begin
        if (reset)
            h_count <= 0;
        else if (h_count == H_TOTAL - 1)
            h_count <= 0;
        else
            h_count <= h_count + 1;
    end

    // Vertical Line Counter
    always @(posedge clk_25MHz or posedge reset) begin
        if (reset)
            v_count <= 0;
        else if (h_count == H_TOTAL - 1) begin
            if (v_count == V_TOTAL - 1)
                v_count <= 0;
            else
                v_count <= v_count + 1;
        end
    end

    // Active-Low Sync Signals
    always @(posedge clk_25MHz) begin
        hsync <= ~((h_count >= H_DISPLAY + H_FRONT) && (h_count < H_DISPLAY + H_FRONT + H_SYNC));
        vsync <= ~((v_count >= V_DISPLAY + V_FRONT) && (v_count < V_DISPLAY + V_FRONT + V_SYNC));
    end

    // Active Display Region Flag and Coordinates
    assign video_on = (h_count < H_DISPLAY) && (v_count < V_DISPLAY);
    assign x_loc    = h_count;
    assign y_loc    = v_count;

endmodule