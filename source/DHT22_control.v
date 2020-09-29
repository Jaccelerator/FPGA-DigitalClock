`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/12/31 22:20:12
// Design Name: 
// Module Name: DHT22_control
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

//�Դ���Ƶ��״̬������
module DHT22_control(
    input clk_100MHz,
    input rst_DHT,
    inout DHT_DATA,                 //�ӻ�����������˿�

    output reg [39:0] HT_data       //���������40λ����
);

reg [31:0] us_count;                //��¼1us��ʱ�����
reg [3:0] DHT_state;                //���״̬
reg [5:0] bit_count;                //�������λ��

reg DHT_DATA_reg;                   //��Ŷ�дDHT_DATA�ļĴ���
reg [39:0] HT_data_reg;             //��Ϊ����������ݵ��м����

reg flag;        //��ʶ��  1�Ƕ���0�Ǹ��裬���ɶ�״̬
assign DHT_DATA = flag ? DHT_DATA_reg : 1'bz;           //SDA����ͨ·�ź�
//13��״̬
parameter S0 = 0, S1 = 1, S2 = 2, S3 = 3, S4 = 4, S5 = 5, S6 = 6, S7 = 7, S8 = 8, S9 = 9, S10 = 10, S11 = 11, S12 = 12;

reg clk_1MHz;  
reg [7:0] cnt;
parameter N = 100;
initial
begin
    cnt <= 8'b0;
    clk_1MHz <= 1'b0;
end

always @ (posedge clk_100MHz,negedge rst_DHT)
begin
    if(!rst_DHT)
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

always @ (posedge clk_1MHz, negedge rst_DHT)
begin
    if(!rst_DHT)			//��λ�źţ�ȫ�����㣬�������ӻ��ӳ�̬��ʼ
    begin
        DHT_state <= 4'b0;
        us_count <= 32'b0;
        flag <= 0;
        DHT_DATA_reg <= 0;
        HT_data_reg <= 0;
        bit_count <= 0;
        HT_data <= 0;
    end
    else
    begin
        case(DHT_state)
            S0:
            begin
                if(us_count == 2000000) //��֤���ζ�ȡ����С���Ϊ2s
                begin
                    us_count <= 0;
                    DHT_state <= S1;
                end     
                else
                begin
                  HT_data_reg <= 0;
                  flag <= 1;
                  DHT_DATA_reg <= 1;
                  us_count <= us_count + 1;
                end
            end
            S1:
            begin
                if(us_count == 1000)   //��������������SDA(HT_data)����1ms��ֹͣд�����ݣ��ӻ���ʼ�����ź�
                begin
                    flag <= 0;	//ֹͣд��
                    us_count <= 0;
                    DHT_state <= S2;
                end
                else
                begin
                    DHT_DATA_reg <= 0;
                    us_count <= us_count + 1;
                end    
            end
            S2:
            begin
                if(us_count == 20)      //�����ͷ����ߣ����������������ã��ᱣ��20us�ߵ�ƽ
                begin
                    us_count <= 0;
                    DHT_state <= S3;
                end
                else
                begin
                    us_count <= us_count + 1;
                end
            end
            S3:
            begin
                if(DHT_DATA == 1)
                begin
                    DHT_state <= S3;   
                end
                else
                begin
                    DHT_state <= S4;	 //��֤�����ɹ��������� 	
                end
            end
            S4:
            begin
                if(DHT_DATA == 0)
                begin
                    DHT_state <= S4;
                end
                else
                begin
                    DHT_state <= S5;	//�ӻ��ɹ���������
                end
            end
            S5:
            begin
                if(DHT_DATA == 1)
                begin
                    DHT_state <= S5;
                end
                else
                begin  
                    DHT_state <= S6;//�ٳɹ���������
                end
            end
            S6: 
            begin
                if(DHT_DATA == 0)
                begin
                    DHT_state <= S6;	  //�������ݴ���һ��ʼ�ǵ͵�ƽ����ʱ����״̬
                end
                else
                begin
                    DHT_state <= S7;  //ֱ���ӻ������������źţ����������ߣ���ʼ�Ӵӻ��ж�����
                end
            end
            S7:
            begin
                if(DHT_DATA == 1)	 //��֤�������ݵ͵�ƽ����������ߵ�ƽ״̬
                begin
                    DHT_state <= S8;   
                end
            end
            S8: //���õ����ݶ�ȡ״̬	
            begin
                if(us_count == 50)   //��ʱ50us����������0��26~28us�ߵ�ƽ��������1��70us�ߵ�ƽ������ȡ�м���50us�鿴����״̬��
                begin
                    us_count <= 0;
                    DHT_state <= S9; 
                end           
                else 
                begin     
                    us_count <= us_count+1;
                    DHT_state <= S8;
                end
            end
            S9:
            begin
                if(DHT_DATA == 1)      //50us��ȥ�����߸ߵ�ƽ���λΪ1������Ϊ0
                begin
                    HT_data_reg[0] <= 1;
                end
                else
                begin
                    HT_data_reg[0] <= 0;
                end
                DHT_state <= S10;
                bit_count <= bit_count + 1;	//��¼��ȡλ��
                us_count <= 0;
            end
            S10:
            begin
                if(bit_count >= 40)
                begin
                    DHT_state <= S0;		//��ȡλ���ﵽ40������һ�����ݶ�ȡ���̣��ص���̬
                    bit_count <= 0;
                    if(HT_data_reg[39:32] + HT_data_reg[31:24] + HT_data_reg[23:16] + HT_data_reg[15:8] == HT_data_reg[7:0])        //����У�飬�ж϶�ȡ���ݵ���ȷ��
                        HT_data <= HT_data_reg;
                    else
                        HT_data <= HT_data;
                end
                else
                begin
                    HT_data_reg <= HT_data_reg << 1;	//���ڴ���������Ǹ�λ�ȳ������ÿ��ȡһλ����Ҫ������һλ
                    if(DHT_DATA == 1)	//������߻��Ǹߵ�ƽ������ȡ��λ����1
                        DHT_state <= S11;
                    else
                        DHT_state <= S12; 	//�͵�ƽ����ȡλ����0������������һ�����ݴ���ĵ͵�ƽ�׶�
                end
            end
            S11://������һλ����Ϊ1���������Ҫ��ʣ��ĸߵ�ƽʱ��������ٶȹ�����һ�����ݵ����ߵ͵�ƽ�׶Σ�����S11~S12
            begin
                if(DHT_DATA == 1)     
                begin
                    DHT_state <= S11; 
                end           
                else 
                begin     
                    DHT_state <= S12;
                end
            end
            S12://������һλ����Ϊ0�������ֻ��Ҫ�ѽ�����һ�����ݵ����ߵ͵�ƽ�׶Σ����ն��߶��ص�S8�ظ�ÿһλ�Ķ�ȡ����
            begin
                 if(DHT_DATA == 0)     
                 begin
                     DHT_state <= S12; 
                 end           
                 else 
                 begin     
                     DHT_state <= S8;
                 end  
            end  
            default:
            DHT_state <= S0;           
        endcase
    end
end
endmodule