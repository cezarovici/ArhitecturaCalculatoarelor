module control_path(
    input clk,
    input res,
    input [6:0] opcode,

    output reg PCWriteCond,
    output reg PCWrite,
    output reg IorD,
    output reg MemRead,
    output reg MemWrite,
    output reg MemtoReg,
    output reg IRWrite,
    output reg RegWrite,
    output reg ALUSrcA,
    output reg [1:0] ALUSrcB,
    output reg [1:0] ALUOp,
    output reg PCSource
    );
        
    
    reg [3:0] cs;
    reg [3:0] ns;
    // FSM

    // {1} next state logic
    always @(cs or opcode) begin
    casex({cs, opcode})
        /// DIN STAREA 0
        11'b0000_xxxxxxx : ns = 4'b0001;
        
        // DIN STAREA 1
        // op pt lw sau sw
        11'b0001_0x00011: ns = 4'b0010;
        // op - R type
        11'b0001_011x011 : ns = 4'b0110;
        // op - BEQ
        11'b0001_1100011 : ns = 4'b1000;
        
        // DIN STAREA 2
        // lw
        11'b0010_0000011:ns = 4'b0011;
        // sw
        11'b0010_0100011:ns = 4'b0101;
        
        //DIN STAREA 6
        //  R type
        11'b0110_011x011: ns = 4'b0111;
        
        //DIN STAREA 3
        11'b0011_0000011: ns = 4'b0100;

        default: ns = 4'b0000;
    endcase
end

// {2} update next state
    always @(posedge clk) begin
    if(res)
        cs = 4'b0000;
    else
        cs = ns;
    end

// {3} output logic
    always @(cs) begin
       case({cs})
        4'b0000: {PCWriteCond, PCWrite, IorD, MemRead, MemWrite, MemtoReg, IRWrite, RegWrite, ALUSrcA, ALUSrcB, ALUOp, PCSource} = 14'b0_1_0_1_0_0_1_0_0_01_00_0;
        4'b0001: {PCWriteCond, PCWrite, IorD, MemRead, MemWrite, MemtoReg, IRWrite, RegWrite, ALUSrcA, ALUSrcB, ALUOp, PCSource} = 14'b0_0_0_0_0_0_0_0_0_10_00_0;
        4'b0010: {PCWriteCond, PCWrite, IorD, MemRead, MemWrite, MemtoReg, IRWrite, RegWrite, ALUSrcA, ALUSrcB, ALUOp, PCSource} = 14'b0_0_0_0_0_0_0_0_1_10_00_0;
        4'b0011: {PCWriteCond, PCWrite, IorD, MemRead, MemWrite, MemtoReg, IRWrite, RegWrite, ALUSrcA, ALUSrcB, ALUOp, PCSource} = 14'b0_0_1_1_0_0_0_0_0_00_00_0;
        4'b0100: {PCWriteCond, PCWrite, IorD, MemRead, MemWrite, MemtoReg, IRWrite, RegWrite, ALUSrcA, ALUSrcB, ALUOp, PCSource} = 14'b0_0_0_0_0_1_0_1_0_00_00_0;
        4'b0101: {PCWriteCond, PCWrite, IorD, MemRead, MemWrite, MemtoReg, IRWrite, RegWrite, ALUSrcA, ALUSrcB, ALUOp, PCSource} = 14'b0_0_1_0_1_0_0_0_0_00_00_0;
        4'b0110: {PCWriteCond, PCWrite, IorD, MemRead, MemWrite, MemtoReg, IRWrite, RegWrite, ALUSrcA, ALUSrcB, ALUOp, PCSource} = 14'b0_0_0_0_0_0_0_0_1_00_10_0;
        4'b0111: {PCWriteCond, PCWrite, IorD, MemRead, MemWrite, MemtoReg, IRWrite, RegWrite, ALUSrcA, ALUSrcB, ALUOp, PCSource} = 14'b0_0_0_0_0_0_0_1_0_00_00_0;
        4'b1000: {PCWriteCond, PCWrite, IorD, MemRead, MemWrite, MemtoReg, IRWrite, RegWrite, ALUSrcA, ALUSrcB, ALUOp, PCSource} = 14'b1_0_0_0_0_0_0_0_1_00_01_1;
        default: {PCWriteCond, PCWrite, IorD, MemRead, MemWrite, MemtoReg, IRWrite, RegWrite, ALUSrcA, ALUSrcB, ALUOp, PCSource} = 14'b0_0_0_0_0_0_0_0_0_00_00_0;
    endcase
end
     
endmodule
