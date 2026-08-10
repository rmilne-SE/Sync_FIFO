// Synchronous FIFO Module
// Single clock, synchronous FIFO with independent read/write enables
// Uses extra pointer bit to detect FULL/EMPTY
// - lower bits index memory
// - extra MSB toggles when pointers wraparound enabling FULL/EMPTY detection
module fifo_sync # (
    parameter DATA_WIDTH = 8, // Width of each stored word
    parameter DEPTH      = 16 // Number of storage locations
)(
    input logic CLK,
    input logic RST_N, // Active Low Synchronous Reset

    // Write Domain
    input logic WR_EN,
    input logic [DATA_WIDTH-1:0] WR_DATA,
    output logic FULL, // High when FIFO cannot accept a write

    // Read Domain
    input logic RD_EN,
    output logic [DATA_WIDTH-1:0] RD_DATA,
    output logic EMPTY // High when FIFO has nothing to read
);

    localparam ADDR_WIDTH = $clog2(DEPTH); // Calculates number of bits for ptrs (DEPTH must be power of 2 for this logic to work)

    logic [DATA_WIDTH-1:0] mem [0:DEPTH-1];

    // Pointers one bit wider than needed
    // MSB detects FULL/EMPTY
    logic [ADDR_WIDTH:0] wr_ptr;
    logic [ADDR_WIDTH:0] rd_ptr;

    // Write Data to FIFO
    // Silently ignores writes if FULL is asserted
    always_ff @(posedge CLK) begin
        if(!RST_N) begin
            wr_ptr <= 0; 
        end else if(WR_EN && !FULL) begin
            mem[wr_ptr[ADDR_WIDTH-1:0]] <= WR_DATA;
            wr_ptr <= wr_ptr + 1;
        end
    end

    // Read Data from FIFO
    // RD_DATA has one cycle latency
    // Silenty ignores read if EMPTY is asserted
    always_ff @(posedge CLK) begin
        if(!RST_N) begin
            rd_ptr <= 0; 
            RD_DATA <= 0;
        end else if(RD_EN && !EMPTY) begin
            RD_DATA <= mem[rd_ptr[ADDR_WIDTH-1:0]];
            rd_ptr <= rd_ptr + 1;
        end
    end

    // FULL: index bits match, wrap bit does not
    // wr_ptr has lapped rd_ptr
    assign FULL =
    (wr_ptr[ADDR_WIDTH] != rd_ptr[ADDR_WIDTH]) &&
    (wr_ptr[ADDR_WIDTH-1:0] == rd_ptr[ADDR_WIDTH-1:0]);

    // EMPTY: full pointers are identical, no unread data
    assign EMPTY = (wr_ptr == rd_ptr);
endmodule