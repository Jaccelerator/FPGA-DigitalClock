`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/12/17 14:53:44
// Design Name: 
// Module Name: Divider
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
module Divider(
    input clk_100MHz,       //ϵͳʱ��
    input rst_n,            //VGA��λ�ź�
    output reg clk_25MHz   //�������VGA��ʱ��
    );
//4��Ƶ
reg count = 1'b0; 
always @(posedge clk_100MHz) 
begin 
    if(!rst_n)
    begin
      count <= 1'b0;
      clk_25MHz <= 0;  
    end
    else if(count == 1'b1) 
    begin 
        count <= 1'b0; 
        clk_25MHz <= ~clk_25MHz; 
    end 
    else
        count <= 1'b1; 
end
endmodule


