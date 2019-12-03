module stage4(
	//mux for rwdata
	input [1:0] rd_sel,
	input [31:0] rwdata_em,
	input [31:0] rv2,
	output reg [31:0] rwdata,

    //shifter
	input [31:0] daddr,
    input [4:0] ld_st,
	input [31:0] drdata,
	output [3:0] we,
	output [31:0] dwdata
);
	wire [31:0] mod_drdata;

	shifter s1(.rv2(rv2),.mod_drdata(mod_drdata),.ld_st(ld_st),.daddr(daddr),
			   .drdata(drdata),.we(we),.dwdata(dwdata));
	
	always @(*) begin
		casez(rd_sel)
			2'b01 : rwdata <= mod_drdata;
			default : rwdata <= rwdata_em;
		endcase
	end
endmodule