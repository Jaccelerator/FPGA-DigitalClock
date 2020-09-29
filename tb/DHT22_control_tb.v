`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/01/06 10:22:07
// Design Name: 
// Module Name: DHT22_control_tb
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


module DHT22_control_tb();
    reg clk;         
    reg rst;                
    wire DHT_DATA;           
    wire [39:0] HT_data; 
    
    initial  clk = 0;
    always  #1 clk = ~clk; //生成时钟信号
    
    initial
    begin
        rst = 0;            //由于是模拟一次主机发送信号，从机接受信号，所以一开始忽略一开始2s的延时
        #50;
        rst = 1;
        force DHT_DATA = 0;
        #1000;
        release DHT_DATA;
        #1;
        force DHT_DATA = 1;
        #20;
        release DHT_DATA;
        #1;
        force DHT_DATA = 0;
        #80;
        release DHT_DATA;
        #1;
        force DHT_DATA = 1;
        #80;
        release DHT_DATA;   
        force DHT_DATA = 0;          //模拟从机发送1次数据
        #50;
        release DHT_DATA;
        #1;
        force DHT_DATA = 1;
        #50;
        release DHT_DATA;
    end
    
    DHT22_control uut(
        .clk_100MHz(clk),
        .rst_DHT(rst),
        .DHT_DATA(DHT_DATA),
        .HT_data(HT_data)
    );

endmodule

