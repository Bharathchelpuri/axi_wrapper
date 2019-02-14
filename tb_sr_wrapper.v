/*
module tb_axi_master_read_wrapper;

reg clk;
reg rst_n;

reg  [31:0] in_address;
reg         in_valid;

wire [31:0] read_data_out;
wire [2:0]  read_resp_out;

wire        out_valid;
//reg         out_ready;

wire [31:0] M_AXI_ARADDR;
wire        M_AXI_ARVALID;
reg         M_AXI_ARREADY;

reg  [31:0] M_AXI_RDATA;
reg  [2:0]  M_AXI_RRESP;
reg         M_AXI_RVALID;
wire        M_AXI_RREADY;

axi_master_read_wrapper DUT (

    .clk(clk),
    .rst_n(rst_n),

    .in_address(in_address),
    .in_valid(in_valid),

    .read_data_out(read_data_out),
    .read_resp_out(read_resp_out),

    .out_valid(out_valid),
    //.out_ready(out_ready),

    .M_AXI_ARADDR(M_AXI_ARADDR),
    .M_AXI_ARVALID(M_AXI_ARVALID),
    .M_AXI_ARREADY(M_AXI_ARREADY),

    .M_AXI_RDATA(M_AXI_RDATA),
    .M_AXI_RRESP(M_AXI_RRESP),
    .M_AXI_RVALID(M_AXI_RVALID),
    .M_AXI_RREADY(M_AXI_RREADY)

);


initial
begin

    clk = 0;

    forever #5 clk = ~clk;

end


initial
begin

    rst_n = 0;

    #30;

    rst_n = 1;

end


initial
begin

    in_address     = 32'd0;
    in_valid       = 1'b0;

    //out_ready      = 1'b0;

    M_AXI_ARREADY  = 1'b0;

    M_AXI_RDATA    = 32'd0;
    M_AXI_RRESP    = 3'd0;
    M_AXI_RVALID   = 1'b0;

end


initial
begin

    wait(rst_n);

    #20;

    @(posedge clk);

    in_address <= 32'h0000_1000;
    in_valid   <= 1'b1;

    @(posedge clk);

    in_valid   <= 1'b0;

end


initial
begin

    wait(M_AXI_ARVALID);

    #15;

    M_AXI_ARREADY = 1'b1;

    #10;

    M_AXI_ARREADY = 1'b0;

end

initial
begin

    //wait(M_AXI_RREADY);

    #90;

    M_AXI_RDATA  = 32'hDEADBEEF;
    M_AXI_RRESP  = 3'b001;
    M_AXI_RVALID = 1'b1;

    #20;

    M_AXI_RVALID = 1'b0;

end


initial
begin

    $monitor("TIME=%0t STATE=%0d IN_VALID=%b ARVALID=%b ARREADY=%b RVALID=%b RREADY=%b OUT_VALID=%b RDATA=%h RRESP=%h",
              $time,
              DUT.present_state,
              in_valid,
              M_AXI_ARVALID,
              M_AXI_ARREADY,
              M_AXI_RVALID,
              M_AXI_RREADY,
              out_valid,
              read_data_out,
              read_resp_out);

end


initial
begin

    $shm_open("sam_read.shm");
    $shm_probe("ACTMF");

end

initial
begin

    #300;

    $finish;

end

endmodule

*/


module tb_axi_master_read_wrapper;

reg clk;
reg rst_n;

reg  [31:0] in_address;
reg         in_valid;

wire [31:0] read_data_out;
wire [2:0]  read_resp_out;

wire        read_valid;
wire        read_ready;

wire [31:0] M_AXI_ARADDR;
wire        M_AXI_ARVALID;
reg         M_AXI_ARREADY;

reg  [31:0] M_AXI_RDATA;
reg  [2:0]  M_AXI_RRESP;
reg         M_AXI_RVALID;
wire        M_AXI_RREADY;

//==========================================================
// DUT
//==========================================================

axi_master_read_wrapper DUT (

    .clk(clk),
    .rst_n(rst_n),

    .in_address(in_address),
    .in_valid(in_valid),

    .read_data_out(read_data_out),
    .read_resp_out(read_resp_out),

    .read_valid(read_valid),
    .read_ready(read_ready),

    .M_AXI_ARADDR(M_AXI_ARADDR),
    .M_AXI_ARVALID(M_AXI_ARVALID),
    .M_AXI_ARREADY(M_AXI_ARREADY),

    .M_AXI_RDATA(M_AXI_RDATA),
    .M_AXI_RRESP(M_AXI_RRESP),
    .M_AXI_RVALID(M_AXI_RVALID),
    .M_AXI_RREADY(M_AXI_RREADY)

);

//==========================================================
// CLOCK
//==========================================================

initial
begin

    clk = 0;

    forever #5 clk = ~clk;

end

//==========================================================
// RESET
//==========================================================

initial
begin

    rst_n = 0;

    #30;

    rst_n = 1;

end

//==========================================================
// DEFAULTS
//==========================================================

initial
begin

    in_address    = 32'd0;
    in_valid      = 1'b0;

    M_AXI_ARREADY = 1'b0;

    M_AXI_RDATA   = 32'd0;
    M_AXI_RRESP   = 3'd0;
    M_AXI_RVALID  = 1'b0;

end

//==========================================================
// TESTCASE 1
// SIMPLE READ
//==========================================================

initial
begin

    wait(rst_n);

    #20;

    $display("\n");
    $display("======================================");
    $display("TESTCASE 1 : SIMPLE READ");
    $display("======================================");

    @(posedge clk);

    in_address <= 32'h0000_1000;
    in_valid   <= 1'b1;

    @(posedge clk);

    in_valid   <= 1'b0;

    #20;

    M_AXI_ARREADY <= 1'b1;

    #10;

    M_AXI_ARREADY <= 1'b0;

    #90;

    M_AXI_RDATA   <= 32'hDEADBEEF;
    M_AXI_RRESP   <= 3'b001;
    M_AXI_RVALID  <= 1'b1;

    #20;

    M_AXI_RVALID  <= 1'b0;

end

//==========================================================
// TESTCASE 2
// DELAYED ARREADY
//==========================================================

initial
begin

    wait(rst_n);

    #250;

    $display("\n");
    $display("======================================");
    $display("TESTCASE 2 : DELAYED ARREADY");
    $display("======================================");

    @(posedge clk);

    in_address <= 32'h0000_2000;
    in_valid   <= 1'b1;

    @(posedge clk);

    in_valid   <= 1'b0;

    #80;

    M_AXI_ARREADY <= 1'b1;

    #10;

    M_AXI_ARREADY <= 1'b0;

    #90;

    M_AXI_RDATA   <= 32'hCAFEBABE;
    M_AXI_RRESP   <= 3'b010;
    M_AXI_RVALID  <= 1'b1;

    #20;

    M_AXI_RVALID  <= 1'b0;

end

//==========================================================
// TESTCASE 3
// DELAYED RVALID
//==========================================================

initial
begin

    wait(rst_n);

    #500;

    $display("\n");
    $display("======================================");
    $display("TESTCASE 3 : DELAYED RVALID");
    $display("======================================");

    @(posedge clk);

    in_address <= 32'h0000_3000;
    in_valid   <= 1'b1;

    @(posedge clk);

    in_valid   <= 1'b0;

    #20;

    M_AXI_ARREADY <= 1'b1;

    #10;

    M_AXI_ARREADY <= 1'b0;

    #200;

    M_AXI_RDATA   <= 32'h12345678;
    M_AXI_RRESP   <= 3'b011;
    M_AXI_RVALID  <= 1'b1;

    #20;

    M_AXI_RVALID  <= 1'b0;

end

//==========================================================
// TESTCASE 4
// BACK TO BACK READS
//==========================================================

initial
begin

    wait(rst_n);

    #850;

    $display("\n");
    $display("======================================");
    $display("TESTCASE 4 : BACK TO BACK READS");
    $display("======================================");

    //------------------------------------------------------
    // FIRST READ
    //------------------------------------------------------

    @(posedge clk);

    in_address <= 32'h0000_4000;
    in_valid   <= 1'b1;

    @(posedge clk);

    in_valid   <= 1'b0;

    #20;

    M_AXI_ARREADY <= 1'b1;

    #10;

    M_AXI_ARREADY <= 1'b0;

    #90;

    M_AXI_RDATA   <= 32'hAAAAAAAA;
    M_AXI_RRESP   <= 3'b100;
    M_AXI_RVALID  <= 1'b1;

    #20;

    M_AXI_RVALID  <= 1'b0;

    //------------------------------------------------------
    // SECOND READ
    //------------------------------------------------------

    #40;

    @(posedge clk);

    in_address <= 32'h0000_5000;
    in_valid   <= 1'b1;

    @(posedge clk);

    in_valid   <= 1'b0;

    #20;

    M_AXI_ARREADY <= 1'b1;

    #10;

    M_AXI_ARREADY <= 1'b0;

    #90;

    M_AXI_RDATA   <= 32'hBBBBBBBB;
    M_AXI_RRESP   <= 3'b101;
    M_AXI_RVALID  <= 1'b1;

    #20;

    M_AXI_RVALID  <= 1'b0;

end

//==========================================================
// TESTCASE 5
// RVALID BEFORE RREADY
//==========================================================

initial
begin

    wait(rst_n);

    #1300;

    $display("\n");
    $display("======================================");
    $display("TESTCASE 5 : RVALID BEFORE RREADY");
    $display("======================================");

    @(posedge clk);

    in_address <= 32'h0000_6000;
    in_valid   <= 1'b1;

    @(posedge clk);

    in_valid   <= 1'b0;

    //------------------------------------------------------
    // SLAVE SENDS RVALID EARLY
    //------------------------------------------------------

    #30;

    M_AXI_RDATA   <= 32'hCCCCCCCC;
    M_AXI_RRESP   <= 3'b110;
    M_AXI_RVALID  <= 1'b1;


    #100;

    M_AXI_ARREADY <= 1'b1;

    #10;

    M_AXI_ARREADY <= 1'b0;

    #20;

    M_AXI_RVALID  <= 1'b0;

end


initial
begin

    $monitor("TIME=%0t STATE=%0d IN_VALID=%b ARVALID=%b ARREADY=%b RVALID=%b RREADY=%b READ_VALID=%b RDATA=%h RRESP=%h",
              $time,
              DUT.present_state,
              in_valid,
              M_AXI_ARVALID,
              M_AXI_ARREADY,
              M_AXI_RVALID,
              M_AXI_RREADY,
              read_valid,
              read_data_out,
              read_resp_out);

end

initial
begin

    $shm_open("sam_mul.shm");
    $shm_probe("ACTMF");

end


initial
begin

    #1700;

    $finish;

end

endmodule
