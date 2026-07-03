interface intf();

    logic clk;
    logic rst;

    logic       start;
    logic [7:0] tx_data;
    logic       miso;
    logic       spi_cs_l;
    logic       spi_sclk;
    logic       spi_data;
    logic [7:0] rx_data;

endinterface
