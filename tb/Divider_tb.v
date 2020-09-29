module Divider_tb();
    reg clk_100MHz,rst_n;
    wire clk_25MHz;
    Divider uut(
    .clk_100MHz(clk_100MHz),
    .rst_n(rst_n),
    .clk_25MHz(clk_25MHz)
    );
    initial
    begin
        clk_100MHz = 0;
        rst_n = 1;
    end
    always #5 clk_100MHz = ~clk_100MHz;
    initial
    begin
        #20 rst_n = 0;
        #200 rst_n = 1;
    end
endmodule