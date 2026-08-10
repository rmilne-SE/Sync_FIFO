// Testbench Monitor Module
// Passive component observes DUT/driver signals and logs write/read transactions
// to the console. Does not drive any signals and has no bearing on pass/fail.
//
// rd_pending is necessary as the RD_DATA is registered in DUT, data associated with a given
// rd_en pulse appears one cycle later. Sampling the rd_en directly would print wrong value
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

    // Sample after negative clock edge
    // #1; avoids race conditions with signals updated on negedge elsewhere
    always @(negedge clk) begin
        #1;
        
        rd_pending <= rd_en && !empty;

        if(wr_en && !full)
            $display("WRITE: %0d", wr_data);
        
        if(rd_pending)
            $display("READ: %0d", rd_data);

    end
endmodule