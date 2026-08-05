module driver # (
    parameter DATA_WIDTH = 8
)(
    input clk,
    input full,
    input empty,

    output reg rst_n,

    output reg wr_en,
    output reg [DATA_WIDTH-1:0] wr_data,

    output reg rd_en
);
    task reset();
        rst_n = 0;
        wr_en = 0;
        rd_en = 0;
        wr_data = 0;

        repeat(2)
            @(posedge clk);

        rst_n = 1;
    endtask

    task write([DATA_WIDTH-1:0] data);
        @(posedge clk);

        if(!full) begin
            wr_en = 1;
            wr_data = data;
        end

        @(posedge clk);
        wr_en = 0;
    endtask

    task read();
        @(posedge clk)

        if(!empty)
            rd_en = 1;

        @(posedge clk)
            rd_en = 0;
    endtask

endmodule