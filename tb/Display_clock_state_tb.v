`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/01/06 13:44:20
// Design Name: 
// Module Name: Display_clock_state_tb
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


module Display_clock_state_tb();
    reg clk_100MHz;
    reg rst_time;
    reg [3:0] L_sec;           
    reg [3:0] H_sec;           
    reg [3:0] L_min;           
    reg [3:0] H_min;           
    reg [3:0] L_hour;          
    reg [3:0] H_hour;
    reg [1:0] select_time;
    reg change_out;
 //作为位选信号
    wire [7:0] bit_sel;
//作为段选信号
    wire [6:0] seg_sel;
    
    initial
    begin
        clk_100MHz = 0;
        rst_time = 0;
        L_sec = 8;
        H_sec = 5;
        L_min = 9;
        H_min = 5;
        L_hour = 3;
        H_hour = 2;
        select_time = 0;
        change_out = 0;
    end
    
    always #1 clk_100MHz = ~clk_100MHz;
    
    initial
    begin
        #100;
        rst_time = 1;
        #100;
        rst_time = 0;
        select_time = 2;
        change_out = 1;
    end
    
    Display_clock_state uut(
    .clk_100MHz(clk_100MHz),
    .rst_time(rst_time),
    .L_sec(L_sec),
    .H_sec(H_sec),
    .L_min(L_min),
    .H_min(H_min),
    .L_hour(L_hour),
    .H_hour(H_hour),
    .select_time(select_time),
    .change_out(change_out),
    .bit_sel(bit_sel),
    .seg_sel(seg_sel)
    );
endmodule
