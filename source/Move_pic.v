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
    input rst_n,                    //vga��ʾ��Чѭ��
    input loc_rst,                  //�ߵ�ƽ��Ч����ƫ��λ���Ƶ��м�
    input VS_negedge,               //���ź��½���
    output reg [11:0] hpos,        //��x�᷽���ƫ�ƣ�1��ʾ������ؽӴ�
    output reg [11:0] vpos         //��y�᷽���ƫ�ƣ�1��ʾ���ϱ��ؽӴ�
);
//localparam 
parameter MOON_PIX_WIDTH = 135;  //�˶�ͼƬ�Ŀ��
parameter MOON_PIX_HEIGHT = 135; //�˶�ͼƬ�ĸ߶�

reg [1:0] state = 2'b11;    //00��01,10,11�ֱ��ʾͼƬ�����ϣ����£����ϣ������ƶ�
//����״̬ת��
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
            state <= (state + 1) % 4;     //����һ��0-3������ʾ����λ�ú��˶������п��� 
        end
        else
        begin
            case (state)
                2'b00://�������˶���ע�⳯��/��Ϊ��
                begin
                    hpos <= hpos - 1;
                    vpos <= vpos - 1;
                    //���������
                    if(hpos == 11'b1)      
                        state <= 2'b10;     //������
                    //�����±���
                    else if(vpos == 11'b1)      //ע����Ҫ��else��ʱ��ע���ǲ���ִ��
                        state <= 2'b01;     //������
                end
                2'b01://�������˶�
                begin
                    hpos <= hpos - 1;
                    vpos <= vpos + 1;
                    //���������
                    if(hpos == 11'b1)           
                        state <= 2'b11;     //������
                    //�����±���
                    else if(vpos + MOON_PIX_HEIGHT == 480)
                        state <= 2'b00;     //������
                end
                2'b10://�������˶�
                begin
                    hpos <= hpos + 1;
                    vpos <= vpos - 1;
                    //�����ұ���
                    if(hpos + MOON_PIX_WIDTH == 640)
                        state <= 2'b00;     //������
                    //�����ϱ���
                    else if(vpos == 11'b1)
                        state <= 2'b11;     //������
                end
                2'b11://�������˶�
                begin
                    hpos <= hpos + 1;
                    vpos <= vpos + 1;
                    //�����ұ���
                    if(hpos + MOON_PIX_WIDTH == 640)
                        state <= 2'b01;     //������
                    //�����±���
                    else if(vpos + MOON_PIX_HEIGHT == 480)
                        state <= 2'b10;     //������
                end
                default:            //����ȱʡ
                    state <= 2'b00;
            endcase
        end
    end
end

endmodule
