class env;
    generator  gen;
    driver     drv;
    monitor    mon;
    scoreboard scb;
    mailbox #(transaction) gen2drv;
    mailbox #(transaction) mon2scb;

    // Constructor
  
    function new(virtual intf vif);

        // Create Mailboxes
        gen2drv = new();
        mon2scb = new();

        // Create Components
        gen = new(gen2drv);

        drv = new(vif, gen2drv);

        mon = new(vif, mon2scb);

        scb = new(mon2scb);

    endfunction

    // Run Test
    task test_run();

        fork

            gen.main();

            drv.main();

            mon.main();

            scb.main();

        join

    endtask

endclass
