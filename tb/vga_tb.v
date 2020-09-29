`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/12/16 18:24:54
// Design Name: 
// Module Name: vga_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module vga_tb();
reg         clk;
reg         rst_n;
wire [3:0]  vga_r;
wire [3:0]  vga_g;
wire [3:0]  vga_b;
wire        Hsync_s;
wire        Vsync_s;

initial begin
    clk = 1'b0;
    rst_n = 1'b0;

    // Reset for 1us
    #100 
    rst_n = 1'b1;
end

// Generate 100MHz clock signal
always #1 clk <= ~clk;

VGA_top uut(
    .clk_100MHz(clk),
    .rst_n(rst_n),
    .vga_r   (vga_r),
    .vga_g   (vga_g),
    .vga_b   (vga_b),
    .Hsync_s (Hsync_s),
    .Vsync_s (Vsync_s)
);

endmodule
