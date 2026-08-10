// Testbench Driver Module
// Drives DUT stimulus (reset, write, read, simultaneous read+write) on behalf of test sequence in tb_fifo.sv
// Signal changes happen on negative edge of clock, in order for them to settle in time for the DUT's
// next positive edge sample. This means DUT, monitor and scoreboard all see consistent view each cycle
module driver # (
    parameter DATA_WIDTH = 8
)(
    input clk,
    
    output reg rst_n,

    output reg wr_en,
    output reg [DATA_WIDTH-1:0] wr_data,

    output reg rd_en
);
    // Drive active low reset for 2 clocks, all controls deasserted
    task reset();
        rst_n = 0;
        wr_en = 0;
        rd_en = 0;
        wr_data = 0;

        repeat(2) @(posedge clk);

        rst_n = 1;
    endtask

    // Pulse a single write for one clock period
    task write([DATA_WIDTH-1:0] data);
        @(negedge clk);

        wr_en = 1;
        wr_data = data;

        @(negedge clk);

        wr_en = 0;
    endtask

    // Pulse a single read for one clock period
    task read();
        @(negedge clk);

        rd_en = 1;

        @(negedge clk);

        rd_en = 0;
    endtask

    // Assert write and read together for one period
    task read_write([DATA_WIDTH-1:0] data);
        @(negedge clk);
        wr_en = 1;
        wr_data = data;

        rd_en = 1;

        @(negedge clk);

        wr_en = 0;
        rd_en = 0;
    endtask

endmodule