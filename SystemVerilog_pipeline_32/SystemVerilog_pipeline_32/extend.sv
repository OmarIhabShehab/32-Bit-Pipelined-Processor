module extend #(
    parameter int WIDTH = 32
) (
    input  logic [23:0]      instr_imm,
    input  logic [1:0]       immsrc,
    output logic [WIDTH-1:0] extimm
);
    always_comb begin
        unique case (immsrc)
            2'b00: extimm = {{(WIDTH-8){1'b0}}, instr_imm[7:0]};
            2'b01: extimm = {{(WIDTH-12){1'b0}}, instr_imm[11:0]};
            2'b10: extimm = {{(WIDTH-26){instr_imm[23]}}, instr_imm[23:0], 2'b00};
            default: extimm = '0;
        endcase
    end
endmodule
