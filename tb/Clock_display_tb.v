`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/01/06 13:16:51
// Design Name: 
// Module Name: Clock_display_tb
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


module Clock_display_tb();
   reg clk_100MHz;
   reg rst_time;
   reg select;           //控制选择对秒分时的改变，三合一          
   reg time_cnt;         //为1时对应时间+1                
   reg change;           //change为1时表手动计时           
   wire [3:0] L_sec;
   wire [3:0] H_sec;
   wire [3:0] L_min;
   wire [3:0] H_min;
   wire [3:0] L_hour;
   wire [3:0] H_hour;
   wire [1:0] select_time;      //以下用作显示模块中间数据交换
   wire change_out;
   
   initial
   begin
    clk_100MHz = 0;
    rst_time = 0;
    select = 0;
    time_cnt = 0;
    change = 0;
   end
   
   always #10 clk_100MHz = ~clk_100MHz;
   
   initial
   begin
        #50 rst_time = 1;
        #600 rst_time = 0;
        #50; 
        change = 1;
        select = 1;
        time_cnt = 1;
        #200; 
        change = 0;
        select = 0; 
   end
   
   Clock_display uut(
   .clk_100MHz(clk_100MHz),
   .rst_time(rst_time),
   .select(select),
   .time_cnt(time_cnt),
   .change(change),
   .L_sec(L_sec),
   .H_sec(H_sec),
   .L_min(L_min),
   .H_min(H_min),
   .L_hour(L_hour),
   .select_time(select_time),
   .change_out(change_out),
   .H_hour(H_hour)
   );
endmodule
