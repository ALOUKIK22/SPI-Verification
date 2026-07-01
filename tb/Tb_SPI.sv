`timescale 1ns/1ps

module tb_SPI;
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, tb_SPI);
end

reg clk;
reg rst;
reg start;

reg [7:0] tx_data;
reg miso;

wire spi_cs_l;
wire spi_sclk;
wire spi_data;

wire [7:0] rx_data;

SPI dut
(
    .clk(clk),
    .rst(rst),
    .start(start),
    .tx_data(tx_data),
    .miso(miso),
    .spi_cs_l(spi_cs_l),
    .spi_sclk(spi_sclk),
    .spi_data(spi_data),
    .rx_data(rx_data)
);
// Clock 

initial
begin
    clk = 0;
    forever #5 clk = ~clk;     
end

//RESET

initial
begin
    rst = 1;
    start = 0;
    tx_data = 8'h00;
    miso = 0;

    #20;
    rst = 0;
end


//  MISO 

task send_miso;

input [7:0] data;

integer i;

begin

    // Wait until slave is selected
    @(negedge spi_cs_l);

    // Put first bit before first sample
    miso = data[7];

    for(i=6;i>=0;i=i-1)
    begin
        @(negedge spi_sclk);
        miso = data[i];
    end

end
endtask
// Test Task

task run_test;

input [7:0] master_tx;
input [7:0] slave_tx;

begin

    tx_data = master_tx;

    fork

        send_miso(slave_tx);

    join_none

    @(posedge clk);
    start = 1;

    @(posedge clk);
    start = 0;

   wait(spi_cs_l==0);
wait(spi_cs_l==1);

    #20;

    if(rx_data==slave_tx)
        $display("PASS  TX=%h  RX=%h",master_tx,rx_data);

    else
        $display("FAIL  TX=%h  Expected=%h  Got=%h",
                    master_tx,
                    slave_tx,
                    rx_data);

end

endtask

// Test Sequence
initial
begin

    @(negedge rst);

    run_test(8'hA5,8'h3C);

    #100;

    run_test(8'hFF,8'h3C);

    #100;

    run_test(8'h00,8'hA5);

    #100;

    $display("-------------------------");
    $display("Simulation Finished");
    $display("-------------------------");
 $finish;

end

endmodule
