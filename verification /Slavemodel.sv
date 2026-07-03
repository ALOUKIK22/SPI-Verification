module spi_slave(intf vif);

    // Data slave transmits
    reg [7:0] tx_shift;

    initial
    begin
        forever
        begin

            // Wait until slave is selected
            @(negedge vif.spi_cs_l);

            // Load byte
            tx_shift = 8'hA5;

            // Send all bits
            repeat(8)
            begin

                // Get next bit before master's sampling edge
                @(negedge vif.spi_sclk);

                vif.miso = tx_shift[7];

                tx_shift = {tx_shift[6:0],1'b0};

            end

            // Release after transaction
            @(posedge vif.spi_cs_l);

            vif.miso = 1'b0;

        end
    end

endmodule
