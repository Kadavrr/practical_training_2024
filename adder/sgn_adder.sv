module sgn_adder #(
    parameter int DATA_W = 16,
    parameter int IMM_W = 6,
    parameter bit SIGN_EXT_TYPE = 1'b0
) (
    input logic[1:0] ctrl,
    input logic[DATA_W-1:0] in_d1,
    input logic[DATA_W-1:0] in_d2,
    input logic[IMM_W-1:0] in_imm,
    output logic[DATA_W:0] out_d
    );
    
    logic[DATA_W:0] in_add1;
    logic[DATA_W:0] in_add2;
    localparam int DIFF_W = DATA_W - IMM_W + 1;
    typedef logic [DATA_W:0] data_t;
    if (SIGN_EXT_TYPE == 1'b0) begin: cast_add
        always_comb begin
            case(ctrl)
                2'b00: begin
                    in_add1 = $signed(in_d1);
                    in_add2 = $signed(in_d2);
                end
                2'b01: begin
                    in_add1 = $signed(in_d1);
                    in_add2 = $signed(data_t'($signed(in_imm)));
                end
                2'b10: begin
                    in_add1 = $signed(data_t'($signed(in_imm)));
                    in_add2 = $signed(in_d2);
                end
                default begin
                    in_add1 = 'x;
                    in_add2 = 'x;
                end
            endcase
        end
    end:cast_add
    else begin:conc_add
        always_comb begin
            case(ctrl)
                2'b00: begin
                    in_add1 = {in_d1[DATA_W-1], in_d1};
                    in_add2 = {in_d2[DATA_W-1], in_d2};
                end
                2'b01: begin
                    in_add1 = {in_d1[DATA_W-1], in_d1};
                    in_add2 = {{DIFF_W{in_imm[IMM_W-1]}}, in_imm};
                end
                2'b10: begin
                    in_add1 = {{DIFF_W{in_imm[IMM_W-1]}}, in_imm};
                    in_add2 = {in_d2[DATA_W-1], in_d2};
                end
                default begin
                    in_add1 = 'x;
                    in_add2 = 'x;
                end
            endcase     
        end
    end:conc_add
    assign out_d = in_add1 + in_add2;
    
    
endmodule