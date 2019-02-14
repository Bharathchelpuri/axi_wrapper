
module tb_axi_master_wrapper;

reg clk;
reg rst_n;

reg  [31:0] in_address;
reg         write_en;
reg         read_en;
reg         in_valid;
reg  [31:0] write_data;
reg  [3:0]  byte_enable;

wire [31:0] read_data_out;
wire [2:0]  read_resp_out;
wire [2:0]  write_resp_out;

wire        addr_error;

wire [31:0] bg_axi_awaddr;
wire        bg_axi_awvalid;
reg         bg_axi_awready;

wire [31:0] bg_axi_wdata;
wire [3:0]  bg_axi_wstrb;
wire        bg_axi_wvalid;
reg         bg_axi_wready;

reg  [2:0]  bg_axi_bresp;
reg         bg_axi_bvalid;
wire        bg_axi_bready;

wire [31:0] bg_axi_araddr;
wire        bg_axi_arvalid;
reg         bg_axi_arready;

reg  [31:0] bg_axi_rdata;
reg  [2:0]  bg_axi_rresp;
reg         bg_axi_rvalid;
wire        bg_axi_rready;

wire [31:0] dm_axi_awaddr;
wire        dm_axi_awvalid;
reg         dm_axi_awready;

wire [31:0] dm_axi_wdata;
wire [3:0]  dm_axi_wstrb;
wire        dm_axi_wvalid;
reg         dm_axi_wready;

reg  [2:0]  dm_axi_bresp;
reg         dm_axi_bvalid;
wire        dm_axi_bready;

wire [31:0] dm_axi_araddr;
wire        dm_axi_arvalid;
reg         dm_axi_arready;

reg  [31:0] dm_axi_rdata;
reg  [2:0]  dm_axi_rresp;
reg         dm_axi_rvalid;
wire        dm_axi_rready;

axi_master_wrapper DUT (

    .clk(clk),
    .rst_n(rst_n),

    .in_address(in_address),
    .write_en(write_en),
    .read_en(read_en),
    .in_valid(in_valid),
    .write_data(write_data),
    .byte_enable(byte_enable),

    .read_data_out(read_data_out),
    .read_resp_out(read_resp_out),
    .write_resp_out(write_resp_out),

    .addr_error(addr_error),

    .bg_axi_awaddr(bg_axi_awaddr),
    .bg_axi_awvalid(bg_axi_awvalid),
    .bg_axi_awready(bg_axi_awready),

    .bg_axi_wdata(bg_axi_wdata),
    .bg_axi_wstrb(bg_axi_wstrb),
    .bg_axi_wvalid(bg_axi_wvalid),
    .bg_axi_wready(bg_axi_wready),

    .bg_axi_bresp(bg_axi_bresp),
    .bg_axi_bvalid(bg_axi_bvalid),
    .bg_axi_bready(bg_axi_bready),

    .bg_axi_araddr(bg_axi_araddr),
    .bg_axi_arvalid(bg_axi_arvalid),
    .bg_axi_arready(bg_axi_arready),

    .bg_axi_rdata(bg_axi_rdata),
    .bg_axi_rresp(bg_axi_rresp),
    .bg_axi_rvalid(bg_axi_rvalid),
    .bg_axi_rready(bg_axi_rready),

    .dm_axi_awaddr(dm_axi_awaddr),
    .dm_axi_awvalid(dm_axi_awvalid),
    .dm_axi_awready(dm_axi_awready),

    .dm_axi_wdata(dm_axi_wdata),
    .dm_axi_wstrb(dm_axi_wstrb),
    .dm_axi_wvalid(dm_axi_wvalid),
    .dm_axi_wready(dm_axi_wready),

    .dm_axi_bresp(dm_axi_bresp),
    .dm_axi_bvalid(dm_axi_bvalid),
    .dm_axi_bready(dm_axi_bready),

    .dm_axi_araddr(dm_axi_araddr),
    .dm_axi_arvalid(dm_axi_arvalid),
    .dm_axi_arready(dm_axi_arready),

    .dm_axi_rdata(dm_axi_rdata),
    .dm_axi_rresp(dm_axi_rresp),
    .dm_axi_rvalid(dm_axi_rvalid),
    .dm_axi_rready(dm_axi_rready)

);

initial
begin

    clk = 0;

    forever #5 clk = ~clk;

end

initial
begin

    rst_n = 0;

    repeat(5) @(posedge clk);

    rst_n = 1;

end

initial
begin

    in_address     = 0;
    write_en       = 0;
    read_en        = 0;
    in_valid       = 0;
    write_data     = 0;
    byte_enable    = 0;

    bg_axi_awready = 0;
    bg_axi_wready  = 0;
    bg_axi_bvalid  = 0;
    bg_axi_bresp   = 0;
    bg_axi_arready = 0;
    bg_axi_rvalid  = 0;
    bg_axi_rdata   = 0;
    bg_axi_rresp   = 0;

    dm_axi_awready = 0;
    dm_axi_wready  = 0;
    dm_axi_bvalid  = 0;
    dm_axi_bresp   = 0;
    dm_axi_arready = 0;
    dm_axi_rvalid  = 0;
    dm_axi_rdata   = 0;
    dm_axi_rresp   = 0;

end

initial
begin

    wait(rst_n);

    #20;

    @(posedge clk);

    in_address  <= 32'h1000_0010;
    write_data  <= 32'hAABBCCDD;
    byte_enable <= 4'b1111;

    write_en    <= 1'b1;
    in_valid    <= 1'b1;

    @(posedge clk);

    write_en    <= 1'b0;
    in_valid    <= 1'b0;

end

initial
begin

    wait(bg_axi_awvalid);

    #10;
    bg_axi_awready = 1;

    #10;
    bg_axi_awready = 0;

end

initial
begin

    wait(bg_axi_wvalid);

    #10;
    bg_axi_wready = 1;

    #10;
    bg_axi_wready = 0;

end

initial
begin

   wait(bg_axi_bready);

    #20;

    bg_axi_bvalid = 1;
    bg_axi_bresp  = 3'b001;

    #20;

    bg_axi_bvalid = 0;

end

initial
begin

    wait(rst_n);

    #200;

    @(posedge clk);

    in_address <= 32'h0000_0010;

    read_en    <= 1'b1;
    in_valid   <= 1'b1;

    @(posedge clk);

    read_en    <= 1'b0;
    in_valid   <= 1'b0;

end

initial
begin

    wait(dm_axi_arvalid);

    #10;
    dm_axi_arready = 1;

    #10;
    dm_axi_arready = 0;

end

initial
begin

    wait(dm_axi_rready);

    #20;

    dm_axi_rvalid = 1;
    dm_axi_rdata  = 32'hCAFEBABE;
    dm_axi_rresp  = 3'b010;

    #10;

    dm_axi_rvalid = 0;

end

initial
begin

    wait(rst_n);

    #400;

    @(posedge clk);

    in_address <= 32'h9000_0000;

    write_en   <= 1'b1;
    in_valid   <= 1'b1;

    @(posedge clk);

    write_en   <= 1'b0;
    in_valid   <= 1'b0;

end

initial
begin

    $monitor("TIME=%0t STATE=%0d ADDR=%h BG_AWVALID=%b DM_ARVALID=%b RDATA=%h ERROR=%b",
              $time,
              DUT.present_state,
              in_address,
              bg_axi_awvalid,
              dm_axi_arvalid,
              read_data_out,
              addr_error);

end


initial
begin

    $shm_open("sam.shm");
    $shm_probe("ACTMF");

end



initial
begin

    #700;

    $finish;

end

endmodule
