`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/12/14 19:38:31
// Design Name: 
// Module Name: VGA_control
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
module VGA_disp(
    input clk_25MHz,        //VGA����ʱ��
    input rst_n,            //��λ�źţ��͵�ƽ��Ч
    input ena_sun,          //ѡ��ʼ�հ���ģʽ���ߵ�ƽ��Ч
    input disp_en,          //����ͼƬ�Ƿ�����ʾ
    input [3:0] L_sec,
    input [3:0] H_sec,
    input [3:0] L_min,
    input [3:0] H_min,
    input [3:0] L_hour,
    input [3:0] H_hour,     //���������������
    
    input [39:0] HT_data,    //�����¶ȴ�����������
    
    input v2_show_en,       //������������������ʾʱ��/��ʪ����Ч�ź�
    
    input [11:0] xpos,       //���������
    input [11:0] ypos,
    input [11:0] hpos,      //��¼ͼƬ��ʱ�̱仯��ƫ����
    input [11:0] vpos,
    output [3:0] vga_r,     //�����RGBͨ������
    output [3:0] vga_g,
    output [3:0] vga_b
 );
 parameter MOON_NUM = 18225; //�˶�����ͼƬ������
 parameter MOON_WIDTH = 135;
 parameter MOON_HEIGHT = 135;
 parameter SUN_NUM = 18225; //�˶�̫��ͼƬ������
 parameter SUN_WIDTH = 135;
 parameter SUN_HEIGHT = 135;
 
 parameter TONGJI_WIDTH = 640;  //ͼƬ�Ŀ��
 parameter TONGJI_HEIGHT = 200; //ͼƬ�ĸ߶�
 
 parameter CHARAC_WIDTH = 80;  //����ͼƬ�Ŀ��
 parameter CHARAC_HEIGHT = 150; //����ͼƬ�ĸ߶�
 parameter CHARAC_H_OFFSET = 140;
 parameter CHARAC_V_OFFSET = 210; //����ͼƬλ��ƫ����
 
 parameter UNIT_WIDTH = 80;      //�ַ�ͼƬ�Ŀ��
 parameter UNIT_HEIGHT = 80;     //ע���޸�ͼƬ��СҪͳһ
 parameter UNIT_H_OFFSET = 395;  
 parameter UNIT_V_OFFSET = 265;  //��λͼƬλ��ƫ����

//ip��ROM�Ĵ洢����
reg [17:0] cloud_addr = 0;
reg [14:0] moon_addr = 0, sun_addr = 0;
reg [16:0] tongji_addr = 0;
reg [13:0] charac_addr = 0;
reg [12:0] unit_addr = 0;           //ͼƬ��ַ��Ϣ
wire [15:0] cloud_data, moon_data,tongji_data,charac_data,unit_data,sun_data;   //ͼƬ������Ϣ

reg [3:0] vga_r_reg;
reg [3:0] vga_g_reg;
reg [3:0] vga_b_reg;            //�����ɫͨ�����м�Ĵ�������

wire show_sun;      //����Сʱ��6�㵽18�㣬��֮����չʾ����
assign show_sun = ({H_hour,L_hour} >= 6) &&({H_hour,L_hour} <= 24); //ʮ����18�����Ƕ����Ʋ��ǣ�ƴ���Ƕ�������(���������ʵ�鱨������ϸ˵��)
always @ (negedge clk_25MHz, negedge rst_n)
    begin
      if(!rst_n)
      begin 
          vga_r_reg <= 4'b0;  //��ʾ��ɫ
          vga_g_reg <= 4'b0;
          vga_b_reg <= 4'b0;
          tongji_addr <= 17'b0;
          moon_addr <= 15'b0;
          sun_addr <= 15'b0;
          unit_addr <= 13'b0;
          charac_addr <= 14'b0;
      end
      else
      begin 
        if(disp_en)
        begin
           if(!v2_show_en)
           begin
                 tongji_addr <= 17'd0;    //���е�ַ��λ�������ȥ�ĵ�ַ��Ժ�������Ӱ�죬��ͼƬ�Ű����
                 unit_addr <=13'd0;
                 charac_addr <= 14'd0;
                //������ʮ����Ҫ����һЩ���ȼ��Ŀ�
                  if(~show_sun)
                  begin
                          sun_addr <= 15'd0;        //ÿ���л�ʱ��Ҫ���е�ַ��λ
                          if(xpos >= ( 144 + hpos)  &&  xpos <= (144 + hpos + MOON_WIDTH  - 1'b1)  &&ypos >= (35 + vpos) && ypos <= (35 + vpos + MOON_HEIGHT - 1'b1)  )
                                begin
                                    vga_r_reg  <= moon_data[11:8] ;
                                    vga_g_reg  <= moon_data[7:4];
                                    vga_b_reg  <= moon_data[3:0];
                                    if(moon_addr == MOON_NUM - 1'b1)
                                        moon_addr  <=  15'd0 ;
                                    else
                                        moon_addr  <=  moon_addr  +  1'b1 ;         
                                end          
                          else
                             begin
                              vga_r_reg <=  4'b1111;      //vga��ʾͼƬ�����ಿ����ʾ��ɫ���ɺ������ϳ�
                              vga_g_reg <=  4'b0;   
                              vga_b_reg <=  4'b1111;  
                              moon_addr <= moon_addr;
                             end  
                 end
                 else
                 begin
                         moon_addr <= 15'd0;
                         if(xpos >= ( 144 + hpos)  &&  xpos <= (144 + hpos + SUN_WIDTH  - 1'b1)  &&ypos >= (35 + vpos) && ypos <= (35 + vpos + SUN_HEIGHT - 1'b1)  )
                              begin
                                  vga_r_reg  <= sun_data[11:8] ;
                                  vga_g_reg  <= sun_data[7:4];
                                  vga_b_reg  <= sun_data[3:0];
                                  if(sun_addr == SUN_NUM - 1'b1)
                                      sun_addr  <=  15'd0 ;
                                  else
                                      sun_addr  <=  sun_addr  +  1'b1 ;         
                              end          
                              else
                                 begin
                                  vga_r_reg <=  4'b0;      //vga��ʾͼƬ�����ಿ����ʾ��ɫ���ɺ������ϳ�
                                  vga_g_reg <=  4'b1111;   
                                  vga_b_reg <=  4'b1111;  
                                  sun_addr <= sun_addr;
                                 end  
                 
                 end                 
           end
           else //��������������Ч��
           begin
           moon_addr <= 15'd0;
           sun_addr <= 15'd0;
           if(xpos >= 144  && xpos < 144 + TONGJI_WIDTH && ypos >= 35  && ypos < 35 + TONGJI_HEIGHT)       //��ʼ��ΪH/V_Start+ƫ��,�յ�ΪͼƬ��ʼ��+ͼƬ��/�߶�
           begin
                vga_r_reg <= tongji_data[11:8];
                vga_g_reg <= tongji_data[7:4];
                vga_b_reg <= tongji_data[3:0];
                tongji_addr <= (ypos - 35) * TONGJI_WIDTH + xpos - 144; 
            end
            else if(xpos >= 144 + UNIT_H_OFFSET  && xpos < 144 + UNIT_WIDTH + UNIT_H_OFFSET && ypos >= 35 + UNIT_V_OFFSET  && ypos < 35 + UNIT_HEIGHT + UNIT_V_OFFSET)
            begin
                vga_r_reg <= unit_data[11:8];
                vga_g_reg <= unit_data[7:4];
                vga_b_reg <= unit_data[3:0];
                unit_addr <= (ypos - (35 + UNIT_V_OFFSET)) * UNIT_WIDTH + xpos - (144 + UNIT_H_OFFSET);    
            end
            else if(xpos >= 144 + CHARAC_H_OFFSET  && xpos < 144 + CHARAC_WIDTH + CHARAC_H_OFFSET && ypos >= 35 + CHARAC_V_OFFSET  && ypos < 35 + CHARAC_HEIGHT + CHARAC_V_OFFSET)
            begin
                vga_r_reg <= charac_data[11:8];
                vga_g_reg <= charac_data[7:4];
                vga_b_reg <= charac_data[3:0];
                charac_addr <= (ypos - (35 + CHARAC_V_OFFSET)) * CHARAC_WIDTH + xpos - (144 + CHARAC_H_OFFSET);             
            end
            else
             begin
                vga_r_reg <=  4'b1111;      //vga��ʾͼƬ�����ಿ����ʾ��ɫ
                vga_g_reg <=  4'b1111;   
                vga_b_reg <=  4'b1111;  
             end
             end
        end    
            
        else
        begin 
            vga_r_reg<= 4'b0;    //��ʾ��ɫ
            vga_g_reg<= 4'b0;
            vga_b_reg<= 4'b0;
        end
      end
    end

//ͼƬ�����ƶ�������ͼƬ�����������¶������ƻ������ص���ʾ�����⣬���Ҷ���ͼƬͬʱ�����ᳬ���洢�����ֵ
Rom_Moon moon(
    .clka(clk_25MHz),
    .addra(moon_addr),
    .douta(moon_data),
    .ena(~show_sun && ~v2_show_en)
);

Rom_sun sun(
    .clka(clk_25MHz),
    .addra(sun_addr),
    .douta(sun_data),
    .ena(show_sun && ~v2_show_en)
);

Tongji tongji_uut(
    .clka(clk_25MHz),
    .addra(tongji_addr),
    .douta(tongji_data),
    .ena(v2_show_en)
);

Charac charac_uut(
    .clka(clk_25MHz),
    .addra(charac_addr),
    .douta(charac_data),
    .ena(v2_show_en)
);

Unit unit_uut(
   .clka(clk_25MHz),
   .addra(unit_addr),
   .douta(unit_data),
   .ena(v2_show_en)
);

wire [3:0] hum_H,hum_L,hum_point,tep_H,tep_L,tem_point;

assign hum_L = (HT_data[39:24]/10)%10;
assign hum_point = HT_data[39:24]%100;  //��ֹ��λ������������
assign hum_H = (HT_data[39:24] - 10* hum_L)/100;

assign tep_L = HT_data[23]? (HT_data[22:8]/10)%10 : (HT_data[23:8]/10)%10;
assign tep_point = HT_data[23]? HT_data[22:8]%100 : HT_data[23:8]%100;
assign tep_H = HT_data[23]? (HT_data[22:8] - 10* tep_L)/100 :(HT_data[23:8] - 10* tep_L)/100;          //�����¶�Ϊ�������
  
parameter colon = 10, blank = 12, point = 11;   //ð����հ�
//ȷ���ֵ���ʾ��Χ
wire time_en;
assign time_en =
     ((xpos >= 368 && xpos <= 559 && ypos >= 250 && ypos <= 281)||(xpos >= 440 && xpos <= 535 && ypos >= 300 && ypos <= 331)
            || xpos >= 440 && xpos <= 535 && ypos >= 350 && ypos <= 381) ? 1 : 0;

reg [3:0] temp_num;
reg [5:0] x_locate, y_locate;
always @ (*) 
    begin
    if(ypos >= 250 && ypos <= 281)              //��ʾʱ��ķ�Χ
        begin
            y_locate = ypos - 250;
            if(xpos >= 368  && xpos <= 383)  
            begin
                temp_num = H_hour;
                x_locate  = xpos - 368;  
            end
            else if(xpos >= 384  && xpos <= 399)  
            begin
                temp_num = L_hour;
                x_locate  = xpos - 384;  
            end
            else if(xpos >= 400 && xpos <= 415)  
            begin
                temp_num = blank;
                x_locate  = xpos - 400;  
            end
            else if(xpos >= 416  && xpos <= 431)  
            begin
                temp_num = colon;
                x_locate  = xpos - 416;  
            end
            else if(xpos >= 432  && xpos <= 447)  
            begin
                temp_num = blank;
                x_locate  = xpos - 432;  
            end
            else if(xpos >= 448  && xpos <= 463)  
            begin
                temp_num = H_min;
                x_locate  = xpos - 448;  
            end
            else if(xpos >= 464  && xpos <= 479)  
            begin
                temp_num = L_min;
                x_locate  = xpos - 464;  
            end
            else if(xpos >= 480  && xpos <= 495)  
            begin
                temp_num = blank;
                x_locate  = xpos - 480;  
            end
            else if(xpos >= 496  && xpos <= 511)  
            begin
                temp_num = colon;
                x_locate  = xpos - 496;  
            end
            else if(xpos >= 512 && xpos <= 527)  
            begin
                temp_num = blank;
                x_locate  = xpos - 512;  
            end
            else if(xpos >= 528 && xpos <= 543)  
            begin
                temp_num = H_sec;
                x_locate  = xpos - 528; 
               end
            else if(xpos >= 544 && xpos <= 559)  
            begin
                temp_num = L_sec;
                x_locate  = xpos - 544;  
            end
            else 
            begin
                temp_num = blank;
                x_locate = 0;  
            end
        end
    else if(ypos >= 300 && ypos <= 331)
    begin
        y_locate = ypos - 300;
        
        if(xpos >= 440 && xpos <= 455)
        begin
            temp_num = colon;
            x_locate = xpos - 440;                                                
        end
        else if(xpos >= 456 && xpos <= 471)
        begin
            temp_num = HT_data[23] ? 0 : blank;
            x_locate = xpos - 456;    
        end
        else if(xpos >= 472 && xpos <= 487)
        begin
            temp_num = tep_H;
            x_locate = xpos - 472;    
        end
        else if(xpos >= 488 && xpos <= 503)
        begin
            temp_num = tep_L;
            x_locate = xpos - 488;    
        end
        else if(xpos >= 504 && xpos <= 519)
        begin
            temp_num = point;
            x_locate = xpos - 504;    
        end
        else if(xpos >= 520 && xpos <= 535)
        begin
            temp_num = (tep_point < 10) ? tep_point : 0;
            x_locate = xpos - 520;    
        end                                         
    end

        else if(ypos >= 350 && ypos <= 381)
        begin
            y_locate = ypos - 350;
            
            if(xpos >= 440 && xpos <= 455)
            begin
                temp_num = colon;
                x_locate = xpos - 440;
            end
            else if(xpos >= 456 && xpos <= 471)
            begin
                temp_num = blank;
                x_locate = xpos - 456;
            end
            else if(xpos >= 472 && xpos <= 487)
            begin
                temp_num = hum_H;
                x_locate = xpos - 472;
            end
            else if(xpos >= 488 && xpos <= 503)
            begin
                temp_num = hum_L;
                x_locate = xpos - 488;
            end
            else if(xpos >= 504 && xpos <= 519)
            begin
                temp_num = point;
                x_locate = xpos - 504;
            end
            else if(xpos >= 520 && xpos <= 535)
            begin
                temp_num = (hum_point < 10) ? hum_point : 0;
                x_locate = xpos - 520;
            end                                                                                                       
        end
        else
        begin
            temp_num = blank;
            y_locate = 0;
            x_locate = 0;
        end
    end

reg [9:0] base_addr;        //���ڶ�ȡ��Ӧλ������ģcoe�ļ���������
    always@( * ) 
    begin
        case(temp_num)
        4'd0 :
            base_addr = 0;
        4'd1 :
            base_addr = 32;
        4'd2 :
            base_addr = 64;
        4'd3 :
            base_addr = 96;
        4'd4 :
            base_addr = 128;
        4'd5 :
            base_addr = 160;
        4'd6 :
            base_addr = 192;
        4'd7 :
            base_addr = 224;
        4'd8 :
            base_addr = 256;
        4'd9 :
            base_addr = 288;
        4'd10:
            base_addr = 320;
        4'd11:
            base_addr = 352;
        4'd12:
            base_addr = 384;
        4'd13:
            base_addr = 416;
        4'd14:
            base_addr = 448;
        4'd15:
            base_addr = 480;
        default:
            base_addr =0;
        endcase
    end
     
wire [8:0] addra;
assign addra = base_addr + y_locate;      //��λ��һ�������������е����ص㣬��������
wire [15:0] douta;
     
Character character_uut
(
  .clka(clk_25MHz), 
  .addra(addra), 
  .douta(douta), //��ȡÿ�����ֵ�16λһ�е�����
  .ena(v2_show_en)
);

wire [15:0] douta_initial;
assign douta_initial = douta << x_locate;     //ÿ����Χ�ڵĵ�ַ����ӳ�䵽��Ե�ַ��Ȼ���������������λ�õ����λ�����Ǹõ��rgbֵ
assign num = douta_initial[15];

//��ģ������ʾ����������ǰ׵ģ���Ҫ����ģ����ȡ��
/*
������ʾ�ĵط�Ϊ1������ʾ�ĵط�Ϊ0�������潲�������ֱ�Ӹ�����RGB��
������ɫ�ϳɣ����RGB����1�Ļ�����ô�����ľ��ǰ�ɫ������Ļ�ϾͿ������ˣ���RGB����0�Ļ�����ô�����ľ��Ǻ�ɫ
*/
//��rgbֵȡ��ʵ�ְ�����ҹ��ģʽ���л�
assign vga_r = v2_show_en ? (show_sun | ena_sun ? (time_en ? {4{~num}} : vga_r_reg):(time_en ? {4{num}} : ~vga_r_reg)) : vga_r_reg;
assign vga_g = v2_show_en ? (show_sun | ena_sun ? (time_en ? {4{~num}} : vga_g_reg):(time_en ? {4{num}} : ~vga_g_reg)) : vga_g_reg;
assign vga_b = v2_show_en ? (show_sun | ena_sun ? (time_en ? {4{~num}} : vga_b_reg):(time_en ? {4{num}} : ~vga_b_reg)) : vga_b_reg;
endmodule