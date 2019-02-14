module axi_master_wrapper #
(
    parameter UART_START = 32'h1000_0000,
    parameter UART_END   = 32'h1000_0FFF,

    parameter SPI_START  = 32'h1000_1000,
    parameter SPI_END    = 32'h1000_1FFF,

    parameter I2C_START  = 32'h1000_2000,
    parameter I2C_END    = 32'h1000_2FFF,

    parameter MEM_START  = 32'h0000_0000,
    parameter MEM_END    = 32'h0000_FFFF
)
(

    input               clk,
    input               rst_n,

    input       [31:0]  in_address,
    input               write_en,
    input               read_en,
    input               in_valid,
    input       [31:0]  write_data,
    input       [3:0]   byte_enable,

    output reg  [31:0]  read_data_out,
    output reg  [2:0]   read_resp_out,
    output reg  [2:0]   write_resp_out,

    output reg          addr_error,

    output              read_valid,
    output              read_ready,
    output              w_resp_valid,
    output              w_resp_ready,


    output reg  [31:0]  bg_axi_awaddr,
    output reg          bg_axi_awvalid,
    input               bg_axi_awready,

    output reg  [31:0]  bg_axi_wdata,
    output reg  [3:0]   bg_axi_wstrb,
    output reg          bg_axi_wvalid,
    input               bg_axi_wready,

    input       [1:0]   bg_axi_bresp,
    input               bg_axi_bvalid,
    output reg          bg_axi_bready,

    output reg  [31:0]  bg_axi_araddr,
    output reg          bg_axi_arvalid,
    input               bg_axi_arready,

    input       [31:0]  bg_axi_rdata,
    input       [1:0]   bg_axi_rresp,
    input               bg_axi_rvalid,
    output reg          bg_axi_rready,

    output reg  [31:0]  dm_axi_awaddr,
    output reg          dm_axi_awvalid,
    input               dm_axi_awready,

    output reg  [31:0]  dm_axi_wdata,
    output reg  [3:0]   dm_axi_wstrb,
    output reg          dm_axi_wvalid,
    input               dm_axi_wready,

    input       [1:0]   dm_axi_bresp,
    input               dm_axi_bvalid,
    output reg          dm_axi_bready,

    output reg  [31:0]  dm_axi_araddr,
    output reg          dm_axi_arvalid,
    input               dm_axi_arready,

    input       [31:0]  dm_axi_rdata,
    input       [1:0]   dm_axi_rresp,
    input               dm_axi_rvalid,
    output reg          dm_axi_rready

);

localparam IDLE        = 3'd0,
           WRITE_REQ   = 3'd1,
           WRITE_RESP  = 3'd2,
           READ_REQ    = 3'd3,
           READ_DATA   = 3'd4,
           ERROR_STATE = 3'd5;

localparam BRIDGE_SEL  = 1'b0,
           MEM_SEL     = 1'b1;

reg [2:0] present_state;
reg [2:0] next_state;

reg aw_done;
reg w_done;

reg target_slave;

wire uart_sel;
wire spi_sel;
wire i2c_sel;

wire bridge_sel;
wire mem_sel;

wire illegal_addr;

wire awready_mux;
wire wready_mux;
wire bvalid_mux;

wire arready_mux;
wire rvalid_mux;

wire [31:0] rdata_mux;

wire [2:0] bresp_mux;
wire [2:0] rresp_mux;

wire awvalid_mux;
wire wvalid_mux;

assign uart_sel = (in_address >= UART_START) && (in_address <= UART_END);

assign spi_sel = (in_address >= SPI_START) && (in_address <= SPI_END);

assign i2c_sel = (in_address >= I2C_START) && (in_address <= I2C_END);

assign mem_sel = (in_address >= MEM_START) && (in_address <= MEM_END);

assign bridge_sel = uart_sel || spi_sel  || i2c_sel;

assign illegal_addr = !(bridge_sel || mem_sel);

assign awready_mux = (target_slave == BRIDGE_SEL) ? bg_axi_awready : dm_axi_awready;

assign wready_mux = (target_slave == BRIDGE_SEL) ? bg_axi_wready : dm_axi_wready;

assign bvalid_mux = (target_slave == BRIDGE_SEL) ? bg_axi_bvalid : dm_axi_bvalid;

assign bready_mux = (target_slave == BRIDGE_SEL) ? bg_axi_bready : dm_axi_bready;


assign arready_mux = (target_slave == BRIDGE_SEL) ? bg_axi_arready : dm_axi_arready;

assign rvalid_mux = (target_slave == BRIDGE_SEL) ? bg_axi_rvalid : dm_axi_rvalid;

assign rready_mux = (target_slave == BRIDGE_SEL) ? bg_axi_rready : dm_axi_rready;


assign rdata_mux = (target_slave == BRIDGE_SEL) ? bg_axi_rdata : dm_axi_rdata;  

assign bresp_mux = (target_slave == BRIDGE_SEL) ? bg_axi_bresp : dm_axi_bresp;

assign rresp_mux = (target_slave == BRIDGE_SEL) ? bg_axi_rresp : dm_axi_rresp;

assign awvalid_mux = (target_slave == BRIDGE_SEL) ? bg_axi_awvalid : dm_axi_awvalid;

assign wvalid_mux = (target_slave == BRIDGE_SEL) ? bg_axi_wvalid : dm_axi_wvalid;


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
    begin

        target_slave <= BRIDGE_SEL;

    end

    else
    begin

        if(present_state == IDLE)
        begin

            if(in_valid && (write_en || read_en))
            begin

                if(bridge_sel)
                    target_slave <= BRIDGE_SEL;

                else if(mem_sel)
                    target_slave <= MEM_SEL;

            end

        end

    end

end


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

        else
        begin

            if(awready_mux && awvalid_mux)
                aw_done <= 1'b1;

            if(wready_mux && wvalid_mux)
                w_done <= 1'b1;

        end

    end

end

always @( * )
begin

       if(rvalid_mux && rready_mux)
        begin

            read_data_out = rdata_mux;
            read_resp_out = rresp_mux;

        end  
end

always @( * )
begin
       if(bvalid_mux && bready_mux)
        begin

            write_resp_out = bresp_mux;

        end
end


assign read_valid = rvalid_mux; // output of rvalid and rready
assign read_ready = rready_mux;

assign w_resp_valid = bvalid_mux; // output of bvalid and bready 
assign w_resp_ready = bready_mux;


always @( * )
begin

    next_state = present_state;

    case(present_state)

    IDLE:
    begin

        if(in_valid && (write_en || read_en))
        begin

            if(illegal_addr)
            begin

                next_state = ERROR_STATE;

            end

            else if(write_en)
            begin

                next_state = WRITE_REQ;

            end

            else if(read_en)
            begin

                next_state = READ_REQ;

            end

        end

    end

    WRITE_REQ:
    begin

        if(aw_done && w_done)
        begin

            next_state = WRITE_RESP;

        end

    end

    WRITE_RESP:
    begin

        if(bvalid_mux && bready_mux)
        begin

            next_state = IDLE;

        end

    end

    READ_REQ:
    begin

        if(arready_mux && 
          ((target_slave == BRIDGE_SEL && bg_axi_arvalid) ||
           (target_slave == MEM_SEL    && dm_axi_arvalid)))
        begin

            next_state = READ_DATA;

        end

    end

    READ_DATA:
    begin

        if(rvalid_mux && rready_mux)
        begin

            next_state = IDLE;

        end

    end

    ERROR_STATE:
    begin

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

    bg_axi_awaddr  = 32'd0;
    bg_axi_awvalid = 1'b0;

    bg_axi_wdata   = 32'd0;
    bg_axi_wstrb   = 4'd0;
    bg_axi_wvalid  = 1'b0;

    bg_axi_bready  = 1'b0;

    bg_axi_araddr  = 32'd0;
    bg_axi_arvalid = 1'b0;

    bg_axi_rready  = 1'b0;

    dm_axi_awaddr  = 32'd0;
    dm_axi_awvalid = 1'b0;

    dm_axi_wdata   = 32'd0;
    dm_axi_wstrb   = 4'd0;
    dm_axi_wvalid  = 1'b0;

    dm_axi_bready  = 1'b0;

    dm_axi_araddr  = 32'd0;
    dm_axi_arvalid = 1'b0;

    dm_axi_rready  = 1'b0;

    addr_error     = 1'b0;

    case(present_state)

    IDLE:
    begin

    end
    
    WRITE_REQ:
    begin

        if(target_slave == BRIDGE_SEL)
        begin

            if(!aw_done)
            begin

                bg_axi_awaddr  = in_address;
                bg_axi_awvalid = 1'b1;

            end

            if(!w_done)
            begin

                bg_axi_wdata   = write_data;
                bg_axi_wstrb   = byte_enable;
                bg_axi_wvalid  = 1'b1;

            end

        end

        else
        begin

            if(!aw_done)
            begin

                dm_axi_awaddr  = in_address;
                dm_axi_awvalid = 1'b1;

            end

            if(!w_done)
            begin

                dm_axi_wdata   = write_data;
                dm_axi_wstrb   = byte_enable;
                dm_axi_wvalid  = 1'b1;

            end

        end

    end

    WRITE_RESP:
    begin

        if(target_slave == BRIDGE_SEL)
        begin
            bg_axi_bready = 1'b1;
         end

        else
        begin
            dm_axi_bready = 1'b1;

        end

    end

    READ_REQ:
    begin

        if(target_slave == BRIDGE_SEL)
        begin

            bg_axi_araddr  = in_address;
            bg_axi_arvalid = 1'b1;

        end

        else
        begin

            dm_axi_araddr  = in_address;
            dm_axi_arvalid = 1'b1;

        end

    end

    READ_DATA:
    begin

        if(target_slave == BRIDGE_SEL)
        begin

            bg_axi_rready = 1'b1;

        end

        else
        begin

            dm_axi_rready = 1'b1;

        end

    end

    ERROR_STATE:
    begin

        addr_error = 1'b1;

    end

    endcase

end

endmodule
