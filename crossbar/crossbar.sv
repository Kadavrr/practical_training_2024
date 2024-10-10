module crossbar #(
    parameter int DATA_W = 16,
    parameter int N = 7,
    parameter int M = 6,
    parameter int ID_W = $clog2(N)
) (
    input logic[N-1:0] ireq,
    input logic[DATA_W-1:0] idata[N],
    output logic[M-1:0] oreq,
    output logic[DATA_W-1:0] odata[M],
    output logic[ID_W-1:0] oid[N]
    );
    typedef logic[ID_W-1:0] oid_u_t; 
    if (N < M) $fatal("Error. Incorrect number of inputs or outputs");
    logic[ID_W-1:0] ireq_cnt;
    always_comb begin
        ireq_cnt = '0;
        oreq = '0;
        for (int j = 0; j < M; j++)
            odata[j] = 'x;
        for (int i = 0; i < N; i++) begin
            oid[i] = 'x;
            if (ireq_cnt < M) begin
                oid[i] = oid_u_t'(ireq_cnt);
                odata[ireq_cnt] = idata[i];
                oreq[ireq_cnt] = 1'b1;
            end
            if (ireq[i])
                ireq_cnt++;
        end
   end
endmodule : crossbar