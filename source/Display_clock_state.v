`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/12/31 20:49:35
// Design Name: 
// Module Name: Display_clock_state
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
//自带分频的数码管显示
module Display_clock_state(
    input clk_100MHz,
    input rst_time,
    input [3:0] L_sec,           
    input [3:0] H_sec,           
    input [3:0] L_min,           
    input [3:0] H_min,           
    input [3:0] L_hour,          
    input [3:0] H_hour,
    input [1:0] select_time,
    input change_out,
     //作为位选信号
    output reg [7:0] bit_sel,
    //作为段选信号
    output [6:0] seg_sel           
    );
    //10万分频
    reg clk_1000Hz;
    parameter fresh_N = 10_0000;      //默认系统时钟频率100MHz，转化为1000Hz，需要除以十万
    reg [23:0] count;
      //数码管刷新时钟
      always @ (posedge clk_100MHz, negedge rst_time)
      begin
          if(!rst_time)
          begin
              count <= 0; 
              clk_1000Hz <= 0;
          end
          else if(count == fresh_N/2 - 1)
          begin
              count <= 0;
              clk_1000Hz <= ~clk_1000Hz;
          end
          else
              count <= count + 1;
      end    
    
    
    //以七段数码管为测试对象输出
    reg [2:0] seg_count;    //用于数码管定位输出
    reg [3:0] num_disp;     //用于将输出统一
    parameter ZERO = 7'b1000000, ONE = 7'b1111001, TWO = 7'b0100100, THREE = 7'b0110000, FOUR = 7'b0011001,
                  FIVE = 7'b0010010, SIX = 7'b0000010, SEVEN = 7'b1111000, EIGHT = 7'b0000000, NINE = 7'b0010000;//数码管段选定义
    parameter bit_H_hour = 8'b11011111, bit_L_hour = 8'b11101111, bit_H_min = 8'b11110111, bit_L_min = 8'b11111011, bit_H_sec = 8'b11111101, bit_L_sec = 8'b11111110;
    //输出是状态机，进行状态转移，用的是自然编码
    parameter twinkle_second = 8'b1111_1100, twinkle_minute = 8'b1111_0011, twinkle_hour = 8'b1100_1111;
    reg [6:0] seg_sel_reg;
    reg [7:0] bit_sel_temp = 8'b1111_1111;
    
    reg [9:0] ms_count = 0;
    always @ (posedge clk_1000Hz)           //每400ms取反闪烁信号
    begin
        if(ms_count > 400)
        begin
            bit_sel_temp <= ~ bit_sel_temp;
            ms_count <= 0;
        end
        else
            ms_count <= ms_count + 1;
    end
    
    always @ (posedge clk_1000Hz,negedge rst_time)
    begin
        if(!rst_time)
        begin
            bit_sel <= 8'b11111111;
            seg_count <= 0;
            num_disp <= 0;
        end
        else
        begin    
            case(seg_count)
                3'b000: 
                begin
                    num_disp <= L_sec;
                    if(change_out && select_time == 0)
                        bit_sel <= bit_L_sec | bit_sel_temp;
                    else
                        bit_sel <= bit_L_sec;
                end
                3'b001:
                begin
                    num_disp <= H_sec;
                    if(change_out && select_time == 0)
                        bit_sel <= bit_H_sec | bit_sel_temp;
                    else
                        bit_sel <= bit_H_sec;                    
                end
                3'b010: 
                begin
                    num_disp <= L_min;
                    if(change_out && select_time == 1)
                        bit_sel <= bit_L_min | bit_sel_temp;
                    else
                        bit_sel <= bit_L_min;                    
                end
                3'b011: 
                begin
                    num_disp <= H_min;
                    if(change_out && select_time == 1)
                        bit_sel <= bit_H_min | bit_sel_temp;
                    else
                        bit_sel <= bit_H_min;                    
                end
                3'b100:
                begin
                    num_disp <= L_hour;   
                    if(change_out && select_time == 2)
                        bit_sel <= bit_L_hour | bit_sel_temp;
                    else
                        bit_sel <= bit_L_hour;                    
                end
                3'b101:
                begin
                    num_disp <= H_hour;
                    if(change_out && select_time == 2)
                        bit_sel <= bit_H_hour | bit_sel_temp;
                    else
                        bit_sel <= bit_H_hour;                           
                end
                default:
                    seg_count <= 0;
         endcase
         seg_count <= seg_count + 1;
         end
    end
    
    always @ (num_disp)
    begin
         case(num_disp)
            0 : seg_sel_reg <= ZERO;
            1 : seg_sel_reg <= ONE;
            2 : seg_sel_reg <= TWO;
            3 : seg_sel_reg <= THREE;
            4 : seg_sel_reg <= FOUR;
            5 : seg_sel_reg <= FIVE;
            6 : seg_sel_reg <= SIX;
            7 : seg_sel_reg <= SEVEN;
            8 : seg_sel_reg <= EIGHT;
            9 : seg_sel_reg <= NINE;
            default:
                seg_sel_reg <= ZERO;
         endcase    
    end
    
assign seg_sel = rst_time ? seg_sel_reg: 7'b1111111;
endmodule

