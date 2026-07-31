module tb_fifo # (
    parameter DATA_WIDTH = 8,
    parameter DEPTH      = 16
)();
    reg clk;
    reg rst_n;

    reg wr_en;
    reg [DATA_WIDTH-1:0] wr_data;
    wire full;

    reg rd_en;
    wire [DATA_WIDTH-1:0] rd_data;
    wire empty;

    initial begin 
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        // Initialise and Test Reset
        rst_n = 0;
        wr_en = 0;
        rd_en = 0;

        wr_data = 0;

        #10;
        rst_n = 1;
        #5;

        // Test Single Write + Read Out
        wr_en = 1;
        wr_data = 5;

        #5;
        wr_en = 0;
        // Enable Read
        #5;
        rd_en = 1;
        #10;

        // Disable Read and Fill to Full
        rd_en = 0;
        wr_en = 1;
        wr_data = 5;
        #160;

        // Disable Write and Empty
        wr_en = 0;
        rd_en = 1;
        #150;

        // Test wr_ptr wraparound
        #5;
        rd_en = 0;
        wr_en = 1;
        #150;

        // Test wr_ptr wraparound
        #5;
        wr_en = 0;
        rd_en = 1;
        #140;

        #5;
        wr_en = 1;
        wr_data = 7;
        #20;

        
        #5;
        $finish;
    end

    fifo_sync uut (
        .CLK(clk),
        .RST_N(rst_n),
        .WR_EN(wr_en),
        .WR_DATA(wr_data),
        .FULL(full),
        .RD_EN(rd_en),
        .RD_DATA(rd_data),
        .EMPTY(empty)
    );
    
    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, tb_fifo);
    end

endmodule