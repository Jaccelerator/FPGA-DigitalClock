`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/12/14 19:35:55
// Design Name: 
// Module Name: VGA_driver
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
module VGA_sync(
    input clk_25MHz,                //VGAʱ��
    input rst_n,                    //VGA��λ�ź�
    output Hsync_s,                 //��ͬ���ź�                      
    output Vsync_s,                 //��ͬ���ź� 
    output disp_en,                 //��ʾ��Ч�ź�
    output reg [11:0] H_count, //�м�������ˮƽ����                              
    output reg [11:0] V_count,//�м���������ֱ����  
    output VS_negedge           //������ź��½���
);

parameter H_Total = 800;           //��������                       
parameter H_Sync = 96;             //��ͬ�����壨Sync a��              
parameter H_Back = 48;             //��ʾ���أ�Back porch b��         
parameter H_Disp = 640;            //��ʾʱ��Σ�Display interval c��  
parameter H_Front = 16;            //��ʾǰ�أ�Front porch d��        
parameter H_Start = 144;           //��ͬ��+��ʾ���أ�������ʾ���иտ�ʼ�����ص�     
parameter H_End = 784;             //��ͬ������-��ʾǰ�أ�������ʾ������Ҫ����������   


// ��ֱɨ��������趨640*480 VGA
parameter V_Total = 525;          //��������               
parameter V_Sync = 2;             //��ͬ�����壨Sync o��      
parameter V_Back = 33;            //��ʾ���أ�Back porch p�� 
parameter V_Disp = 480;           //��ʾʱ��Σ�Display inter
parameter V_Front = 11;           //��ʾǰ�أ�Front porch r��
parameter V_Start = 35;           //����ʾ���иտ�ʼ�����ص�       
parameter V_End = 514;            //����ʾ���иս��������ص�

//�ڲ��źŶ���                                                     
                            
reg H_Sync_r;            //������Ϊ�˿���/���ź��������ʱ����     
reg V_Sync_r; 

reg VS_reg1, VS_reg2;       //���ź���1->0ʱ�����½���ʱ�Ž���״̬ת�ơ�ÿһ֡���½��أ�ͼƬ��������һ֡һ֡���˶������������˶��γɶ���

// ˮƽɨ�����
always @ (posedge clk_25MHz ,negedge rst_n)
       if(!rst_n)    
            H_count <= 0;
       else if(H_count == H_Total - 1) 
            H_count <= 0;
       else 
            H_count <= H_count + 1;

// ˮƽɨ���ź�hsync,H_Sync_valid����
always @ (posedge clk_25MHz, negedge rst_n)
   begin
       if(!rst_n) 
            H_Sync_r <= 1'b1;
       else if(H_count == 0) 
            H_Sync_r <= 1'b0;            //����hsync�ź�
       else if(H_count == H_Sync - 1) 
            H_Sync_r <= 1'b1;
	end
	
// ��ֱɨ�����
always @ (posedge clk_25MHz,negedge rst_n)
       if(!rst_n) 
            V_count <= 0;
       else if(V_count == V_Total - 1) 
            V_count <= 0;
       else if(H_count == H_Total - 1) 
            V_count <= V_count + 1;
       
// ��ֱɨ���ź�vsync, V_Sync_valid����
always @ (posedge clk_25MHz,negedge rst_n)
  begin
       if(!rst_n) 
            V_Sync_r <= 1'b1;
       else if(V_count == 0) 
            V_Sync_r <= 1'b0;    //����vsync�ź�
       else if(V_count == V_Sync - 1) 
            V_Sync_r <= 1'b1;
  end
                                 
  //�����Ƿ�Ϊ��ʱ���½���
  always @ (posedge clk_25MHz, negedge rst_n)
  begin
      if(!rst_n)
      begin
          VS_reg1 <= 0;
          VS_reg2 <= 0;
      end
      else
      begin
          VS_reg1 <= Vsync_s;
          VS_reg2 <= VS_reg1;     //��������ֵ���˿�reg1��ֵ�ǵ�ǰclk�����ص�VS��reg2Ϊ��һclk�����ص�VS
      end
  end
  
 assign Hsync_s = H_Sync_r;
 assign Vsync_s = V_Sync_r;  
 assign VS_negedge = ~VS_reg1 & VS_reg2; //���ȼ�~����&��VS��1��Ϊ0ʱ������ֵȡ1����ΪͼƬ�ƶ�״̬��ת�Ƶ���Ч�źţ��������ϣ�

  //�����ʾ��Ч���ź�
  assign disp_en = (H_count <= H_End) && (H_count >= H_Start) && (V_count <= V_End) && (V_count >= V_Start) ? 1'b1 : 1'b0;
  
endmodule