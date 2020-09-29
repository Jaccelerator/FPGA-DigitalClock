`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/12/17 21:56:29
// Design Name: 
// Module Name: Move_pic
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

module Move_pic(
    input clk_25MHz,
    input rst_n,                    //vga显示有效循环
    input loc_rst,                  //高电平有效，将偏移位置移到中间
    input VS_negedge,               //场信号下降沿
    output reg [11:0] hpos,        //沿x轴方向的偏移，1表示与左边沿接触
    output reg [11:0] vpos         //沿y轴方向的偏移，1表示与上边沿接触
);
//localparam 
parameter MOON_PIX_WIDTH = 135;  //运动图片的宽度
parameter MOON_PIX_HEIGHT = 135; //运动图片的高度

reg [1:0] state = 2'b11;    //00，01,10,11分别表示图片向左上，左下，右上，右下移动
//进行状态转移
always @ (posedge clk_25MHz, negedge rst_n)
begin
    if(!rst_n)
    begin
        state <= 2'b11;
        hpos <= 12'b0;
        vpos <= 12'b0;
    end
    else if (VS_negedge)
    begin
        if(loc_rst)
        begin
            hpos <= 253;
            vpos <= 173;
            state <= (state + 1) % 4;     //生成一个0-3数，表示重置位置后运动方向都有可能 
        end
        else
        begin
            case (state)
                2'b00://朝左上运动，注意朝右/下为正
                begin
                    hpos <= hpos - 1;
                    vpos <= vpos - 1;
                    //触碰左边沿
                    if(hpos == 11'b1)      
                        state <= 2'b10;     //朝右上
                    //触碰下边沿
                    else if(vpos == 11'b1)      //注意需要有else，时刻注意是并行执行
                        state <= 2'b01;     //朝左下
                end
                2'b01://朝左下运动
                begin
                    hpos <= hpos - 1;
                    vpos <= vpos + 1;
                    //触碰左边沿
                    if(hpos == 11'b1)           
                        state <= 2'b11;     //朝右下
                    //触碰下边沿
                    else if(vpos + MOON_PIX_HEIGHT == 480)
                        state <= 2'b00;     //朝左上
                end
                2'b10://朝右上运动
                begin
                    hpos <= hpos + 1;
                    vpos <= vpos - 1;
                    //触碰右边沿
                    if(hpos + MOON_PIX_WIDTH == 640)
                        state <= 2'b00;     //朝左上
                    //触碰上边沿
                    else if(vpos == 11'b1)
                        state <= 2'b11;     //朝右下
                end
                2'b11://朝右下运动
                begin
                    hpos <= hpos + 1;
                    vpos <= vpos + 1;
                    //触碰右边沿
                    if(hpos + MOON_PIX_WIDTH == 640)
                        state <= 2'b01;     //朝左下
                    //触碰下边沿
                    else if(vpos + MOON_PIX_HEIGHT == 480)
                        state <= 2'b10;     //朝右上
                end
                default:            //不可缺省
                    state <= 2'b00;
            endcase
        end
    end
end

endmodule
