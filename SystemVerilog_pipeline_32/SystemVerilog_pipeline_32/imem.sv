module imem #(
    parameter int WIDTH = 32,
    parameter int DEPTH = 256
) (
    input  logic [WIDTH-1:0] a,
    output logic [WIDTH-1:0] rd
);
    logic [WIDTH-1:0] RAM [0:DEPTH-1];
    integer i;

    initial begin
        for (i = 0; i < DEPTH; i = i + 1) begin
            RAM[i] = '0;
        end
        $readmemh("imem.txt", RAM);
    end

    assign rd = RAM[a[WIDTH-1:2]];
endmodule
