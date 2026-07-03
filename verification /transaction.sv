class transaction;

  
    rand bit       start;
    rand bit [7:0] tx_data;

    rand bit [7:0] miso_data;

    bit [7:0] rx_data;

    function void display(string name);

        $display("--------------------------------------------");
        $display("%s", name);
        $display("--------------------------------------------");
        $display("START    = %0d", start);
        $display("TX_DATA  = %0h", tx_data);
        $display("MISO     = %0h", miso_data);
        $display("RX_DATA  = %0h", rx_data);
        $display("--------------------------------------------");

    endfunction

endclass
