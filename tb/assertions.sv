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

    reg reset_check;

    always @(posedge clk) begin
        if(full && empty) begin
            $display("ASSERT FAIL: FULL and EMPTY both active");
            assertion_errors++;
        end

        if(empty != ((wr_ptr == rd_ptr))) begin
            $error("EMPTY flag incorrect");
            assertion_errors++;
        end
        
        if(full != (
            (wr_ptr[ADDR_WIDTH] != rd_ptr[ADDR_WIDTH]) &&
            (wr_ptr[ADDR_WIDTH-1:0] == rd_ptr[ADDR_WIDTH-1:0])))
            begin
                $error("FULL flag incorrect");
                assertion_errors++;
            end

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



        
        prev_wr_ptr <= wr_ptr;
        if(full && wr_en) begin
            if(wr_ptr != prev_wr_ptr) begin
                $error("Write pointer advanced while FULL");
                assertion_errors++;
            end
        end

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