module flopenr #(
    parameter int WIDTH = 8
) (
    input  logic             clk,
    input  logic             reset,
    input  logic             en,
    input  logic [WIDTH-1:0] d,
    output logic [WIDTH-1:0] q
);
    always_ff @(posedge clk or posedge reset) begin
        if (reset)      q <= '0;
        else if (en)    q <= d;
    end
endmodule
