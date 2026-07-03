class scoreboard;
    mailbox #(transaction) mon2scb;
    // Constructor
    

    function new(mailbox #(transaction) mon2scb);

        this.mon2scb = mon2scb;

    endfunction
    task main();

        transaction trans;

        forever
        begin

            mon2scb.get(trans);

            trans.display("SCOREBOARD");

            if(trans.rx_data == trans.miso_data)
                $display("******** PASS ********");

            else
            begin
                $display("******** FAIL ********");
                $display("Expected = %0h", trans.miso_data);
                $display("Received = %0h", trans.rx_data);
            end

        end

    endtask

endclass
