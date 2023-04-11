module tb_top(

);
    reg clk;
    reg res;
    reg PCWriteCond;
    reg PCWrite;
    reg IorD;
    reg  MemRead;
    reg MemWrite;
    reg IRWrite;
    reg RegDst;
    reg RegWrite;
    reg ALUSrcA;
    reg [1:0]ALUSrcB;
    reg  [1:0]ALUOp;
    reg  PCSource;
    
    wire [6:0]op_code;
   
   data_path DUT( clk,res,

    PCWriteCond,
    PCWrite,
    IorD,
    MemRead,
    MemWrite,
    IRWrite,
    RegDst,
    RegWrite,
    ALUSrcA,
    ALUSrcB,
     ALUOp,
     PCSource,
    
    op_code);
    
   initial begin
   
   clk=0;
   res=0;

    PCWriteCond=0;
    PCWrite=0;
    IorD=0;
    MemRead=0;
    MemWrite=0;
    IRWrite=0;
    RegDst=0;
    RegWrite=0;
    ALUSrcA=0;
    ALUSrcB=0;
    ALUOp=0;
    PCSource=0;
    
    
     #10 res =1;
     #10 res =0;
     
     MemRead = 1;
     IRWrite = 1;
     ALUSrcB = 2'b01;
     PCWrite = 1;
     
     #10
      MemRead = 0;
     IRWrite = 0;
     ALUSrcB = 2'b00;
     PCWrite = 0;
     
     
     #100 $finish;

end

always #5 clk=~clk;

endmodule