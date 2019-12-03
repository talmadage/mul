//Template code for CPU 


`define pc_increment 4


module CPU(
    input clk,
    input reset,
    input [31:0] idata,   // data from instruction memory
    output [31:0] iaddr,  // address to instruction memory
    
    input [31:0] drdata,  // data read from data memory
    output [31:0] daddr,  // address to data memory
    output [31:0] dwdata, // data to be written to data memory
    output [3:0] we,      // write enable signal for each byte of 32-b word
    
    // Additional outputs for debugging
    output [31:0] x31,
    output [31:0] pc   , 
	 output nop,
	 output stall,
	 output [31:0]imm
);  

//wire stall;

    wire [95:0] wire1;
    wire [192:0] wire2;
    wire [174:0] wire3;
    wire [37:0] wire4;
    reg [95:0] buf1;
    reg [192:0] buf2;
    reg [141:0] buf3;
    reg [37:0] buf4;
	 wire wireconstants;
assign daddr = buf3[102:71];

    stage1 I1(.clk(clk),.reset(reset),.idata(idata),.idata_out(wire1[63:32]),
        .address_predicted(wire1[95:64]),.branch_taken(wire3[110]),
        .branch_addr(wire3[142:111]),.iaddr(iaddr),.pc(wire1[31:0]),.stall(stall),.imm(imm[31:0]));

    stage2 I2 (.idata(buf1[63:32]),.branch_taken(wire3[110]),.state1(buf2[0]),
        .rd_sel(wire2[154:153]),.pc_sel(wire2[152:151]),.alu_in2_sel(wire2[7]),.op(wire2[6:1]),
        .imm(wire2[39:8]),.ld_st(wire2[160:156]),.rs1(wire2[108:104]),.rs2(wire2[113:109]),.rd(wire2[118:114]),
        .we_rf(wire2[155]),.next_state1(wire2[0]),
        .we_rf_prev(buf2[155]),.rd_sel_prev(buf2[154:153]),.rd_prev(buf2[118:114]),.stall(stall),.nop(nop),
		  .idata_EX(buf2[192:161]));

    RF R1(.rs1(wire2[108:104]),.rs2(wire2[113:109]),
        .clk(clk),.rv1(wire2[71:40]),.rv2(wire2[103:72]),.x31(x31),
        .rd(wire4[4:0]),.we(wire4[37]),.rwdata(wire4[36:5]));
    
    stage3 I3(.op(buf2[6:1]),
              .alu_in2_sel(buf2[7]),
              .imm(buf2[39:8]),
              .alu_out(wire3[102:71]),
              .rv1(buf2[71:40]),
              .rv2(buf2[103:72]),
              .rs1(buf2[108:104]),
              .rs2(buf2[113:109]),
              .rd_em(buf3[4:0]),
              .rwdata_em(buf3[36:5]),
              .rd_valid_em(buf3[37]),
              .rd_mw(buf4[4:0]),
              .rwdata_mw(buf4[36:5]),
              .rd_valid_mw(buf4[37]),
              .frv2(wire3[70:39]),
              .we_rf(buf2[155]),
              .rd_sel(buf2[154:153]),
              .rd_valid(wire3[37]),
              .rwdata(wire3[36:5]),
              .pc(buf2[150:119]),
              .pc_sel(buf2[152:151]),
              .branch_taken(wire3[110]),
              .branch_address(wire3[142:111]),
              .address_predicted(buf2[192:161])
              );

    stage4 I4(.rd_sel(buf3[109:108]),
              .rwdata_em(buf3[36:5]),
              .rv2(buf3[70:39]),
              .rwdata(wire4[36:5]),
              .ld_st(buf3[107:103]),
              .drdata(drdata),
              .we(we),
              .daddr(buf3[102:71]),
              .dwdata(dwdata)
              );

assign pc = wire1[31:0];

//propagation outside registers
assign wire2[192:161] = buf1[95:64];//idata
assign wire2[150:119] = buf1[31:0];//pc
assign wire3[174:143] = buf2[192:161]; //idata_EX
assign wire3[4:0] = buf2[118:114];//rd
assign wire3[38] = buf2[155];//we_rf
assign wire3[107:103] = buf2[160:156];//ld_st
assign wire3[109:108] = buf2[154:153];//rd_sel

assign wire4[4:0] = buf3[4:0];//rd
assign wire4[37] = buf3[38];//we_rf

always @(posedge clk) begin
    if(reset) begin
        buf1 <= 0;
        buf2 <= 0;
        buf3 <= 0;
        buf4 <= 0;
    end else begin
        if(stall) begin//stall = 1 is normal operation
            buf1 <= wire1;
        end
            buf2 <= wire2;
            buf3 <= wire3[109:0];
            buf4 <= wire4;
    end
end

endmodule
