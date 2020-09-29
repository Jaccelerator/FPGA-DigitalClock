`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/12/31 20:50:15
// Design Name: 
// Module Name: Clock_display
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
module Clock_display(
    input clk_100MHz,
    input rst_time,
    input select,           //控制选择对秒分时的改变，三合一          
    input time_cnt,         //为1时对应时间+1                
    input change,           //change为1时表手动计时           
    output [3:0] L_sec,
    output [3:0] H_sec,
    output [3:0] L_min,
    output [3:0] H_min,
    output [3:0] L_hour,
    output [3:0] H_hour,
    output [1:0] select_time,      //以下用作显示模块中间数据交换
    output change_out
    );
    reg clk_1Hz = 1'b0;
    parameter time_N = 1_0000_0000;      //默认系统时钟频率100MHz，转化为1000Hz，需要除以十万
    reg [31:0] cnt;
    always @ (posedge clk_100MHz, negedge rst_time)
    begin
        if(!rst_time)
        begin
            cnt <= 0; 
            clk_1Hz <= 0;
        end
        else if(cnt == time_N/2 - 1)
        begin
            cnt <= 0;
            clk_1Hz <= ~clk_1Hz;
        end
        else
            cnt <= cnt + 1;
    end
    
    //中间变量分别表示自动计时与手动输入计时
    reg [3:0] L_sec_auto;
    reg [3:0] H_sec_auto;
    reg [3:0] L_min_auto;
    reg [3:0] H_min_auto;
    reg [3:0] L_hour_auto;
    reg [3:0] H_hour_auto;
    reg [3:0] L_sec_hand;
    reg [3:0] H_sec_hand;
    reg [3:0] L_min_hand;
    reg [3:0] H_min_hand;
    reg [3:0] L_hour_hand;
    reg [3:0] H_hour_hand;
    
    always @ (posedge clk_1Hz, negedge rst_time)//输出时钟写错了
    begin
        if(!rst_time)
        begin
            L_sec_auto <= 4'b0000;
            H_sec_auto <= 4'b0000;
            L_min_auto <= 4'b0000;
            H_min_auto <= 4'b0000;
            L_hour_auto <= 4'b0000;
            H_hour_auto <= 4'b0000;
        end
        else if(change == 0)
        begin
            //末状态恢复初始值
            if(L_sec_auto == 4'b1001 && H_sec_auto == 4'b0101 && L_min_auto == 4'b1001 && H_min_auto == 4'b0101 && L_hour_auto == 4'b0011 && H_hour_auto == 4'b0010)
            begin
                L_sec_auto <= 4'b0000;
                H_sec_auto <= 4'b0000;
                L_min_auto <= 4'b0000;
                H_min_auto <= 4'b0000;
                L_hour_auto <= 4'b0000;
                H_hour_auto <= 4'b0000;
            end
            else
            begin
                if(L_sec_auto == 9)
                begin
                    L_sec_auto <= 0;
                    if(H_sec_auto == 5)
                    begin
                        H_sec_auto <= 0;
                        if(L_min_auto == 9)
                        begin
                            L_min_auto <= 0;
                            if(H_min_auto == 5)
                            begin
                                H_min_auto <= 0;
                                if(L_hour_auto == 9)        //09时到10时
                                begin
                                    L_hour_auto <= 0;
                                    H_hour_auto <= H_hour_auto + 1;
                                end
                                else
                                    L_hour_auto <= L_hour_auto + 1;
                                end
                            else
                                H_min_auto <= H_min_auto + 1;
                            end
                        else
                            L_min_auto <= L_min_auto + 1;    
                        end
                    else
                        H_sec_auto <= H_sec_auto + 1;    
                    end
                else
                    L_sec_auto <= L_sec_auto + 1;
                end
            end
        else if(change == 1)        //从手动输入的值开始计算时间
        begin
            L_sec_auto <= L_sec_hand;
            H_sec_auto <= H_sec_hand;
            L_min_auto <= L_min_hand;
            H_min_auto <= H_min_hand;
            L_hour_auto <= L_hour_hand;
            H_hour_auto <= H_hour_hand;
        end
    end
    
    //调时间根据选择调节秒，分，时，且保证时分秒间无进位
    reg [1:0] select_time_reg;  //0表秒，1表分，2表时，设置时间时分别对应秒分时，会自动跳转到对应位置，且会自动增加，但不会进位，直到自己按按钮（感觉这里可以优化成加减，自行选择妙十分与按键防抖）
    always @ (posedge select, negedge rst_time)
    begin
        if(!rst_time)
            select_time_reg = 0;
        else if(select_time_reg == 2'b11)
            select_time_reg = 0;
        else
            select_time_reg = select_time_reg + 1;
    end
    assign change_out = change;
    assign select_time = change ? select_time_reg : 0; //没次改变时间后，再次改变不应该沿用之前的值，而是从0开始

    always @ (posedge time_cnt, negedge rst_time)
    begin
        if(!rst_time)
        begin
            L_sec_hand<= 4'b0000;
            H_sec_hand<= 4'b0000;
            L_min_hand<= 4'b0000;
            H_min_hand<= 4'b0000;
            L_hour_hand <= 4'b0000;
            H_hour_hand <= 4'b0000;
        end
        else if(change == 1)
        begin
            //清零
            if(L_sec_hand == 4'b1001 && L_sec_hand == 4'b0101 && L_min_hand == 4'b1001 && H_min_hand == 4'b0101 && L_hour_hand == 4'b0011 && H_hour_hand == 4'b0010)
            begin
                L_sec_hand <= 4'b0000;
                H_sec_hand <= 4'b0000;
                L_min_hand <= 4'b0000;
                H_min_hand <= 4'b0000;
                L_hour_hand <= 4'b0000;
                H_hour_hand <= 4'b0000;
            end
            else if({H_hour_hand,L_hour_hand} >= 35)  //24对应于0010_0100，十进制为36
                {H_hour_hand,L_hour_hand} <= 0;
            else
            begin
                if(select_time == 2'b00)        //改变秒
                begin
                    if(L_sec_hand == 9)
                    begin
                        L_sec_hand = 0;
                        if(H_sec_hand == 5)
                            H_sec_hand = 0;
                        else
                            H_sec_hand = H_sec_hand + 1;
                    end
                    else
                        L_sec_hand = L_sec_hand + 1;
                end
                else if(select_time == 2'b01)   //改变分
                begin
                    if(L_min_hand == 9)
                    begin
                        L_min_hand = 0;
                        if(H_min_hand == 5)
                            H_min_hand = 0;
                        else
                            H_min_hand = H_min_hand + 1;
                    end
                    else
                        L_min_hand = L_min_hand + 1;
                end
                else if(select_time == 2'b10)
                begin
                    if(L_hour_hand == 9)
                    begin
                        L_hour_hand = 0;
                        H_hour_hand = H_hour_hand + 1;
                    end
                    else
                        L_hour_hand = L_hour_hand + 1;
                end
            end
        end
    end
    
    //时间变化的周期为1s，在此基础上给输出赋值，自动手动选择其一即可，可以在assign
    assign L_sec = change ? L_sec_hand : L_sec_auto;
    assign H_sec = change ? H_sec_hand : H_sec_auto;
    assign L_min = change ? L_min_hand : L_min_auto;
    assign H_min = change ? H_min_hand : H_min_auto;
    assign L_hour = change ? L_hour_hand : L_hour_auto;
    assign H_hour = change ? H_hour_hand : H_hour_auto;
endmodule
