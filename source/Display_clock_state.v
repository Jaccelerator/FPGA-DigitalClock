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
//�Դ���Ƶ���������ʾ
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
     //��Ϊλѡ�ź�
    output reg [7:0] bit_sel,
    //��Ϊ��ѡ�ź�
    output [6:0] seg_sel           
    );
    //10���Ƶ
    reg clk_1000Hz;
    parameter fresh_N = 10_0000;      //Ĭ��ϵͳʱ��Ƶ��100MHz��ת��Ϊ1000Hz����Ҫ����ʮ��
    reg [23:0] count;
      //�����ˢ��ʱ��
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
    
    
    //���߶������Ϊ���Զ������
    reg [2:0] seg_count;    //��������ܶ�λ���
    reg [3:0] num_disp;     //���ڽ����ͳһ
    parameter ZERO = 7'b1000000, ONE = 7'b1111001, TWO = 7'b0100100, THREE = 7'b0110000, FOUR = 7'b0011001,
                  FIVE = 7'b0010010, SIX = 7'b0000010, SEVEN = 7'b1111000, EIGHT = 7'b0000000, NINE = 7'b0010000;//����ܶ�ѡ����
    parameter bit_H_hour = 8'b11011111, bit_L_hour = 8'b11101111, bit_H_min = 8'b11110111, bit_L_min = 8'b11111011, bit_H_sec = 8'b11111101, bit_L_sec = 8'b11111110;
    //�����״̬��������״̬ת�ƣ��õ�����Ȼ����
    parameter twinkle_second = 8'b1111_1100, twinkle_minute = 8'b1111_0011, twinkle_hour = 8'b1100_1111;
    reg [6:0] seg_sel_reg;
    reg [7:0] bit_sel_temp = 8'b1111_1111;
    
    reg [9:0] ms_count = 0;
    always @ (posedge clk_1000Hz)           //ÿ400msȡ����˸�ź�
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

