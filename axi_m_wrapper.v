
module axi_m_wrapper //#(
    /*parameter UART_START = 32'h1000_0000,
    parameter UART_END   = 32'h1000_0FFF,

    parameter SPI_START  = 32'h1000_1000,
    parameter SPI_END    = 32'h1000_1FFF,

    parameter I2C_START  = 32'h1000_2000,
    parameter I2C_END    = 32'h1000_2FFF,

    parameter MEM_START  = 32'h0000_0000,
    parameter MEM_END    = 32'h0000_FFFF
    
  )

  */

   (

    input               clk,
    input               rst_n,

    //core side signals

    input       [31:0]  in_address,
    input               write_en,
    input               read_en,
    input               in_valid,
    input       [31:0]  write_data,
    input       [3:0]   byte_enable,

    output      [31:0]  read_data_out,
    output      [2:0]   read_resp,

    output      [2:0]   write_resp,    

    //axi write in_address channel

    output reg  [31:0]  M_AXI_AWADDR,
    output reg          M_AXI_AWVALID,
    input               M_AXI_AWREADY,

    //axi write data channel

    output reg  [31:0]  M_AXI_WDATA,
    output reg  [3:0]   M_AXI_WSTRB,
    output reg          M_AXI_WVALID,
    input               M_AXI_WREADY,

    //axi write responce channel

    input       [2:0]   M_AXI_BRESP,
    input               M_AXI_BVALID,
    output reg          M_AXI_BREADY,

    //axi read in_address channel

    output reg  [31:0]  M_AXI_ARADDR,
    output reg          M_AXI_ARVALID,
    input               M_AXI_ARREADY,

    //axi read data channel

    input       [31:0]  M_AXI_RDATA,
    input       [2:0]   M_AXI_RRESP,
    input               M_AXI_RVALID,
    output reg          M_AXI_RREADY

);

/*
wire uart_sel;
wire spi_sel;
wire spi_sel;
wire i2c_sel;

wire bridge_sel;
wire mem_sel;

wire illegal_addr;

*/


localparam IDLE        = 3'd0,
           WRITE_REQ   = 3'd1,
           WRITE_RESP  = 3'd2,
           READ_REQ    = 3'd3,
           READ_DATA   = 3'd4;

reg [2:0] present_state;
reg [2:0] next_state;

reg aw_done;
reg w_done;


/*
//slave selection logic

assign uart_sel = (in_address >= UART_START) && (in_address <= UART_END);

assign spi_sel = (in_address >= SPI_START) && (in_address <= SPI_END);

assign i2c_sel = (in_address >= I2C_START) && (in_address <= I2C_END);

assign mem_sel = (in_address >= MEM_START) && (in_address <= MEM_END);

assign bridge_sel = (uart_sel || spi_sel  || i2c_sel);

assign illegal_addr = !(bridge_sel || mem_sel);

*/

// state logic

always @(posedge clk or negedge rst_n)
begin

    if(!rst_n)
        present_state <= IDLE;

    else
        present_state <= next_state;

end

// handshaking flags

always @(posedge clk or negedge rst_n)
begin

    if(!rst_n)
    begin

        aw_done <= 1'b0;
        w_done  <= 1'b0;

    end

    else
    begin

        if(present_state == IDLE)
        begin

            aw_done <= 1'b0;
            w_done  <= 1'b0;

        end

        else if(M_AXI_AWVALID && M_AXI_AWREADY)
        begin

            aw_done <= 1'b1;

        end

        if(M_AXI_WVALID && M_AXI_WREADY)
        begin

            w_done <= 1'b1;

        end

    end

end

//seq read data out 

/*
always @(posedge clk or negedge rst_n)
begin

    if(!rst_n)
    begin

        read_data_out <= 32'd0;
        read_resp     <= 3'b0;
        write_resp    <= 3'b0;

    end

    else
    begin

        if(M_AXI_RVALID && M_AXI_RREADY)
        begin

            read_data_out <= M_AXI_RDATA;
            read_resp     <= M_AXI_RRESP

        end


        if(M_AXI_BVALID && M_AXI_BREADY)
        begin
            write_resp   <= M_AXI_BRESP;
        end

    end

end

*/

// combinational read data and read response
// write response

assign  read_data_out = M_AXI_RDATA;
assign  read_resp     = M_AXI_RRESP;
assign  write_resp    = M_AXI_BRESP;
 
// state transation logic

always @( * )
begin

    next_state = present_state;

    case(present_state)

    IDLE:
    begin

        if(in_valid && write_en)
            next_state = WRITE_REQ;

        else if(in_valid && read_en)
            next_state = READ_REQ;

    end

    WRITE_REQ:
    begin

        if(aw_done && w_done)
            next_state = WRITE_RESP;

    end

    WRITE_RESP:
    begin

        if(M_AXI_BVALID && M_AXI_BREADY)
            next_state = IDLE;

    end

    READ_REQ:
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
        next_state = IDLE;

    endcase

end

// state output logic 

always @( * )
begin

    M_AXI_AWADDR  = 32'd0;
    M_AXI_AWVALID = 1'b0;

    M_AXI_WDATA   = 32'd0;
    M_AXI_WSTRB   = 4'd0;
    M_AXI_WVALID  = 1'b0;

    M_AXI_BREADY  = 1'b0;

    M_AXI_ARADDR  = 32'd0;
    M_AXI_ARVALID = 1'b0;

    M_AXI_RREADY  = 1'b0;

    case(present_state)

    IDLE:
    begin

    end

    WRITE_REQ:
    begin

        if(!aw_done)
        begin

            M_AXI_AWADDR  = in_address;
            M_AXI_AWVALID = 1'b1;

        end

        if(!w_done)
        begin

            M_AXI_WDATA   = write_data;
            M_AXI_WSTRB   = byte_enable;
            M_AXI_WVALID  = 1'b1;

        end

    end

    WRITE_RESP:
    begin

        if(M_AXI_BVALID) 
            M_AXI_BREADY = 1'b1;

    end

    READ_REQ:
    begin

        M_AXI_ARADDR  = in_address;
        M_AXI_ARVALID = 1'b1;

    end

    READ_DATA:
    begin

        if(M_AXI_RVALID) 
            M_AXI_RREADY = 1'b1;

    end

    endcase

end

endmodule


   
