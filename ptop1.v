`timescale 1ns / 1ps
//Implementation Testbench for DMEM

module top(
    input clk
    ); //Only input from the outside is clock
	

wire man_clk,reset;

wire [31:0] idata,iaddr;
wire [31:0] daddr,wdata;
wire [31:0] rdata,rdata_dmem,rdata_acc;
wire [3:0] we;
wire [31:0] x31,pc;

wire enable_dmem, enable_acc;

CPU instance1(
    .clk(man_clk),
    .reset(reset),
    .idata(idata),
    .iaddr(iaddr),
    .drdata(rdata),
    .daddr(daddr),
    .dwdata(wdata),
    .we(we),
    .x31(x31),
    .pc(pc)
    );

imem instance2(.idata(idata),
            .iaddr(iaddr)
            );

arbiter instance3(.addr(daddr),
                .rdata_dmem(rdata_dmem),//data read from dmem
                .rdata_acc(rdata_acc),
                .rdata_mas(rdata),      // data sent to master
                .enable1(enable_dmem),
                .enable2(enable_acc)
                );

dmem instance4(.clk(~man_clk),
    .daddr(daddr),
    .dwdata(wdata),
    .we(we&{4{enable_dmem}}),
    .drdata(rdata_dmem)
    );

accumulator instance5(
    .clk(~man_clk),
    .reset(reset),
    .ce(enable_acc),
    .we(we!=0),
    .addr(daddr[3:2]),
    .wdata(wdata),
    .rdata(rdata_acc)
    );


wire [35:0] VIO_CONTROL;

iconk instanceB (
	 //Input-output ports controlled by VIO and ILA
	//Control wires used by ICON to control VIO and ILA
	//.CONTROL0(ILA_CONTROL), // INOUT BUS [35:0]
    .CONTROL0(VIO_CONTROL) // INOUT BUS [35:0]
);

viok instanceC(
    .CONTROL(VIO_CONTROL), // INOUT BUS [35:0]
	.CLK(clk),
    .SYNC_OUT({man_clk,reset}),// 2bits
    .SYNC_IN({we,iaddr,idata,daddr,drdata,dwdata,x31,pc})//BUS[224+3:0]
);

/*
ila0 instanceE (
    .CONTROL(ILA_CONTROL), // INOUT BUS [35:0]
    .CLK(clk), // IN
    .TRIG0(outdata)// IN BUS [31:0]	
	
);
*/
endmodule

/*
UCF statement to be added in constraints file-
NET "clk" LOC = "C9"  | IOSTANDARD = LVCMOS33 ;
*/
 