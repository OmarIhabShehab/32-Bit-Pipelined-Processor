module hazard_unit (
    input  logic [3:0] RA1D,
    input  logic [3:0] RA2D,
    input  logic [3:0] RA1E,
    input  logic [3:0] RA2E,
    input  logic [3:0] WA3E,
    input  logic [3:0] WA3M,
    input  logic [3:0] WA3W,
    input  logic       RegWriteM,
    input  logic       RegWriteW,
    input  logic       MemtoRegE,
    input  logic       PCSrcD,
    input  logic       PCSrcE,
    input  logic       PCSrcM,
    input  logic       PCSrcW,
    input  logic       BranchTakenE,
    output logic [1:0] ForwardAE,
    output logic [1:0] ForwardBE,
    output logic       StallD,
    output logic       StallF,
    output logic       FlushD,
    output logic       FlushE
);
    logic Match_1E_M;
    logic Match_1E_W;
    logic Match_2E_M;
    logic Match_2E_W;
    logic Match_12D_E;
    logic LDRstall;
    logic PCWrPendingF;

    assign Match_1E_M = (RA1E == WA3M);
    assign Match_1E_W = (RA1E == WA3W);
    assign Match_2E_M = (RA2E == WA3M);
    assign Match_2E_W = (RA2E == WA3W);

    always_comb begin
        if (Match_1E_M & RegWriteM)      ForwardAE = 2'b10;
        else if (Match_1E_W & RegWriteW) ForwardAE = 2'b01;
        else                             ForwardAE = 2'b00;

        if (Match_2E_M & RegWriteM)      ForwardBE = 2'b10;
        else if (Match_2E_W & RegWriteW) ForwardBE = 2'b01;
        else                             ForwardBE = 2'b00;
    end

    assign Match_12D_E = (RA1D == WA3E) | (RA2D == WA3E);
    assign LDRstall    = Match_12D_E & MemtoRegE;
    assign PCWrPendingF = PCSrcD | PCSrcE | PCSrcM;

    assign StallD = LDRstall;
    assign StallF = LDRstall | PCWrPendingF;
    assign FlushE = LDRstall | BranchTakenE;
    assign FlushD = PCWrPendingF | PCSrcW | BranchTakenE;
endmodule
