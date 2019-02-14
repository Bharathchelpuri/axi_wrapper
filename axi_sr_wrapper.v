
/*
module axi_master_read_wrapper (

    input               clk,
    input               rst_n,

    input       [31:0]  in_address,
    input               in_valid,

    output      [31:0]  read_data_out,
    output      [2:0]   read_resp_out,

    output              read_valid,
    output              read_ready,

    output reg  [31:0]  M_AXI_ARADDR,
    output reg          M_AXI_ARVALID,
    input               M_AXI_ARREADY,

    input       [31:0]  M_AXI_RDATA,
    input       [2:0]   M_AXI_RRESP,
    input               M_AXI_RVALID,
    output reg          M_AXI_RREADY

);

localparam IDLE       = 2'd0,
           READ_ADDR  = 2'd1,
           READ_DATA  = 2'd2;

reg [1:0] present_state;
reg [1:0] next_state;

assign read_data_out = M_AXI_RDATA;

assign read_resp_out = M_AXI_RRESP;

assign read_valid = M_AXI_RVALID;

assign read_ready =  M_AXI_RREADY;

always @(posedge clk or negedge rst_n)
begin

    if(!rst_n)
        present_state <= IDLE;

    else
        present_state <= next_state;

end

always @( * )
begin

    next_state = present_state;

    case(present_state)

    IDLE:
    begin

        if(in_valid)
            next_state = READ_ADDR;

    end

    READ_ADDR:
    begin

        if(M_AXI_ARVALID && M_AXI_ARREADY)
            next_state = READ_DATA;

    end

    READ_DATA:
    begin

        if(M_AXI_RVALID && M_AXI_RREADY)
            next_state = IDLE;

    end

    default:
    begin

        next_state = IDLE;

    end

    endcase

end

always @( * )
begin

    M_AXI_ARADDR  = 32'd0;
    M_AXI_ARVALID = 1'b0;
    M_AXI_RREADY = 1'b0;
    

    case(present_state)

    IDLE:
    begin

    end

    READ_ADDR:
    begin

        M_AXI_ARADDR  = in_address;
        M_AXI_ARVALID = 1'b1;

    end

    READ_DATA:
    begin
        if(M_AXI_RVALID)
            M_AXI_RREADY = 1'b1;

    end

    default:
    begin

        M_AXI_ARADDR  = 32'd0;
        M_AXI_ARVALID = 1'b0;

    end

    endcase

end

endmodule

*/

module axi_master_read_wrapper (

    input               clk,
    input               rst_n,

    input       [31:0]  in_address,
    input               in_valid,

    output reg  [31:0]  read_data_out,
    output reg  [2:0]   read_resp_out,

    output reg          read_valid,
    output reg          read_ready,

    //input       current_pc,
    input       reset_valid,
    output reg  reg_valid,

    output reg  [31:0]  M_AXI_ARADDR,
    output reg          M_AXI_ARVALID,
    input               M_AXI_ARREADY,

    input       [31:0]  M_AXI_RDATA,
    input       [2:0]   M_AXI_RRESP,
    input               M_AXI_RVALID,
    output reg          M_AXI_RREADY

);

localparam IDLE       = 2'd0,
           READ_ADDR  = 2'd1,
           READ_DATA  = 2'd2;

reg [1:0] present_state;
reg [1:0] next_state;

/*
assign read_data_out = M_AXI_RDATA;

assign read_resp_out = M_AXI_RRESP;

assign read_valid = M_AXI_RVALID;

assign read_ready =  M_AXI_RREADY;
*/

reg [31:0] pc;

always @(posedge clk or negedge rst_n)
begin

    if(!rst_n)
        present_state <= IDLE;

    else
        present_state <= next_state;

end


always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        pc <= 32'b0;
    else if(in_valid)
        pc <= in_address;
    
end

always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
    begin
        read_data_out <= 32'b0;
        read_resp_out <= 3'b0;
        read_valid    <= 1'b0;
        read_ready    <= 1'b0;
    end

    else if(reset_valid)
    begin
        read_valid <= 1'b0;
    end
    
    else if(M_AXI_RVALID && M_AXI_RREADY)
    begin
        read_data_out  <= M_AXI_RDATA;
        read_resp_out  <= M_AXI_RRESP;
        read_valid     <= M_AXI_RVALID;
        read_ready     <= M_AXI_RREADY;
      
    end

end


always @( * )
begin

    next_state = present_state;

    case(present_state)

    IDLE:
    begin

        if(in_valid && in_address != pc)
            next_state = READ_ADDR;

    end

    READ_ADDR:
    begin

        if(M_AXI_ARVALID && M_AXI_ARREADY)
            next_state = READ_DATA;

    end

    READ_DATA:
    begin

        if(M_AXI_RVALID && M_AXI_RREADY)
            next_state = IDLE;

    end

    default:
    begin

        next_state = IDLE;

    end

    endcase

end

always @( * )
begin

    M_AXI_ARADDR  = 32'd0;
    M_AXI_ARVALID = 1'b0;
    M_AXI_RREADY = 1'b0;
    

    case(present_state)

    IDLE:
    begin

    end

    READ_ADDR:
    begin

        M_AXI_ARADDR  = in_address;
        M_AXI_ARVALID = 1'b1;

    end

    READ_DATA:
    begin
        if(M_AXI_RVALID)
            M_AXI_RREADY = 1'b1;

    end

    default:
    begin

        M_AXI_ARADDR  = 32'd0;
        M_AXI_ARVALID = 1'b0;

    end

    endcase

end

endmodule
