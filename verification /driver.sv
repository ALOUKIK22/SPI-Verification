class driver;
    virtual intf vif;
    mailbox #(transaction) gen2drv;
    // Constructor

    function new(

        virtual intf vif,

        mailbox #(transaction) gen2drv

    );

        this.vif = vif;

        this.gen2drv = gen2drv;

    endfunction

    task main();

        transaction trans;

        forever
        begin

            gen2drv.get(trans);

            trans.display("DRIVER");

            @(posedge vif.clk);

            vif.tx_data <= trans.tx_data;
            vif.start   <= 1'b1;

            @(posedge vif.clk);

            vif.start <= 1'b0;

            // Wait until SPI transfer completes
            wait(vif.spi_cs_l == 1'b1);

        end

    endtask

endclass
