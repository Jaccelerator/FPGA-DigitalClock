`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/01/03 21:07:04
// Design Name: 
// Module Name: Sound_control
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
module Sound_control(
    inout v2,           //声音传感器数据通路
    input clk_100MHz,   //系统时钟
    input rst_sound,        //复位信号，否则声音传感器不工作，设置与数字钟的复位信号相同
    output v2_show_en      //检测到声音显示
    );
    //自带分频记录延时
    reg clk_1MHz;  //每个计数代表1us
    reg [7:0] cnt;
    parameter N = 100;
    initial
    begin
        cnt <= 8'b0;
        clk_1MHz <= 1'b0;
    end
    always @ (posedge clk_100MHz,negedge rst_sound)
    begin
        if(!rst_sound)
        begin
            cnt <= 8'b0;
            clk_1MHz <= 1'b0;
        end
        else if(cnt == N/2 -1)
        begin
            cnt <= 8'b0;
            clk_1MHz <= ~clk_1MHz;
        end
        else
            cnt <= cnt + 1'b1;
    end
    
    reg [1:0] state_sound;
    reg [31:0] us_count;
    reg temp_reg = 0;
    parameter S0 = 0, S1 = 1, S2 = 2;
    
    always @ (posedge clk_1MHz, negedge rst_sound)
    begin
        if(!rst_sound)
        begin
            state_sound <= S0;
            us_count <= 0;
            temp_reg <= 0;
        end
        else
        begin
           case(state_sound)
               S0:
               begin
                   if(v2 == 1)
                   begin
                       if(us_count >= 50_0000)      //检测到持续的声音0.5s
                       begin
                           state_sound <= S1;
                           temp_reg <= 1;
                           us_count <= 0;
                       end
                       else
                       begin
                            temp_reg <= 0;
                            us_count <= us_count + 1;
                       end
                   end
                   else
                   begin
                       state_sound <= S0;
                       temp_reg <= 0; 
                   end
               end
               S1:
               begin
                   if(us_count >= 2000_0000)        //数组大小要合适，尽可能大
                   begin
                       state_sound <= S2;
                       us_count <= 0;
                       temp_reg <= 0;
                   end
                   else
                   begin
                       us_count <= us_count + 1;
                       state_sound <= S1;
                       temp_reg <= 1;
                   end
               end
               S2:
               begin
                   if(v2 == 1)
                       state_sound <= S1;
                   else
                       state_sound <= S0;
               end
               default:
               begin
                   state_sound <= S0;
                   us_count <= 0;
               end
           endcase
        end
    end
    
    assign v2_show_en = rst_sound ? temp_reg : 1;       //无效时始终传出1
endmodule
