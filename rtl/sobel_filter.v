`timescale 1ns / 1ps

module sobel_filter(
    input [7:0] p00, input [7:0] p01, input [7:0] p02,
    input [7:0] p10, input [7:0] p11, input [7:0] p12,
    input [7:0] p20, input [7:0] p21, input [7:0] p22,
    output reg [7:0] edge_out
);

    integer gx;
    integer gy;
    integer abs_gx;
    integer abs_gy;
    integer magnitude;

    always @(*) begin
        gx = (p02 + (2 * p12) + p22) - (p00 + (2 * p10) + p20);
        gy = (p20 + (2 * p21) + p22) - (p00 + (2 * p01) + p02);
        
        if (gx < 0) 
            abs_gx = -gx;
        else 
            abs_gx = gx;
            
        if (gy < 0) 
            abs_gy = -gy;
        else 
            abs_gy = gy;
        
        magnitude = abs_gx + abs_gy;
        
        if (magnitude > 255) begin
            edge_out = 8'hFF;
        end else begin
            edge_out = magnitude[7:0];
        end
    end

endmodule