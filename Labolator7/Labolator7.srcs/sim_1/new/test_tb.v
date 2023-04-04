module tb_top(

);
    reg clk;
    reg res;
    reg [6:0] opcode;
    
    wire PCWriteCond;
    wire PCWrite;
    wire IorD;
    wire MemRead;
    wire MemWrite;
    wire MemtoReg;
    wire IRWrite;
    wire RegWrite;
    wire ALUSrcA;
    wire [1:0] ALUSrcB;
    wire [1:0] ALUOp;
    wire PCSource;

control_path DUT(
    .clk(clk),
    .res(res),
    .PCWriteCond(PCWriteCond),
    .PCWrite(PCWrite),
    .IorD(IorD),
    .MemRead(MemRead),
    .MemWrite(MemWrite),
    .MemtoReg(MemtoReg),
    .IRWrite(IRWrite),
    .RegWrite(RegWrite),
    .ALUSrcA(ALUSrcA),
    .ALUSrcB(AluSrcB),
    .ALUOp(ALUOp),
    .PCSource(PCSource)
    
);

initial begin
clk = 0; res = 0; 
opcode = 7'b0000011;
#10 res = 1;
#10 res = 0;
#200 $finish;
end

always #5 clk = ~clk;

endmodule