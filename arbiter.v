module arbiter(
	input [31:0] addr,
	// input [3:0] we,
	// output we1,
	// input [31:0] wdata_mas,
	// output reg [31:0] wdata,
    input [31:0] rdata_dmem,
    input [31:0] rdata_acc,
    output reg [31:0] rdata_mas,
    output reg enable1, enable2
);
	
always @ (*) begin
	enable1 <= 0;
	enable2 <= 0;
	rdata_mas <= 0;

	// assign we1 = we4==4'b1111;

	if ((addr&32'hffffff80)==32'h00000000) begin //0 + 7bits for dmem 
		enable1 <= 1;
		rdata_mas <= rdata_dmem;
	end	

	if ((addr&32'hfffffff0)==32'h00000200) begin //512 + 4bits for accumulator
		enable2 <= 1;
		rdata_mas <= rdata_acc; 
	end
end

endmodule
