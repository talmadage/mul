module stage2(
	input [31:0] idata,// from IF_ID buffer
	input branch_taken, state1, // for discard instructions due to branch
	input [31:0]idata_EX,
    output [1:0] rd_sel,//
    output reg [1:0] pc_sel,
	//ALU
	output alu_in2_sel,
	output [5:0] op,
	output [31:0] imm,
	//DMEM
	output reg [4:0] ld_st,
  	//RF
  	output [4:0] rs1,rs2,rd,
    output reg we_rf,           // we for rf
	
	output reg next_state1,

	input we_rf_prev,
	input [1:0] rd_sel_prev,
	input [4:0] rd_prev,
	output reg nop,
	output reg stall

);
	//reg nop;
	wire [4:0] ld_st_d;//from decoder
	wire we_rf_d;	   //from decoder
	wire [1:0] pc_sel_d;//from decoder

	Decoder dut(.idata(idata),.op(op),.alu_in2_sel(alu_in2_sel),.imm(imm),
			.ld_st(ld_st_d),.rd_sel(rd_sel),.pc_sel(pc_sel_d),.we_rf(we_rf_d));


	assign rs1 = idata[19:15];
	assign rs2 = idata[24:20];
	assign rd  = idata[11:7];

	always @ (*) begin
		//hazard detection unit
		//case(((rd_sel_prev)&&(we_rf_prev)&&((rs1==rd_prev)||((alu_in2_sel==0||ld_st_d[1:0]!=0)&&(rs2==rd_prev)))/*||((idata[6:0]==7'b1100011))*/))
		case(((idata[6:0] == 7'b0000011)||((idata_EX[6:0]==7'b0000011)&&((idata_EX[11:7] == rs1 || ((idata_EX[11:7] == rd) && (idata[6:0] != 7'b0000011)))))))
			1'b0 : stall <= 1; // normal operation
			1'b1 : stall <= 0; //hazard detected
		endcase

		//state machine for branching
		casez({branch_taken,state1})//cancelling(discarding) last two instructions
			2'b1z : begin next_state1 <= 1; nop <= 1; end
			2'b01 : begin next_state1 <= 0; nop <= 1; end
			2'b00 : begin next_state1 <= 0; nop <= 0; end		
		endcase

		case({nop})//setting the control signals to zero
			1'b0: begin we_rf<=we_rf_d; ld_st<=ld_st_d;pc_sel<=pc_sel_d; end
			//1'b0: begin we_rf<=we_rf_d; ld_st<=ld_st_d;pc_sel<=pc_sel_d; end
			default: begin we_rf<=0; ld_st<=0;pc_sel<=0; end
		endcase
		if (nop) begin
			we_rf<=0;
			ld_st<=0;
			pc_sel<=0;
		end else begin
			we_rf<=we_rf_d;
			ld_st<=ld_st_d;
			pc_sel<=pc_sel_d;
			end
	end
	
endmodule
