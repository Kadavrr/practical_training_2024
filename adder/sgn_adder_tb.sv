`timescale 1ns / 1ps
module sgn_adder_tb;
    parameter int DATA_W = 16;
    parameter int IMM_W = 6;
    parameter bit SIGN_EXT_TYPE = 1'b0;
    localparam bit VERIF_METHOD = 1'b1;
    logic[DATA_W:0] out_d;
    logic[1:0] ctrl;
    logic[IMM_W-1:0] in_imm;
    logic[DATA_W-1:0] in_d1;
    logic[DATA_W-1:0] in_d2;
    logic[DATA_W:0] ref_out_d;
    logic[1:0] ctrl_a;
    integer in_imm_a;
    integer in_d1_a;
    integer in_d2_a;
    integer in_d1_q[$];
    integer in_d2_q[$];
    integer in_imm_q[$];
    logic[1:0] ctrl_q[$];
    typedef logic[DATA_W:0] data_t;
    typedef logic[1:0] ctrl_t;
    typedef logic[DATA_W-1:0] in_data_t;
    typedef logic[IMM_W-1:0] imm_t;
    sgn_adder #(
        .DATA_W(DATA_W),
        .IMM_W(IMM_W),
        .SIGN_EXT_TYPE(SIGN_EXT_TYPE)
    )
    dut_u (.ctrl(ctrl),
        .in_imm(in_imm),
        .in_d1(in_d1),
        .in_d2(in_d2),
        .out_d(out_d)
    );
    function logic[DATA_W:0] adding;
        input integer in_d1_a, in_d2_a;
        input integer in_imm_a;
        input logic[1:0] ctrl_a;
        if      (ctrl_a == '0)    return data_t'(in_d1_a + in_d2_a);
        else if (ctrl_a == 2'b01) return data_t'(in_d1_a + in_imm_a);
        else if (ctrl_a == 2'b10) return data_t'(in_imm_a + in_d2_a);
        else                      return data_t'('x);
    endfunction
    task checking;
        assert (ref_out_d === out_d) 
        else begin
            $error("Error. Incorrect addition result");
            $display("ref_out_d = %b, out_d = %b\n\n", ref_out_d, out_d);
        end
    endtask
    task iterate; 
        $monitor ($time, " ctrl = %d, in_d1 = %b, in_d2 = %b, in_imm = %b, out_d = %b, checking_result = %b\n", 
        ctrl, in_d1, in_d2, in_imm, out_d, adding(integer'($signed(in_d1)), integer'($signed(in_d2)), integer'($signed(in_imm)), ctrl));
        for (int i = 0; i <= 'b11; i++) begin
            ctrl = ctrl_t'(i);
            for (int j = 0; j <= 'h3F; j++) begin
                in_imm = imm_t'(j);
                for (int k = 0; k <= 'hFFFF; k++) begin
                    in_d2 = in_data_t'(k);
                    for (int l = 0; l <= 'hFFFF; l++) begin
                        in_d1 = in_data_t'(l);
                        ref_out_d = adding(integer'($signed(in_d1)), integer'($signed(in_d2)), integer'($signed(in_imm)), ctrl);
                        #10;
                        checking;
                    end
                end
            end
        end
    endtask
    initial begin
        if (VERIF_METHOD == 1'b1) begin
            bit empty;
            $monitor ($time, " ctrl = %d, in_d1 = %b, in_d2 = %b, in_imm = %b, out_d = %b, checking_result = %b\n", 
            ctrl, in_d1, in_d2, in_imm, out_d, adding(in_d1_a, in_d2_a, in_imm, ctrl_a));
            for (int k = 0; k < 100; k++) begin
                in_d1_q.push_back(integer'($signed(in_data_t'($urandom_range(16'h0, 16'hFFFF)))));
                in_d2_q.push_back(integer'($signed(in_data_t'($urandom_range(16'h0, 16'hFFFF)))));
                in_imm_q.push_back(integer'($signed(imm_t'($urandom_range(6'h0, 6'h3F)))));
                ctrl_q.push_back(ctrl_t'($urandom_range(2'b00, 2'b11)));
                in_d1_a = in_d1_q.pop_front();
                in_d2_a = in_d2_q.pop_front();
                in_imm_a = in_imm_q.pop_front();
                ctrl_a = ctrl_t'(ctrl_q.pop_front());
                in_d1 = in_data_t'(in_d1_a);
                in_d2 = in_data_t'(in_d2_a);
                in_imm = imm_t'(in_imm_a);
                ctrl = ctrl_a;
                ref_out_d = adding(in_d1_a, in_d2_a, in_imm_a, ctrl_a);
                #10;

                checking;
            end
        end
        else begin
            iterate();
        end
    end
endmodule