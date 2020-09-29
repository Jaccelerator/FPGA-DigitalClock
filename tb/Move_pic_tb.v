`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/01/06 13:01:06
// Design Name: 
// Module Name: Move_pic_tb
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


module Move_pic_tb();
    reg clk_25MHz;       
    reg rst_n;           
    reg loc_rst;         
    reg VS_negedge;      
    wire [11:0] hpos;
    wire [11:0] vpos; 

initial
begin
    clk_25MHz = 0;
    rst_n = 0;
    loc_rst = 0;
    VS_negedge = 0;
end

always #10 clk_25MHz = ~clk_25MHz;

initial
begin
    #50 rst_n = 1;
    #50 VS_negedge = 1;
    #50 VS_negedge = 0;
    #50 loc_rst = 1;
end

Move_pic uut(
.clk_25MHz(clk_25MHz),          
.rst_n(rst_n),         
.loc_rst(loc_rst),       
.VS_negedge(VS_negedge),     
.hpos(hpos),   
.vpos(vpos)   
 );       
endmodule
