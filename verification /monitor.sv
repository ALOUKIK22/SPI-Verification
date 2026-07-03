class monitor;
    virtual intf vif;
    mailbox #(transaction) mon2scb;

    function new(
        virtual intf vif,
        mailbox #(transaction) mon2scb
    );

        this.vif     = vif;
        this.mon2scb = mon2scb;

    endfunction
    task main();

        transaction trans;

        forever
        begin

            // Wait until SPI transaction starts
            @(negedge vif.spi_cs_l);

            trans = new();

            // Wait until transaction completes
            @(posedge vif.spi_cs_l);
            trans.rx_data = vif.rx_data;

            trans.display("MONITOR");

            mon2scb.put(trans);

        end

    endtask

endclass
