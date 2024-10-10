`timescale 1ns / 1ps
module crossbar_tb;
    parameter int DATA_W = 16;
    parameter int N = 6;
    parameter int M = 4;
    parameter int NUM_IMP_GR = 6;
    localparam int ID_W = $clog2(N);
    logic[N-1:0] ireq;
    logic[DATA_W-1:0] idata[N];
    logic[M-1:0] oreq;
    logic[DATA_W-1:0] odata[M];
    logic[ID_W-1:0] oid[N];
    typedef logic[DATA_W-1:0] idata_u_t;
    typedef struct packed{
        bit ireq_q;
        idata_u_t idata_u_q;
    } inp_imp_t;
    inp_imp_t imp_q[$];
    crossbar #(
        .DATA_W(DATA_W),
        .N(N),
        .M(M)
    )
    dut_u (
        .ireq(ireq),
        .idata(idata),
        .oreq(oreq),
        .odata(odata),
        .oid(oid)
        );
    task queuing;
        for (int i = 0; i < NUM_IMP_GR * N; i++) begin
            imp_q.push_back({bit'($urandom_range('0, N)), idata_u_t'($urandom())});
        end
    endtask
    task displaying;
        $display("Input impacts: \n");
        for (int i = 0; i < N; i++) begin
            $display($time, " ireq[%-d] = %b, idata [%-d] = %d, oid[%-d] = %d", i, ireq[i], i, idata[i], i, oid[i]);
        end
        $display("\nResults:\n");
        for (int i = 0; i < M; i++) begin
            $display($time, " oreq[%-d] = %b, odata [%-d] = %d", i, oreq[i], i, odata[i]);
        end
        $display("\n");
    endtask
    task checking;
        automatic int last_out = 0;
        for (int i = 0; i < N; i++) begin
            if (last_out < M) begin
                if (ireq[i] == 1'b1) begin 
                    assert (odata[last_out] === idata[i])
                    else $error("Error. Incorrect data. odata = %d, idata = %d", odata[last_out], odata[i]);
                    assert (oreq[last_out] == 1'b1)
                    else $error("Error. Incorrect req signal. oreq = %b", oreq[last_out]);
                    last_out++;
                end
                assert (ireq[i] ? idata[i] == odata[oid[i]]  : 1)
                else $error("Error. Output does not match intput\n");
            end
        end
    endtask
    initial begin
        queuing();
        while ($size(imp_q) != 0) begin
            for (int i = 0; i < N; i++)
                {ireq[i], idata[i]} = {imp_q.pop_front()}; 
            #10;
            displaying();
            checking();
        end
    end
endmodule : crossbar_tb