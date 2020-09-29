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

//自带分频的状态机控制
module DHT22_control(
    input clk_100MHz,
    input rst_DHT,
    inout DHT_DATA,                 //从机的输入输出端口

    output reg [39:0] HT_data       //传出输出的40位数据
);

reg [31:0] us_count;                //记录1us的时间个数
reg [3:0] DHT_state;                //存放状态
reg [5:0] bit_count;                //存放数据位数

reg DHT_DATA_reg;                   //存放读写DHT_DATA的寄存器
reg [39:0] HT_data_reg;             //作为最终输出数据的中间变量

reg flag;        //标识符  1是读，0是高阻，不可读状态
assign DHT_DATA = flag ? DHT_DATA_reg : 1'bz;           //SDA数据通路信号
//13个状态
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
    if(!rst_DHT)			//复位信号，全部清零，即主机从机从初态开始
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
                if(us_count == 2000000) //保证两次读取的最小间隔为2s
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
                if(us_count == 1000)   //主机将数据总线SDA(HT_data)拉低1ms，停止写入数据，从机开始发出信号
                begin
                    flag <= 0;	//停止写入
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
                if(us_count == 20)      //主机释放总线，由于上拉电阻作用，会保持20us高电平
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
                    DHT_state <= S4;	 //保证主机成功下拉总线 	
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
                    DHT_state <= S5;	//从机成功上拉总线
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
                    DHT_state <= S6;//再成功下拉总线
                end
            end
            S6: 
            begin
                if(DHT_DATA == 0)
                begin
                    DHT_state <= S6;	  //由于数据传输一开始是低电平，延时保持状态
                end
                else
                begin
                    DHT_state <= S7;  //直到从机发送上升沿信号（再上拉总线）开始从从机中读数据
                end
            end
            S7:
            begin
                if(DHT_DATA == 1)	 //保证传输数据低电平结束，到达高电平状态
                begin
                    DHT_state <= S8;   
                end
            end
            S8: //有用的数据读取状态	
            begin
                if(us_count == 50)   //延时50us（由于数据0是26~28us高电平，而数据1是70us高电平，所以取中间数50us查看总线状态）
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
                if(DHT_DATA == 1)      //50us过去，总线高电平输出位为1，否则为0
                begin
                    HT_data_reg[0] <= 1;
                end
                else
                begin
                    HT_data_reg[0] <= 0;
                end
                DHT_state <= S10;
                bit_count <= bit_count + 1;	//记录读取位数
                us_count <= 0;
            end
            S10:
            begin
                if(bit_count >= 40)
                begin
                    DHT_state <= S0;		//读取位数达到40，结束一轮数据读取过程，回到初态
                    bit_count <= 0;
                    if(HT_data_reg[39:32] + HT_data_reg[31:24] + HT_data_reg[23:16] + HT_data_reg[15:8] == HT_data_reg[7:0])        //进行校验，判断读取数据的正确性
                        HT_data <= HT_data_reg;
                    else
                        HT_data <= HT_data;
                end
                else
                begin
                    HT_data_reg <= HT_data_reg << 1;	//由于传输的数据是高位先出，因而每读取一位，就要向左移一位
                    if(DHT_DATA == 1)	//如果总线还是高电平，即读取的位数据1
                        DHT_state <= S11;
                    else
                        DHT_state <= S12; 	//低电平即读取位数据0，即到达了下一个数据传输的低电平阶段
                end
            end
            S11://接受这一位数据为1的情况，需要把剩余的高电平时间结束，再度过读下一个数据的总线低电平阶段，即从S11~S12
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
            S12://接受这一位数据为0的情况，只需要把结束下一个数据的总线低电平阶段，最终二者都回到S8重复每一位的读取过程
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