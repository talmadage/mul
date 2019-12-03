module shifter(
    //dec
    input [31:0] rv2,
    output reg [31:0] mod_drdata,
    input [4:0] ld_st,

    //dmem
    input [31:0] daddr,
    input [31:0] drdata,
    output reg [3:0] we,
    output reg [31:0] dwdata
);

    always @(*) begin
    dwdata<=0;
    mod_drdata<=0;
    we<=0;

    casez({ld_st[1:0],daddr[1:0]})//storing into dmem
        4'b0100: begin dwdata[7:0]  <=rv2[7:0];  we<=1; end
        4'b0101: begin dwdata[15:8] <=rv2[7:0];  we<=2; end
        4'b0110: begin dwdata[23:16]<=rv2[7:0];  we<=4; end
        4'b0111: begin dwdata[31:24]<=rv2[7:0];  we<=8; end
        4'b100z: begin dwdata[15:0] <=rv2[15:0]; we<=3; end
        4'b101z: begin dwdata[31:16]<=rv2[15:0]; we<=12; end
        4'b11zz: begin dwdata<=rv2; we<=15; end
    endcase
    
    casez({ld_st[3:2],daddr[1:0]})//loading from dmem
        //ld_st[4] = 1 implies unsigned 
        4'b0100: mod_drdata <= {{24{ld_st[4]? 1'b0:drdata[7]}},drdata[7:0]};
        4'b0101: mod_drdata <= {{24{ld_st[4]? 1'b0:drdata[15]}},drdata[15:8]};
        4'b0110: mod_drdata <= {{24{ld_st[4]? 1'b0:drdata[23]}},drdata[23:16]};
        4'b0111: mod_drdata <= {{24{ld_st[4]? 1'b0:drdata[31]}},drdata[31:24]};
        4'b100z: mod_drdata <= {{16{ld_st[4]? 1'b0:drdata[15]}},drdata[15:0]};
        4'b101z: mod_drdata <= {{16{ld_st[4]? 1'b0:drdata[31]}},drdata[31:16]};
        4'b11zz: mod_drdata <= drdata;
        // default: mod_drdata <= 0;
    endcase

    end
endmodule