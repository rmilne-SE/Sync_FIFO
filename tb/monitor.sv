module monitor # (
    parameter DATA_WIDTH = 8
)(
    input clk,
    
    input wr_en,
    input [DATA_WIDTH-1:0] wr_data,

    input rd_en,
    input [DATA_WIDTH-1:0] rd_data,

    input full,
    input empty
);

    reg rd_pending;

    always @(posedge clk) begin
        #1;
        
        rd_pending <= rd_en && !empty;

        if(wr_en && !full)
            $display("WRITE: %0d", wr_data);
        
        if(rd_pending)
            $display("READ: %0d", rd_data);

    end
endmodule
