module tb_fifo();
    parameter DATA_WIDTH = 8;
    parameter DEPTH = 16;

    reg clk;
    wire rst_n;

    wire wr_en;
    wire [DATA_WIDTH-1:0] wr_data;

    wire rd_en;
    wire [DATA_WIDTH-1:0] rd_data;

    wire full;
    wire empty;

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    fifo_sync DUT(
        .CLK(clk),
        .RST_N(rst_n),
        .WR_EN(wr_en),
        .WR_DATA(wr_data),
        .FULL(full),
        .RD_EN(rd_en),
        .RD_DATA(rd_data),
        .EMPTY(empty)
    );

    driver drv(
        .clk(clk),
        .full(full),
        .empty(empty),
        .rst_n(rst_n),
        .wr_en(wr_en),
        .wr_data(wr_data),
        .rd_en(rd_en)
    );

    monitor mon(
        .clk(clk),
        .wr_en(wr_en),
        .wr_data(wr_data),
        .rd_en(rd_en),
        .rd_data(rd_data),
        .full(full),
        .empty(empty)
    );

    scoreboard sb(
        .clk(clk),
        .wr_en(wr_en),
        .wr_data(wr_data),
        .rd_en(rd_en),
        .rd_data(rd_data),
        .full(full),
        .empty(empty)
    );

    initial begin
        drv.reset();

        drv.write(10);
        drv.write(20);
        drv.write(30);

        drv.read();
        drv.read();
        drv.read();

        #100;

        $finish;
    end
endmodule