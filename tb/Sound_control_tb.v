`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/01/06 14:02:00
// Design Name: 
// Module Name: Sound_control_tb
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


module Sound_control_tb();
    wire v2;         
    reg clk_100MHz; 
    reg rst_sound;  
    wire v2_show_en;
    
    initial
    begin
        clk_100MHz = 0;
        rst_sound = 1;
    end
    
    always #1 clk_100MHz = ~clk_100MHz;
    
    initial
    begin
        force v2 = 1;
        #50;
        release v2;
        #50 force v2 = 1;
        #600;
        release v2;
        #50;
        rst_sound = 0;
        #50 force v2 = 1;
        #50 release v2;
    end
    
    Sound_control uut(
    .v2(v2),
    .clk_100MHz(clk_100MHz),
    .rst_sound(rst_sound),
    .v2_show_en(v2_show_en)
    );
endmodule
