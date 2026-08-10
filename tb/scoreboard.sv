// Testbench Scoreboard Module
// Reference Module and Checker. Maintains its own version of the queue and compares it against 
// what the DUT actually outputs on RD_DATA flagging any mismatches. This module determines PASS/FAIL,
// independent of assertions.
//
// Same one cycle pending pattern used in monitor. RD_DATA is registered in DUT, so expected value is only
// compared one cycle after read was issued.
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
    reg [DATA_WIDTH-1:0] queue[$]; // Scoreboards version of FIFO contents

    reg pending_read;

    reg [DATA_WIDTH-1:0] expected;

    integer passes = 0;
    integer errors = 0;

    always @(negedge clk) begin
        #1;
        if(!rst_n) begin
            queue.delete();
            pending_read = 0;
        end else begin
            // Mirror any accepted write into scoreboard queue
            if(wr_en && !full)
                queue.push_back(wr_data);

            // Check previous cycle read issue against oldest entry in queue
            if(pending_read) begin
            expected = queue.pop_front();

                if(rd_data != expected)
                begin
                    $error("FIFO ERROR Expected=%0d Got=%0d", expected, rd_data);
                    errors = errors + 1;
                end else begin
                    $display("FIFO PASS Expected=%0d", expected);
                    passes = passes + 1;
                end
            end
        end

        pending_read <= rd_en && !empty;
    end

    // Used once at end of TB to report any data left unread in FIFO
    task report_final_occupancy();
        $display("Final FIFO Occupancy : %0d\n", queue.size());
    endtask
endmodule