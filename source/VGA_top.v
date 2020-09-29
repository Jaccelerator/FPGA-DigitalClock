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
    input rst_n,                    //vga��ʾ��Ч�ź�
    output Hsync_s,                 //��ͬ���ź�                      
    output Vsync_s,                 //��ͬ���ź� 
    output [3:0] vga_r,
    output [3:0] vga_g,
    output [3:0] vga_b,
    input loc_rst,          //ͼƬ�˶�ƫ�Ƶ�ʹ���ź�
    input rst_time,         //ʱ�临λ
    input select,           //����ѡ������ʱ�ĸı䣬����һ   //��������������ʾ
    input time_cnt,         //Ϊ1ʱ��Ӧʱ��+1//��Ϊλѡ�ź�
    input change,           //changeΪ1ʱ���ֶ���ʱoutput [7:0] bit_sel,
    output [7:0] bit_sel,
    //��Ϊ��ѡ�ź�
    output [6:0] seg_sel,
    inout DHT_DATA,             //�¶ȴ������ӿ�
    inout v2,                   //�����������ӿ�
    input rst_DHT,
    input rst_sound,
    input ena_sun               //ҹ��ģʽ��λ
);
wire disp_en;                   //��ʶ�Ƿ�����ʾ

wire [18:0] pix_data;
wire [11:0] xpos, ypos;
wire [11:0] hpos,vpos;

wire clk_25MHz;          //ƴд���⣿��ʹ��ʱ��һֱû��ȥ����ʱ���ź����
wire VS_negedge;        //��ʱ���½���
wire v2_show_en;        //������ʾ��Ч�ź�

//��ʵ�ַ�Ƶģ��
Divider divider(
    .clk_100MHz(clk_100MHz),
    .rst_n(rst_n),
    .clk_25MHz(clk_25MHz)
);

//VGA�г�ͬ��ʱ�򼰲���������
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

//ͼƬ��״̬ת��
Move_pic move_pic(
    .clk_25MHz(clk_25MHz),
    .VS_negedge(VS_negedge),
    .rst_n(rst_n),
    .loc_rst(loc_rst),
    .hpos(hpos),
    .vpos(vpos)
);

//��Ϊ�ֶ����Զ�ʱ����������
wire [3:0] L_sec;
wire [3:0] H_sec;
wire [3:0] L_min;
wire [3:0] H_min;
wire [3:0] L_hour;
wire [3:0] H_hour;    
//��Ϊ������ģ���м����ת�ƣ���Ҫ�����Ƿ��ֶ��޸�ʱ����ı��λ��
wire [1:0] select_time;
wire change_out;

//����ʱ��
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

//�߶��������ʾ
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

//��ʪ�ȴ�����
wire[39:0] HT_data;
DHT22_control dht_control(
    .clk_100MHz(clk_100MHz),
    .rst_DHT(rst_DHT),        
    .DHT_DATA(DHT_DATA),
    .HT_data(HT_data)
);

//����������
Sound_control sound_control(
    .v2_show_en(v2_show_en),
    .clk_100MHz(clk_100MHz),
    .rst_sound(rst_sound),            
    .v2(v2)
);

//VGAͼƬ/�ַ���������ʾ
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
