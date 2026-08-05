module scoreboard # (
    parameter DATA_WIDTH = 8
)(
    input clk,
    input rst_n,

    input wr_en,
    input [DATA_WIDTH-1:0] wr_data,

    input rd_en,
    input [DATA_WIDTH-1:0] rd_data,

    input full,
    input empty
);
    reg [DATA_WIDTH-1:0] queue[$];

    reg pending_read;

    reg [DATA_WIDTH-1:0] expected;

    integer passes = 0;
    integer errors = 0;

    always @(posedge clk) begin
        #1;
        if(!rst_n) begin
            queue.delete();
            pending_read = 0;
        end 

        if(wr_en && !full)
            queue.push_back(wr_data);

        if(pending_read) begin
            expected = queue.pop_front();

            if(rd_data != expected)
            begin
                $error("FIFO ERROR Expected=%0d Got=%0d", expected, rd_data);
                errors = errors + 1;
            end else 
                $display("FIFO PASS Expected=%0d", expected);
                passes = passes + 1;
        end

        pending_read <= rd_en && !empty;
    end
endmodule