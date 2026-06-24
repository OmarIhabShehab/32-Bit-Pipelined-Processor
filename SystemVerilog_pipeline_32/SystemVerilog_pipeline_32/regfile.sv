module regfile #(
    parameter int WIDTH = 32
) (
    input  logic             clk,
    input  logic             we3,
    input  logic [3:0]       a1,
    input  logic [3:0]       a2,
    input  logic [3:0]       a3,
    input  logic [WIDTH-1:0] wd3,
    input  logic [WIDTH-1:0] r15,
    output logic [WIDTH-1:0] rd1,
    output logic [WIDTH-1:0] rd2
);
    logic [WIDTH-1:0] rf [0:14];
    integer i;

    initial begin
        for (i = 0; i < 15; i = i + 1) begin
            rf[i] = '0;
        end
    end

    always @(negedge clk) begin
        if (we3 && (a3 != 4'd15)) rf[a3] <= wd3;
    end

    always_comb begin
        if (a1 == 4'd15) rd1 = r15;
        else             rd1 = rf[a1];

        if (a2 == 4'd15) rd2 = r15;
        else             rd2 = rf[a2];
    end
endmodule
