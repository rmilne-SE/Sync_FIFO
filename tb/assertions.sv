// Testbench Assertions Module
// Monitors DUT flags + pointers, and checks for violations that would not be 
// caught by checking data correctness alone (e.g. FULL and EMPTY flag asserted together
// or a pointer advancing on write/read that should have been blocked)
module fifo_assertions # (
    parameter DEPTH      = 16,
    parameter ADDR_WIDTH = $clog2(DEPTH)
)(
    input clk,
    input rst_n,

    input wr_en,
    input rd_en,
    
    input full,
    input empty,

    input [ADDR_WIDTH:0] wr_ptr,
    input [ADDR_WIDTH:0] rd_ptr
);
    integer assertion_errors = 0;

    reg [ADDR_WIDTH:0] prev_wr_ptr = 0;
    reg [ADDR_WIDTH:0] prev_rd_ptr = 0;

    reg reset_check; // Set on reset, cleared once post reset state has been verified

    always @(posedge clk) begin
        // FULL and EMPTY can never both be true
        if(full && empty) begin
            $display("ASSERT FAIL: FULL and EMPTY both active");
            assertion_errors++;
        end

        // EMPTY flag must exactly track pointers equal
        if(empty != ((wr_ptr == rd_ptr))) begin
            $error("EMPTY flag incorrect");
            assertion_errors++;
        end
        
        // FULL flag must exactly track wrapbit/indexbit comparison
        if(full != (
            (wr_ptr[ADDR_WIDTH] != rd_ptr[ADDR_WIDTH]) &&
            (wr_ptr[ADDR_WIDTH-1:0] == rd_ptr[ADDR_WIDTH-1:0])))
            begin
                $error("FULL flag incorrect");
                assertion_errors++;
            end

        // Pointers and EMPTY must come out of reset clean
        if(!rst_n) begin
            reset_check <= 1;
        end else if(reset_check) begin
            if(wr_ptr != 0) begin
                $error("FIFO reset failure (wr_ptr)");
                assertion_errors++;
            end
            if(rd_ptr != 0) begin
                $error("FIFO reset failure (rd_ptr)");
                assertion_errors++;
            end
            if(!empty) begin
                $error("FIFO reset failure (empty)");
                assertion_errors++;
            end
            reset_check <= 0;
        end


        // prev_wr_ptr and prev_rd_ptr are delayed by one cycle in order
        // for the check to be did wr_ptr change on the cycle a blocked 
        // write happened
        
        // Write attempted while FULL mustn't advance pointer
        prev_wr_ptr <= wr_ptr;
        if(full && wr_en) begin
            if(wr_ptr != prev_wr_ptr) begin
                $error("Write pointer advanced while FULL");
                assertion_errors++;
            end
        end

        // Read attempted while EMPTY mustn't advance pointer
        prev_rd_ptr <= rd_ptr;
        if(empty && rd_en) begin
            if(rd_ptr != prev_rd_ptr) begin
                $error("Read pointer advanced while EMPTY");
                assertion_errors++;
            end
        end

    end

    function get_errors();
        return assertion_errors;
    endfunction
endmodule