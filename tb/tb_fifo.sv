// Testbench Top Module
// Instantiates the DUT, driver, monitor, scoreboard, assertions, and coverage.
// Runs a fixed sequence of directed tests followed by a large random test.
//
// Reports scoreboard results, asseertion error count, coverage and final occupancy
// at the end
module tb_fifo();
    parameter DATA_WIDTH = 8;
    parameter DEPTH = 16;

    reg clk;
    wire rst_n;

    wire wr_en;
    wire [DATA_WIDTH-1:0] wr_data;

    wire rd_en;
    wire [DATA_WIDTH-1:0] rd_data;

    wire full;
    wire empty;

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    fifo_sync DUT(
        .CLK(clk),
        .RST_N(rst_n),
        .WR_EN(wr_en),
        .WR_DATA(wr_data),
        .FULL(full),
        .RD_EN(rd_en),
        .RD_DATA(rd_data),
        .EMPTY(empty)
    );

    driver drv(
        .clk(clk),
        .rst_n(rst_n),
        .wr_en(wr_en),
        .wr_data(wr_data),
        .rd_en(rd_en)
    );

    monitor mon(
        .clk(clk),
        .wr_en(wr_en),
        .wr_data(wr_data),
        .rd_en(rd_en),
        .rd_data(rd_data),
        .full(full),
        .empty(empty)
    );

    scoreboard sb(
        .clk(clk),
        .rst_n(rst_n),
        .wr_en(wr_en),
        .wr_data(wr_data),
        .rd_en(rd_en),
        .rd_data(rd_data),
        .full(full),
        .empty(empty)
    );

    fifo_assertions assertions (
        .clk(clk),
        .rst_n(rst_n),
        .wr_en(wr_en),
        .rd_en(rd_en),
        .full(full),
        .empty(empty),
        .wr_ptr(DUT.wr_ptr), // Uses hierarchical reference to tap ptrs
        .rd_ptr(DUT.rd_ptr)
    );

    fifo_coverage cov (
        .clk(clk),
        .rst_n(rst_n),
        .wr_en(wr_en),
        .rd_en(rd_en),
        .full(full),
        .empty(empty)
    );

    // Directed test sequence followed by large randomised test
    initial begin
        test_reset();
        test_single_rw();
        test_fill_empty();
        test_overflow();
        test_underflow();
        test_wraparound();
        test_sim_rw();
        test_random();

        report_results();
        cov.report();
        sb.report_final_occupancy();

        $finish;
    end

    // Directed Tests
    
    // Basic reset test
    task test_reset();
        $display("\nRunning Reset Test");
        drv.reset();
        repeat(2) @(posedge clk);
    endtask

   // One write followed by one read
    task test_single_rw();
        $display("\nRunning Single Read/Write Test");
        drv.write(10);
        drv.read();
        repeat(2) @(posedge clk);
    endtask

    // Fills FIFO checks FULL, empties FIFO checks EMPTY
    task test_fill_empty();
        integer i;
        $display("\nRunning Fill/Empty Test");
        for(i = 0; i < DEPTH; i = i + 1)
            drv.write(i);

        if(!full)
            $error("FIFO should be FULL");

        for(i = 0; i < DEPTH; i = i + 1)
            drv.read();

        repeat(2) @(posedge clk);

        if(!empty)
            $error("FIFO should be EMPTY!");
    endtask

    // Fills FIFO, attempts additional write, DUT should ignore
    // (assertions verifies this)
    task test_overflow();
        integer i;

        $display("\nRunning Overflow Test");

        drv.reset();

        for(i = 0; i < DEPTH; i = i + 1)
            drv.write(i);

        drv.write(8'hFF); // FIFO should ignore write because FULL=1

        repeat(2) @(posedge clk);
    endtask

    // Attempt read on empty FIFO, DUT should ignore
    // (assertions verifies this)
    task test_underflow();
        $display("\nRunning Underflow Test");
        drv.reset();
        drv.read();
        repeat(2) @(posedge clk);
    endtask

    // Fill. drain half, refill half, drain fully
    // tests ptr wraparound through memory array
    task test_wraparound();
        integer i;
        $display("\nRunning Wraparound Test");

        drv.reset();
        
        for(i = 0; i < DEPTH; i = i + 1)
            drv.write(i);
        for(i = 0; i < DEPTH / 2; i = i + 1)
            drv.read();
        for(i = 0; i < DEPTH / 2; i = i + 1)
            drv.write(i + 100);
        for(i = 0; i < DEPTH; i = i + 1)
            drv.read();

        repeat(2) @(posedge clk);
    endtask

    // Half fill then perform simultaneous Read and Writes
    task test_sim_rw();
        integer i;

        $display("\nRunning Simultaneuous R/W Test");

        drv.reset();

        for(i = 0; i < DEPTH / 2; i = i + 1)
            drv.write(i);
        
        for(i = 0; i < 20; i = i + 1)
            drv.read_write(i + 50);
    endtask

    // 10,000 iteration randomised test
    // Mixes writes, reads, and simultaneous read/write
    task test_random();
        integer i;

        $display("\nRunning Random Test");

        drv.reset();

        for(i = 0; i < 10000; i = i + 1) begin
            case($urandom_range(0,2))
                0: drv.write($urandom);
                1: drv.read();
                2: drv.read_write($urandom);
            endcase
        end
    endtask

    // Final Report
    task report_results();
        $display("\n=================================");
        $display("FIFO Verification Complete");
        $display("=================================\n");

        $display("Passes : %0d", sb.passes);
        $display("Errors : %0d", sb.errors);
        $display("Assertion Errors : %0d", assertions.assertion_errors);
    
        if((sb.errors==0) && (assertions.assertion_errors == 0))
            $display("RESULT : PASS\n");
        else
            $display("RESULT : FAIL\n");
    endtask
endmodule