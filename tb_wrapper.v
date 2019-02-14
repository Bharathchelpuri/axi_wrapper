
module tb_axi_master_wrapper;

reg clk;
reg rst_n;


reg  [31:0] address;
reg         write_en;
reg         read_en;
reg         data_memory_hit;
reg  [31:0] write_data;
reg  [3:0]  byte_enable;

wire [31:0] read_data_out;


wire [31:0] M_AXI_AWADDR;
wire        M_AXI_AWVALID;
reg         M_AXI_AWREADY;


wire [31:0] M_AXI_WDATA;
wire [3:0]  M_AXI_WSTRB;
wire        M_AXI_WVALID;
reg         M_AXI_WREADY;


reg  [1:0]  M_AXI_BRESP;
reg         M_AXI_BVALID;
wire        M_AXI_BREADY;

wire [31:0] M_AXI_ARADDR;
wire        M_AXI_ARVALID;
reg         M_AXI_ARREADY;


reg  [31:0] M_AXI_RDATA;
reg  [1:0]  M_AXI_RRESP;
reg         M_AXI_RVALID;
wire        M_AXI_RREADY;


axi_m_wrapper uut (

    .clk                (clk),
    .rst_n              (rst_n),

    .in_address         (address),
    .write_en           (write_en),
    .read_en            (read_en),
    .in_valid           (data_memory_hit),
    .write_data         (write_data),
    .byte_enable        (byte_enable),

    .read_data_out      (read_data_out),

    // WRITE ADDRESS CHANNEL
    .M_AXI_AWADDR       (M_AXI_AWADDR),
    .M_AXI_AWVALID      (M_AXI_AWVALID),
    .M_AXI_AWREADY      (M_AXI_AWREADY),

    // WRITE DATA CHANNEL
    .M_AXI_WDATA        (M_AXI_WDATA),
    .M_AXI_WSTRB        (M_AXI_WSTRB),
    .M_AXI_WVALID       (M_AXI_WVALID),
    .M_AXI_WREADY       (M_AXI_WREADY),

    // WRITE RESPONSE CHANNEL
    .M_AXI_BRESP        (M_AXI_BRESP),
    .M_AXI_BVALID       (M_AXI_BVALID),
    .M_AXI_BREADY       (M_AXI_BREADY),

    // READ ADDRESS CHANNEL
    .M_AXI_ARADDR       (M_AXI_ARADDR),
    .M_AXI_ARVALID      (M_AXI_ARVALID),
    .M_AXI_ARREADY      (M_AXI_ARREADY),

    // READ DATA CHANNEL
    .M_AXI_RDATA        (M_AXI_RDATA),
    .M_AXI_RRESP        (M_AXI_RRESP),
    .M_AXI_RVALID       (M_AXI_RVALID),
    .M_AXI_RREADY       (M_AXI_RREADY)

);


initial
    clk = 1'b0;

always #5 clk = ~clk;

initial
begin

    rst_n = 1'b0;

    //#20;
    repeat(5) @(posedge clk);
    
    rst_n = 1'b1;

end

initial
begin

    address         = 32'd0;
    write_en        = 1'b0;
    read_en         = 1'b0;
    data_memory_hit = 1'b0;
    write_data      = 32'd0;
    byte_enable     = 4'd0;

    M_AXI_AWREADY   = 1'b0;
    M_AXI_WREADY    = 1'b0;

    M_AXI_BRESP     = 2'b00;
    M_AXI_BVALID    = 1'b0;

    M_AXI_ARREADY   = 1'b0;

    M_AXI_RDATA     = 32'd0;
    M_AXI_RRESP     = 2'b00;
    M_AXI_RVALID    = 1'b0;

end

initial
begin

    wait(rst_n);

    #20;

    @(posedge clk);

    address         <= 32'h00001000;
    write_data      <= 32'hDEADBEEF;
    byte_enable     <= 4'b1111;

    write_en        <= 1'b1;
    data_memory_hit <= 1'b1;

    @(posedge clk);

    write_en        <= 1'b0;
    data_memory_hit <= 1'b0;

end

initial
begin

    wait(M_AXI_AWVALID);

    #20;

    M_AXI_AWREADY = 1'b1;

    #10;

    M_AXI_AWREADY = 1'b0;

end

initial
begin

    wait(M_AXI_WVALID);

    #40;

    M_AXI_WREADY = 1'b1;

    #10;

    M_AXI_WREADY = 1'b0;

end

initial
begin

   // wait(M_AXI_BREADY);

    #100;

    M_AXI_BVALID = 1'b1;
    M_AXI_BRESP  = 2'b00;

   // #10;
#190;
    M_AXI_BVALID = 1'b0;

end

initial
begin

    wait(rst_n);

    #200;

    @(posedge clk);

    address         <= 32'h00002000;

    read_en         <= 1'b1;
    data_memory_hit <= 1'b1;

    @(posedge clk);

    read_en         <= 1'b0;
    data_memory_hit <= 1'b0;

end

initial
begin

    wait(M_AXI_ARVALID);

    #10;

    M_AXI_ARREADY = 1'b1;

    #10;

    M_AXI_ARREADY = 1'b0;

end

initial
begin

   // wait(M_AXI_RREADY);

    #250;

    M_AXI_RVALID = 1'b1;
    M_AXI_RDATA  = 32'hCAFEBABE;
    M_AXI_RRESP  = 2'b00;

    #300;

    M_AXI_RVALID = 1'b0;

end

initial
begin

    $monitor("TIME=%0t | STATE=%0d | AWVALID=%0b | WVALID=%0b | BREADY=%0b | ARVALID=%0b | RREADY=%0b | RDATA=%h",
              $time,
              uut.present_state,
              M_AXI_AWVALID,
              M_AXI_WVALID,
              M_AXI_BREADY,
              M_AXI_ARVALID,
              M_AXI_RREADY,
              read_data_out);

end

initial
begin

    $shm_open("wrapper.shm");
    $shm_probe("ACTMF");

end

initial
begin

    #500;

    $finish;

end


endmodule
