module cpu_tb();

reg clk,reset;

wire [31:0] idata,iaddr;
wire [31:0] daddr,wdata;
wire [31:0] rdata,rdata_dmem,rdata_acc;
wire [3:0] we;
wire [31:0] x31,pc,imm;
wire stall;

wire enable_dmem, enable_acc;

CPU instance1(
    .clk(clk),
    .reset(reset),
    .idata(idata),
    .iaddr(iaddr),
    .drdata(rdata),
    .daddr(daddr),
    .dwdata(wdata),
    .we(we),
    .x31(x31),
    .pc(pc),
	 .nop(nop),
	 .stall(stall),
	 .imm(imm)
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

dmem instance4(.clk(~clk),
    .daddr(daddr),
    .dwdata(wdata),
    .we(we&{4{enable_dmem}}),
    .drdata(rdata_dmem)
    );

accumulator instance5(
    .clk(~clk),
    .reset(reset),
    .ce(enable_acc),
    .we(we!=0),
    .addr(daddr[3:2]),
    .wdata(wdata),
    .rdata(rdata_acc)
    );

always #5 clk = ~clk;

initial begin
    clk = 0;
    reset = 1;
    # 100;

    reset = 0;
end

endmodule