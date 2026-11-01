`timescale 1ns / 1ps

module tb_sobel;

    reg [7:0] img_memory [0:16383];
    reg [7:0] out_memory [0:16383];
    
    reg [7:0] p00, p01, p02;
    reg [7:0] p10, p11, p12;
    reg [7:0] p20, p21, p22;
    wire [7:0] edge_out;
    
    sobel_filter uut (
        .p00(p00), .p01(p01), .p02(p02),
        .p10(p10), .p11(p11), .p12(p12),
        .p20(p20), .p21(p21), .p22(p22),
        .edge_out(edge_out)
    );
    
    integer x, y, i;
    integer output_file;
    
    initial begin
        $readmemh("../../../../../input_hex.txt", img_memory);
        
        for (i = 0; i < 16384; i = i + 1) begin
            out_memory[i] = 8'h00;
        end
        
        #10;
        
        for (y = 1; y < 127; y = y + 1) begin
            for (x = 1; x < 127; x = x + 1) begin
                
                p00 = img_memory[(y-1)*128 + (x-1)];
                p01 = img_memory[(y-1)*128 + x];
                p02 = img_memory[(y-1)*128 + (x+1)];
                
                p10 = img_memory[y*128 + (x-1)];
                p11 = img_memory[y*128 + x];
                p12 = img_memory[y*128 + (x+1)];
                
                p20 = img_memory[(y+1)*128 + (x-1)];
                p21 = img_memory[(y+1)*128 + x];
                p22 = img_memory[(y+1)*128 + (x+1)];
                
                #5; 
                
                out_memory[y*128 + x] = edge_out;
            end
        end
        
        output_file = $fopen("../../../../../output_sim_hex.txt", "w");
        for (i = 0; i < 16384; i = i + 1) begin
            $fwrite(output_file, "%02x\n", out_memory[i]);
        end
        $fclose(output_file);
        
        $display("Simulation successfully completed! Data saved to main folder.");
        $finish;
    end

endmodule