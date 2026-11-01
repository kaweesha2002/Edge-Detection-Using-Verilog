`timescale 1ns / 1ps

module top_basys3 (
    input wire clk_100MHz,
    input wire reset,
    output wire hsync,
    output wire vsync,
    output wire [3:0] vgaRed,
    output wire [3:0] vgaGreen,
    output wire [3:0] vgaBlue
);

    // Clock Divider 
    //100 MHz-> 25 MHz 
    reg [1:0] clk_div = 0;
    always @(posedge clk_100MHz or posedge reset) begin
        if (reset) clk_div <= 0;
        else clk_div <= clk_div + 1;
    end
    wire clk_25MHz = clk_div[1];

    wire video_on;
    wire [9:0] x_loc;
    wire [9:0] y_loc;

    vga_controller vga_inst (
        .clk_25MHz(clk_25MHz),
        .reset(reset),
        .hsync(hsync),
        .vsync(vsync),
        .video_on(video_on),
        .x_loc(x_loc),
        .y_loc(y_loc)
    );

    reg [7:0] image_bram [0:16383];

    initial begin
        $readmemh("output_sim_hex.txt", image_bram);
    end

  
    wire in_image_box = (x_loc >= 256 && x_loc < 384) && 
                               (y_loc >= 176 && y_loc < 304);

    wire [6:0] img_x = x_loc - 256;
    wire [6:0] img_y = y_loc - 176;
    wire [13:0] ram_addr = (img_y * 128) + img_x;

    reg [7:0] pixel_val;
    always @(posedge clk_25MHz) begin
        if (in_image_box)
            pixel_val <= image_bram[ram_addr];
        else
            pixel_val <= 8'h00; // Black background outside box
    end

    wire [3:0] gray_4bit = pixel_val[7:4];

    assign vgaRed   = (video_on && in_image_box) ? gray_4bit : 4'h0;
    assign vgaGreen = (video_on && in_image_box) ? gray_4bit : 4'h0;
    assign vgaBlue  = (video_on && in_image_box) ? gray_4bit : 4'h0;

endmodule