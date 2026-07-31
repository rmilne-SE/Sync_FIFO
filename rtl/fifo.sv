module fifo_sync # (
    parameter DATA_WIDTH = 8,
    parameter DEPTH      = 16
)(
    input logic CLK,
    input logic RST_N,

    // Write Domain
    input logic WR_EN,
    input logic [DATA_WIDTH-1:0] WR_DATA,
    output logic FULL,

    // Read Domain
    input logic RD_EN,
    output logic [DATA_WIDTH-1:0] RD_DATA,
    output logic EMPTY
);

    localparam ADDR_WIDTH = $clog2(DEPTH);

    logic [DATA_WIDTH-1:0] mem [0:DEPTH-1];

    logic [ADDR_WIDTH:0] wr_ptr;
    logic [ADDR_WIDTH:0] rd_ptr;

    // Write Data to FIFO
    always_ff @(posedge CLK) begin
        if(!RST_N) begin
            wr_ptr <= 0; 
        end else if(WR_EN && !FULL) begin
            mem[wr_ptr[ADDR_WIDTH-1:0]] <= WR_DATA;
            wr_ptr <= wr_ptr + 1;
        end
    end

    // Read Data from FIFO
    always_ff @(posedge CLK) begin
        if(!RST_N) begin
            rd_ptr <= 0; 
            RD_DATA <= 0;
        end else if(RD_EN && !EMPTY) begin
            RD_DATA <= mem[rd_ptr[ADDR_WIDTH-1:0]];
            rd_ptr <= rd_ptr + 1;
        end
    end

    // Assign Full and Empty Flags
    assign FULL =
    (wr_ptr[ADDR_WIDTH] != rd_ptr[ADDR_WIDTH]) &&
    (wr_ptr[ADDR_WIDTH-1:0] == rd_ptr[ADDR_WIDTH-1:0]);

    assign EMPTY = (wr_ptr == rd_ptr);
endmodule