module tb_top;
    localparam int WIDTH = 32;

    logic clk;
    logic reset;

    top #(.WIDTH(WIDTH)) dut (
        .clk(clk),
        .reset(reset)
    );

    always #5 clk = ~clk;

    initial begin
        clk = 1'b0;
        reset = 1'b1;

        // Assembly translation of imem.txt:
        // 0:  ADD r1, r0, #10      ; R1 = 10 (0x0A)
        // 1:  ADD r2, r0, #20      ; R2 = 20 (0x14)
        // 2:  ADD r3, r1, r2       ; R3 = 30 (0x1E)
        // 3:  SUB r4, r3, r1       ; R4 = 20 (0x14)
        // 4:  STR r4, [r0, #12]    ; DMEM[3] = 20
        // 5:  LDR r5, [r0, #12]    ; R5 = 20
        // 6:  ADD r6, r5, r2       ; R6 = 40 (0x28)
        // 7:  ORR r7, r6, #15      ; R7 = 40 | 15 = 47 (0x2F)
        // 8:  ADD r8, r0, #3       ; R8 = 3
        // 9:  BIC r9, r7, r8       ; R9 = 47 & ~3 = 44 (0x2C)
        // 10: EOR r10, r9, r6      ; R10 = 44 ^ 40 = 4 (0x04)
        // 11: AND r11, r10, r4     ; R11 = 4 & 20 = 4 (0x04)
        // 12: B +2                 ; Branch Target = PC+8 + (2*4).
        // 13: ADD r12, r0, #1      ; FLUSHED
        // 14: ADD r12, r0, #2      ; FLUSHED
        // 15: ADD r12, r0, #3      ; FLUSHED
        // 16: ADD r12, r0, #100    ; R12 = 100 (0x64)
        // 17: STR r12, [r0, #16]   ; DMEM[4] = 100
        // 18: B -2                 ; HALT

        #20;
        reset = 1'b0;


        repeat (60) @(posedge clk);

        $display("--- SIMULATION RESULTS ---");
        $display("Memory checks:");
        $display("DMEM[3] (Expected 00000014) = %h", dut.u_dmem.RAM[3]);
        $display("DMEM[4] (Expected 00000064) = %h", dut.u_dmem.RAM[4]);
        
        $display("\nRegister checks:");
        $display("RF r3  (Expected 0000001e) = %h", dut.u_arm.dp.rf.rf[3]);
        $display("RF r6  (Expected 00000028) = %h", dut.u_arm.dp.rf.rf[6]);
        $display("RF r9  (Expected 0000002c) = %h", dut.u_arm.dp.rf.rf[9]);
        $display("RF r11 (Expected 00000004) = %h", dut.u_arm.dp.rf.rf[11]);
        $display("RF r12 (Expected 00000064) = %h", dut.u_arm.dp.rf.rf[12]);
        $display("--------------------------");
    end
endmodule