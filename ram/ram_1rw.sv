module ram_1rw #(
    parameter int DATA_W = 16,
    parameter int DEPTH = 16,
    parameter int ADDR_W = $clog2(DEPTH),
    parameter bit SYNC_READ = 1'b1
) (
    input logic clk,
    input logic we,
    input logic[ADDR_W-1:0] addr,
    input logic[DATA_W-1:0] w_data,
    output logic[DATA_W-1:0] r_data
    );
    logic[DATA_W-1:0] mem[DEPTH-1:0];
    always_ff @(posedge clk) begin
            if (we)
                mem[addr] <= w_data;
    end
    if (SYNC_READ) begin 
        always_ff @(posedge clk) begin
            if (~we)
                r_data <= mem[addr];
        end
    end 
    else begin
        assign r_data = mem[addr];
    end
endmodule: ram_1rw