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
    input select,           //����ѡ������ʱ�ĸı䣬����һ          
    input time_cnt,         //Ϊ1ʱ��Ӧʱ��+1                
    input change,           //changeΪ1ʱ���ֶ���ʱ           
    output [3:0] L_sec,
    output [3:0] H_sec,
    output [3:0] L_min,
    output [3:0] H_min,
    output [3:0] L_hour,
    output [3:0] H_hour,
    output [1:0] select_time,      //����������ʾģ���м����ݽ���
    output change_out
    );
    reg clk_1Hz = 1'b0;
    parameter time_N = 1_0000_0000;      //Ĭ��ϵͳʱ��Ƶ��100MHz��ת��Ϊ1000Hz����Ҫ����ʮ��
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
    
    //�м�����ֱ��ʾ�Զ���ʱ���ֶ������ʱ
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
    
    always @ (posedge clk_1Hz, negedge rst_time)//���ʱ��д����
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
            //ĩ״̬�ָ���ʼֵ
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
                                if(L_hour_auto == 9)        //09ʱ��10ʱ
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
        else if(change == 1)        //���ֶ������ֵ��ʼ����ʱ��
        begin
            L_sec_auto <= L_sec_hand;
            H_sec_auto <= H_sec_hand;
            L_min_auto <= L_min_hand;
            H_min_auto <= H_min_hand;
            L_hour_auto <= L_hour_hand;
            H_hour_auto <= H_hour_hand;
        end
    end
    
    //��ʱ�����ѡ������룬�֣�ʱ���ұ�֤ʱ������޽�λ
    reg [1:0] select_time_reg;  //0���룬1��֣�2��ʱ������ʱ��ʱ�ֱ��Ӧ���ʱ�����Զ���ת����Ӧλ�ã��һ��Զ����ӣ��������λ��ֱ���Լ�����ť���о���������Ż��ɼӼ�������ѡ����ʮ���밴��������
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
    assign select_time = change ? select_time_reg : 0; //û�θı�ʱ����ٴθı䲻Ӧ������֮ǰ��ֵ�����Ǵ�0��ʼ

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
            //����
            if(L_sec_hand == 4'b1001 && L_sec_hand == 4'b0101 && L_min_hand == 4'b1001 && H_min_hand == 4'b0101 && L_hour_hand == 4'b0011 && H_hour_hand == 4'b0010)
            begin
                L_sec_hand <= 4'b0000;
                H_sec_hand <= 4'b0000;
                L_min_hand <= 4'b0000;
                H_min_hand <= 4'b0000;
                L_hour_hand <= 4'b0000;
                H_hour_hand <= 4'b0000;
            end
            else if({H_hour_hand,L_hour_hand} >= 35)  //24��Ӧ��0010_0100��ʮ����Ϊ36
                {H_hour_hand,L_hour_hand} <= 0;
            else
            begin
                if(select_time == 2'b00)        //�ı���
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
                else if(select_time == 2'b01)   //�ı��
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
    
    //ʱ��仯������Ϊ1s���ڴ˻����ϸ������ֵ���Զ��ֶ�ѡ����һ���ɣ�������assign
    assign L_sec = change ? L_sec_hand : L_sec_auto;
    assign H_sec = change ? H_sec_hand : H_sec_auto;
    assign L_min = change ? L_min_hand : L_min_auto;
    assign H_min = change ? H_min_hand : H_min_auto;
    assign L_hour = change ? L_hour_hand : L_hour_auto;
    assign H_hour = change ? H_hour_hand : H_hour_auto;
endmodule
