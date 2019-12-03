module forwarder(
	input [4:0] rs1,rs2,  // registers to be forwarded
	
	input [4:0] rd1,rd2,		//1 has high priority than 2
	//input [31:0] rwdata1,rwdata2,	// possible replacement for rv1,rv2
	input rd_valid1,rd_valid2,	
	
	output reg [1:0] rv1_sel,rv2_sel
);
	always @(*) begin
		//frv1 update
		if (rs1==rd1 && rd_valid1==1)
			// frv1<=rwdata1;
			rv1_sel<=1;
		else if (rs1==rd2 && rd_valid2==1) 
			// frv1<=rwdata2;
			rv1_sel<=2;	
		else
			// frv1<=rv1;
			rv1_sel<=0;
		//frv2 update
		if (rs2==rd1 && rd_valid1==1)
			rv2_sel<=1;// frv2<=rwdata1;
		else if (rs2==rd2 && rd_valid2==1) 
			rv2_sel<=2;//frv2<=rwdata2;
		else
			rv2_sel<=0;//frv2<=rv2;
	end

endmodule