// Testbench Coverage Module
// Functional coverage tracker, records whether each meaningful scenario (reset, full
// empty, simultaneous R/W, overflow attempt, underflow attempt and every occupancy 
// level 0 -> DEPTH) has been tested at least once, plus all time R/W counts.

module fifo_coverage # (
    parameter DEPTH      = 16
)(
    input clk,
    input rst_n,

    input wr_en,
    input rd_en,

    input full,
    input empty
);
    integer write_count = 0;
    integer read_count = 0;

    integer occupancy = 0;
    bit occupancy_levels [0:DEPTH]; // Coverage bin per occupancy level 0 -> DEPTH

    bit reset_seen;
    bit full_seen;
    bit empty_seen;
    bit simultaneous_seen;
    bit overflow_seen;
    bit underflow_seen;

    reg pending_read; // Same one cycle offset as in monitor/scoreboard.
                      // Means read_count only increments once read has 
                      // actually been completed

    always @(posedge clk) begin
        if(!rst_n) begin
            reset_seen = 1;
            occupancy = 0; 
            pending_read = 0;
        end else begin   
            if(wr_en && !full)
                write_count++;

            if(pending_read)
                read_count++;
        
            pending_read <= rd_en && !empty;

            // Tracks running occupancy from accepted writes/reads
            case({wr_en && !full, rd_en && !empty})
                2'b10: occupancy++;
                2'b01: occupancy--;
                default: occupancy = occupancy;
            endcase
            occupancy_levels[occupancy] = 1;

            if(full)
                full_seen = 1;

            if(empty)
                empty_seen = 1;

            if((wr_en && !full) && (rd_en && !empty))
                simultaneous_seen = 1;
            
            if(wr_en && full)
                overflow_seen = 1;

            if(rd_en && empty)
                underflow_seen = 1;
        end
    end

    // Prints pass/fail summary of which coverage bins were hit
    task report();
        $display("==============================");
        $display("FIFO Coverage Report");
        $display("==============================\n");

        $display("Reset Tested             : %s", reset_seen ? "PASS" : "FAIL");
        $display("Full Condition           : %s", full_seen ? "PASS" : "FAIL");
        $display("Empty Condition          : %s", empty_seen ? "PASS" : "FAIL");
        $display("Simultaneous Read/Write  : %s", simultaneous_seen ? "PASS" : "FAIL");
        $display("Overflow Attempt         : %s", overflow_seen ? "PASS" : "FAIL");
        $display("Underflow Attempt        : %s", underflow_seen ? "PASS\n" : "FAIL\n");
        for(integer i=0;i<=DEPTH;i++)
        begin
            $display("Occupancy %0d : %s",
                    i,
                    occupancy_levels[i] ? "HIT" : "MISS");
        end
        $display("");
        $display("Total Writes (Lifetime)            : %0d",write_count);
        $display("Total Reads (Lifetime)             : %0d\n",read_count);
    endtask

endmodule