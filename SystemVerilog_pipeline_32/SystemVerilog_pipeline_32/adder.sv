module adder #(
    parameter int WIDTH = 32
) (
    input  logic [WIDTH-1:0] a,
    input  logic [WIDTH-1:0] b,
    output logic [WIDTH-1:0] y
);
    assign y = a + b;
endmodule
