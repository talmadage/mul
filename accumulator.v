module accumulator(
	input clk, reset, // This reset is same as the one given to CPU
	input ce,		// 1 if the daddr is in the 16 addresses mapped to this
	input we,       // need to convert 4 bit we to 1 bit we
	input [1:0] addr,	// addr[1:0] = daddr[3:2], daddr[1:0] are ignored
	input [31:0] wdata, // connected directly from CPU
	output reg [31:0] rdata //goes to arbiter
);
	reg [31:0] sum;
	reg [31:0] count; // Reduce this if not necessary
	initial begin
		sum <= 0;
		count <= 0;
	end

	always @ (posedge clk) begin
		if (reset) begin
			sum <= 0;
			count <= 0;
			rdata <= 0;

		end else begin 
			// sum <= sum;
			// count <= count;
			rdata <= 0;
			casez ({ce,we,addr})
				// we is ignored for reads
				4'b1100 : begin sum <= 0; count <= 0; end //reset for Base +0 
				4'b1101 : begin sum <= sum + wdata; count <= count + 1; end // accumulate for base +4
				4'b1z10 : begin rdata <= sum; end // return sum for BAse +8
				4'b1z11 : begin rdata <= count; end // return count for Base +12
			endcase
		end
	end
	
endmodule