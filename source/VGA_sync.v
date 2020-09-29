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
    input clk_25MHz,                //VGA时钟
    input rst_n,                    //VGA复位信号
    output Hsync_s,                 //行同步信号                      
    output Vsync_s,                 //场同步信号 
    output disp_en,                 //显示有效信号
    output reg [11:0] H_count, //行计数器即水平计数                              
    output reg [11:0] V_count,//列计数器即垂直计数  
    output VS_negedge           //输出场信号下降沿
);

parameter H_Total = 800;           //行周期数                       
parameter H_Sync = 96;             //行同步脉冲（Sync a）              
parameter H_Back = 48;             //显示后沿（Back porch b）         
parameter H_Disp = 640;            //显示时序段（Display interval c）  
parameter H_Front = 16;            //显示前沿（Front porch d）        
parameter H_Start = 144;           //行同步+显示后沿，即行显示序列刚开始的像素点     
parameter H_End = 784;             //行同步周期-显示前沿，即行显示结束后要进行行消隐   


// 垂直扫描参数的设定640*480 VGA
parameter V_Total = 525;          //列周期数               
parameter V_Sync = 2;             //列同步脉冲（Sync o）      
parameter V_Back = 33;            //显示后沿（Back porch p） 
parameter V_Disp = 480;           //显示时序段（Display inter
parameter V_Front = 11;           //显示前沿（Front porch r）
parameter V_Start = 35;           //列显示序列刚开始的像素点       
parameter V_End = 514;            //列显示序列刚结束的像素点

//内部信号定义                                                     
                            
reg H_Sync_r;            //二者作为端口行/场信号输出的临时变量     
reg V_Sync_r; 

reg VS_reg1, VS_reg2;       //场信号由1->0时，即下降沿时才进行状态转移。每一帧的下降沿，图片看起来是一帧一帧的运动，进来连续运动形成动画

// 水平扫描计数
always @ (posedge clk_25MHz ,negedge rst_n)
       if(!rst_n)    
            H_count <= 0;
       else if(H_count == H_Total - 1) 
            H_count <= 0;
       else 
            H_count <= H_count + 1;

// 水平扫描信号hsync,H_Sync_valid产生
always @ (posedge clk_25MHz, negedge rst_n)
   begin
       if(!rst_n) 
            H_Sync_r <= 1'b1;
       else if(H_count == 0) 
            H_Sync_r <= 1'b0;            //产生hsync信号
       else if(H_count == H_Sync - 1) 
            H_Sync_r <= 1'b1;
	end
	
// 垂直扫描计数
always @ (posedge clk_25MHz,negedge rst_n)
       if(!rst_n) 
            V_count <= 0;
       else if(V_count == V_Total - 1) 
            V_count <= 0;
       else if(H_count == H_Total - 1) 
            V_count <= V_count + 1;
       
// 垂直扫描信号vsync, V_Sync_valid产生
always @ (posedge clk_25MHz,negedge rst_n)
  begin
       if(!rst_n) 
            V_Sync_r <= 1'b1;
       else if(V_count == 0) 
            V_Sync_r <= 1'b0;    //产生vsync信号
       else if(V_count == V_Sync - 1) 
            V_Sync_r <= 1'b1;
  end
                                 
  //计算是否为场时序下降沿
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
          VS_reg2 <= VS_reg1;     //非阻塞赋值，此刻reg1的值是当前clk上升沿的VS，reg2为上一clk上升沿的VS
      end
  end
  
 assign Hsync_s = H_Sync_r;
 assign Vsync_s = V_Sync_r;  
 assign VS_negedge = ~VS_reg1 & VS_reg2; //优先级~高于&，VS由1变为0时，最终值取1，作为图片移动状态机转移的有效信号（来自网上）

  //输出显示有效的信号
  assign disp_en = (H_count <= H_End) && (H_count >= H_Start) && (V_count <= V_End) && (V_count >= V_Start) ? 1'b1 : 1'b0;
  
endmodule