`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/12/14 19:33:45
// Design Name: 
// Module Name: VGA_top
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
module VGA_top(
    input clk_100MHz,
    input rst_n,                    //vga显示有效信号
    output Hsync_s,                 //行同步信号                      
    output Vsync_s,                 //场同步信号 
    output [3:0] vga_r,
    output [3:0] vga_g,
    output [3:0] vga_b,
    input loc_rst,          //图片运动偏移的使能信号
    input rst_time,         //时间复位
    input select,           //控制选择对秒分时的改变，三合一   //输出到数码管上显示
    input time_cnt,         //为1时对应时间+1//作为位选信号
    input change,           //change为1时表手动计时output [7:0] bit_sel,
    output [7:0] bit_sel,
    //作为段选信号
    output [6:0] seg_sel,
    inout DHT_DATA,             //温度传感器接口
    inout v2,                   //声音传感器接口
    input rst_DHT,
    input rst_sound,
    input ena_sun               //夜间模式复位
);
wire disp_en;                   //标识是否能显示

wire [18:0] pix_data;
wire [11:0] xpos, ypos;
wire [11:0] hpos,vpos;

wire clk_25MHz;          //拼写问题？？使得时序一直没进去，无时钟信号输出
wire VS_negedge;        //场时序下降沿
wire v2_show_en;        //声音显示有效信号

//自实现分频模块
Divider divider(
    .clk_100MHz(clk_100MHz),
    .rst_n(rst_n),
    .clk_25MHz(clk_25MHz)
);

//VGA行场同步时序及并传出坐标
VGA_sync sync(
    .clk_25MHz(clk_25MHz),
    .rst_n(rst_n),
    .Hsync_s(Hsync_s),
    .Vsync_s(Vsync_s),
    .disp_en(disp_en),
    .H_count(xpos),
    .V_count(ypos),
    .VS_negedge(VS_negedge)
);

//图片的状态转移
Move_pic move_pic(
    .clk_25MHz(clk_25MHz),
    .VS_negedge(VS_negedge),
    .rst_n(rst_n),
    .loc_rst(loc_rst),
    .hpos(hpos),
    .vpos(vpos)
);

//作为手动与自动时间的最终输出
wire [3:0] L_sec;
wire [3:0] H_sec;
wire [3:0] L_min;
wire [3:0] H_min;
wire [3:0] L_hour;
wire [3:0] H_hour;    
//作为数字钟模块中间变量转移，需要传递是否手动修改时间与改变的位置
wire [1:0] select_time;
wire change_out;

//计算时间
Clock_display clock_display(
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
   .H_hour(H_hour),
   .select_time(select_time),
   .change_out(change_out)     
);

//七段数码管显示
Display_clock_state display_clock_state(
    .clk_100MHz(clk_100MHz),   
    .rst_time(rst_time),
    .L_sec(L_sec),  
    .H_sec(H_sec),  
    .L_min(L_min),  
    .H_min(H_min),  
    .L_hour(L_hour),
    .H_hour(H_hour),
    .bit_sel(bit_sel),
    .seg_sel(seg_sel),
    .select_time(select_time),
    .change_out(change_out)                     
);

//温湿度传感器
wire[39:0] HT_data;
DHT22_control dht_control(
    .clk_100MHz(clk_100MHz),
    .rst_DHT(rst_DHT),        
    .DHT_DATA(DHT_DATA),
    .HT_data(HT_data)
);

//声音传感器
Sound_control sound_control(
    .v2_show_en(v2_show_en),
    .clk_100MHz(clk_100MHz),
    .rst_sound(rst_sound),            
    .v2(v2)
);

//VGA图片/字符的整体显示
VGA_disp disp(
    .clk_25MHz(clk_25MHz),
    .rst_n(rst_n),
    .ena_sun(ena_sun),
    .disp_en(disp_en),
    .xpos(xpos),
    .ypos(ypos),
    .hpos(hpos),
    .vpos(vpos),
    .L_sec(L_sec),  
    .H_sec(H_sec),  
    .L_min(L_min),  
    .H_min(H_min),  
    .L_hour(L_hour),
    .H_hour(H_hour),
    .HT_data(HT_data),
    .v2_show_en(v2_show_en),
    .vga_r(vga_r),
    .vga_g(vga_g),
    .vga_b(vga_b)
    );
endmodule
