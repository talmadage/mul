`define pc_increment 4

module stage3(
    //for alu
    input [5:0] op,
    input alu_in2_sel,
    input [31:0] imm, // from decode stage
    output [31:0] alu_out,
    
    // for forwarder
    input [31:0] rv1, rv2,
    input [4:0] rs1,rs2,
    //ex_mem(em)
    input [4:0] rd_em,
    input [31:0] rwdata_em,
    input rd_valid_em,  
    //mem_wb(mw)
    input [4:0] rd_mw,
    input [31:0] rwdata_mw,
    input rd_valid_mw,

    output reg [31:0] frv2,// forwarded to dmem(reg), alu(wire)
    //rwdata
    input we_rf,//mand
    input [1:0] rd_sel,
    output reg rd_valid,
    output reg [31:0] rwdata,
    //pc
    input [31:0] pc,
    input [1:0] pc_sel,
    input [31:0] address_predicted,
    output reg branch_taken,
    output reg [31:0] branch_address

);
    reg [31:0] in2;
    reg [31:0] frv1;
    wire [1:0] rv1_sel,rv2_sel;
    ALU32 a1(.in1(frv1),.in2(in2),.op(op),.out(alu_out));

    forwarder alu_f1(.rs1(rs1),.rs2(rs2),.rd1(rd_em),.rd2(rd_mw),
        .rd_valid1(rd_valid_em),.rd_valid2(rd_valid_mw),
        .rv1_sel(rv1_sel),.rv2_sel(rv2_sel));

    always @(*) begin
        //forwarding
        case(rv1_sel)
            1: frv1 <= rwdata_em;
            2: frv1 <= rwdata_mw;
            default: frv1 <= rv1;
        endcase

        case(rv2_sel)
            1: frv2 <= rwdata_em;
            2: frv2 <= rwdata_mw;
            default: frv2 <= rv2;
        endcase

        case(alu_in2_sel)
            1'b0: in2<=frv2;
            1'b1: in2<=imm;
        endcase

        //logic for rwdata
        rd_valid <= 0;
        rwdata <= 0;
            case({we_rf,rd_sel})
                3'b100 : begin rd_valid<=1; rwdata<=alu_out; end          // from alu
                3'b110 : begin rd_valid<=1; rwdata<=pc+`pc_increment; end // JAL
                3'b111 : begin rd_valid<=1; rwdata<=pc+imm; end // JALR
            endcase
        
        
        // logic for branch_address
        // pc is updated accordingly outside the stage3
        //branch_taken <= 0; // 1=> branch took place
        casez(pc_sel)
            2'b00 : begin branch_address <= pc+`pc_increment; end 
            2'b01 : begin branch_address <= pc+imm; end//Jump           
            2'b10 : begin branch_address <= (alu_out)&32'hfffffffe; end //JALR
            
            2'b11 : case (alu_out[0])
                        1'b0: branch_address <= pc+`pc_increment;
                        1'b1: branch_address <= pc + imm;
                    endcase
        endcase
        
        branch_taken <= ((pc_sel!=0)&&(branch_address!=address_predicted));
		  
        //pc_sel != 0 is redundant but is present anyways 
        //branch_taken = 1 => we need to cancel instructions(wrong prediction)
        
    end

endmodule
