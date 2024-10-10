`timescale 1ns / 1ps

module ram_1rw_tb;

    parameter int DATA_W = 16;
    parameter int DEPTH = 16;
    parameter int ADDR_W = $clog2(DEPTH);

    logic clk;
    logic we;
    logic[ADDR_W-1:0] addr;
    logic[DATA_W-1:0] w_data;
    logic[DATA_W-1:0] r_data;

    typedef logic[ADDR_W-1:0] addr_t;
    typedef logic[DATA_W-1:0] data_t;

    typedef struct packed {
        logic we_q;
        addr_t addr_q;
        data_t w_data_q;
        data_t ref_data_q;
    } imp_t;

    imp_t imp_q[$];

    ram_1rw #(
        .DATA_W(DATA_W),
        .DEPTH(DEPTH)
    )
    dut_u (
        .clk(clk),
        .we(we),
        .addr(addr),
        .w_data(w_data),
        .r_data(r_data)
        );

    int max_addr = int'(ADDR_W'('1));

    task sequential_iter;
        automatic data_t data_interm;
        automatic addr_t addr_interm;

        for (int i = 0; i <  max_addr; i++) begin
            data_interm = data_t'($urandom());
            addr_interm = addr_t'(i);
            imp_q.push_back({1'b1, addr_interm, data_interm, data_interm});
            imp_q.push_back({1'b0, addr_interm, data_interm, data_interm});
        end
    endtask

    task delayed_iter;
        automatic data_t data_interm;
        automatic addr_t addr_interm;
        automatic data_t data_q[$];

        for (int i = 0; i <  max_addr; i++) begin
            data_interm = data_t'($urandom());
            addr_interm = addr_t'(i);
            data_q.push_back(data_interm);
            imp_q.push_back({1'b1, addr_interm, data_interm, data_t'('0)});
        end


        for (int i = 0; i <  max_addr; i++) begin
            data_interm = data_q.pop_front();
            addr_interm = addr_t'(i);
            imp_q.push_back({1'b0, addr_interm, data_t'('0), data_interm});
        end
    endtask


    initial begin
        clk = '1;
        forever #5 clk = ~clk;
    end
    data_t ref_data;
    initial begin
        we = '0;
        #100;

        sequential_iter();

        delayed_iter();
        forever @(posedge clk) begin
            if ($size(imp_q) != 0) begin
                assert property (@(posedge clk) !we |-> r_data === ref_data)
                else $error("Error. Incorrect output data\n r_data = %h, ref_data = %h", r_data, ref_data);          

                {we, addr, w_data, ref_data} = imp_q.pop_front();
                $display($time, " we = %b, addr = %-d, w_data = %-h, r_data = %-h, ref_data = %h", we, addr, w_data, r_data, ref_data);
            end
            else
                $stop;
        end
    end
endmodule: ram_1rw_tb