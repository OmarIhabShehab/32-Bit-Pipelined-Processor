module top #(
    parameter int WIDTH = 32
) (
    input logic clk,
    input logic reset
);
    logic [WIDTH-1:0] PC;
    logic [31:0]      Instr;
    logic             MemWrite;
    logic [WIDTH-1:0] ALUResult;
    logic [WIDTH-1:0] WriteData;
    logic [WIDTH-1:0] ReadData;

    arm #(.WIDTH(WIDTH)) u_arm (
        .clk(clk),
        .reset(reset),
        .PC(PC),
        .Instr(Instr),
        .MemWrite(MemWrite),
        .ALUResult(ALUResult),
        .WriteData(WriteData),
        .ReadData(ReadData)
    );

    imem #(.WIDTH(WIDTH)) u_imem (
        .a(PC),
        .rd(Instr)
    );

    dmem #(.WIDTH(WIDTH)) u_dmem (
        .clk(clk),
        .we(MemWrite),
        .a(ALUResult),
        .wd(WriteData),
        .rd(ReadData)
    );
endmodule
