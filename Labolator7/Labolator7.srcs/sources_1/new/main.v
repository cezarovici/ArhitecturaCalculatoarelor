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

module data_path(
	input clk,
	input res,
	
	input PCWriteCond,
	input PCWrite,
	input IorD,
	input MemRead,
	input MemWrite,
	input IRWrite,
	input RegDst,
	input RegWrite, 
	input ALUSrcA, 
	input [1:0] ALUSrcB, 
	input [1:0] ALUOp, 
	input PCSource,
	
	output [6:0] op_code
);

reg [31:0] PC;
reg [31:0] IR;

reg [31:0] ALUout;

reg [31:0] A;

reg [31:0] B;

reg [31:0] MDR;

reg [7:0] mem [0:1023];

reg [31:0] regs [0:31];

wire [31:0] addr_mem;

wire Zero;

wire [31:0] da;

wire [31:0] db;

reg [31:0] alu;

wire [31:0] opA;

wire [31:0] opB;

wire [4:0] rc;

reg [31:0] imm32;

assign Zero = (alu == 0) ? 1 : 0;

assign opA = (ALUSrcA == 1) ? A : PC;

assign opB = (ALUSrcB == 2'b00) ? 	B :
			 ((ALUSrcB == 2'b01) ? 	4 :
			 ((ALUSrcB == 2'b10) ? 	imm32 : 0 ));

// imm32 model
always@(IR) begin
	        case(IR[6:0])
            7'b0000011,
            7'b0001111,
            7'b0011011,
            7'b1100111,
            7'b1110011,
            7'b0010011: imm32 = { {20{IR[31]}}, IR[31:20]};
            7'b0100011: imm32 = { {20{IR[31]}}, IR[31:25], IR[11:7]};
            7'b1100011: imm32 = { {20{IR[31]}}, IR[7], IR[30:25], IR[11:8], 1'b0};            
            7'b1101111: imm32 = { {12{IR[31]}}, IR[19:12], IR[20], IR[30:25], IR[11:8], 1'b0};            
            7'b0010111,
            7'b0110111: imm32 = { IR[31:12], {12{1'b0}}}; 
            default:
                imm32 = 32'h0000_0000;
        endcase
end

// ALU model
always@(ALUOp or opA or opB or IR)
	casex({ALUOp, IR[31:25], IR[14:12]})
	
		// TBD
		12'b00_xxxxxxx_xxx,
		12'b10_0000000_000,
		12'b11_xxxxxxx_000: alu = opA + opB;
		
		12'b10_0100000_000,
		12'b01_xxxxxxx_xxx: alu = opA - opB;
		
		12'b10_0000000_111,
		12'b11_xxxxxxx_111: alu = opA & opB;
		
		12'b10_0000000_110,
		12'b11_xxxxxxx_110: alu = opA | opB;
		
		12'b10_0000000_100,
		12'b11_xxxxxxx_100: alu = opA ^ opB;
		
		default: alu = 32'b0; // !!! 
	endcase

// PC model
always@(posedge clk)
	if (res == 1) 
		PC <= 0;
	else
		casex({PCWrite, PCWriteCond, Zero, PCSource})
			4'b1_x_x_0: PC <= alu;
			4'b1_x_x_1: PC <= ALUout;
			4'b0_1_1_x: PC <= ALUout;
			
			default: PC <= PC;
		endcase

// IR model
always@(posedge clk)
	casex({res, IRWrite})
		2'b1_x : IR <= 0;
		2'b0_1 : begin 
			IR[31:24] 	<= mem[addr_mem+3];
			IR[23:16] 	<= mem[addr_mem+2];
			IR[15:8] 	<= mem[addr_mem+1];
			IR[7:0] 	<= mem[addr_mem];
			end
	endcase

assign addr_mem = (IorD == 0) ? PC : ALUout;

always@(posedge clk)
	ALUout <= alu;

always@(posedge clk)
	A <= da;

always@(posedge clk)
	B <= db;

always@(posedge clk) begin
	MDR[31:24] 	<= mem[addr_mem+3];
	MDR[23:16] 	<= mem[addr_mem+2];
	MDR[15:8] 	<= mem[addr_mem+1];
	MDR[7:0] 	<= mem[addr_mem];	
end

wire [4:0] ra = IR[ 19:15 ];

assign da = regs[ra];

wire [4:0] rb = IR[ 24:20];

assign db = regs[rb];	

assign rc = IR[ 11:7 ];

// Register file model
always@(posedge clk)
	if (res == 1) begin
		regs[0] <= 0; regs[1] <= 0; regs[2] <= 0; regs[3] <= 0; regs[4] <= 0; regs[5] <= 0;
		regs[6] <= 0; regs[7] <= 0; regs[8] <= 0; regs[9] <= 0; regs[10] <= 0; regs[11] <= 0;
		regs[12] <= 0; regs[13] <= 0; regs[14] <= 0; regs[15] <= 0; regs[16] <= 0; regs[17] <= 0;
		regs[18] <= 0; regs[19] <= 0; regs[20] <= 0; regs[21] <= 0; regs[22] <= 0; regs[23] <= 0;
		regs[24] <= 0; regs[25] <= 0; regs[26] <= 0; regs[27] <= 0; regs[28] <= 0; regs[29] <= 0;
		regs[30] <= 0; regs[31] <= 0;
	end else if (rc != 0 && RegWrite == 1) 
		regs[rc] <= MDR; 

// memory write operation
always@(posedge clk)
	if (MemWrite == 1) begin
		mem[addr_mem+3]	<= B[31:24];
		mem[addr_mem+2] <= B[23:16];
		mem[addr_mem+1] <= B[15:8];
		mem[addr_mem+0] <= B[7:0];	
	end
	
assign op_code = IR[6:0];
	
initial begin
	// mem init with some code and data
	// codul incepe la adresa 0 
	
	mem[3] = 8'h00; mem[2] = 8'h53; mem[1] = 8'h03; mem[0] = 8'hb3;  
	
	// datele sunt stocate de la adresa 256
	mem[259] = 8'h0; mem[258] = 8'h0; mem[257] = 8'b0; mem[256] = 8'h0;
end

endmodule
