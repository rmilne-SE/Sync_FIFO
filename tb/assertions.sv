module fifo_assertions(
    input clk,
    input rst_n,

    input wr_en,
    input rd_en,
    
    input full,
    input empty
);
    integer assertion_errors = 0;

    always @(posedge clk) begin
        if(full && empty) begin
            $display("ASSERT FAIL: FULL and EMPTY both active");
            assertion_errors++;
        end

        if(full && wr_en) begin
            $display("ASSERT FAIL: WRITE while FULL");
            assertion_errors++;
        end

        if(empty && rd_en) begin
            $display("ASSERT FAIL: READ while EMPTY");
            assertion_errors++;
        end
    end

    function get_errors();
        return assertion_errors;
    endfunction
endmodule