program test(intf intf1);

    env environment;
    // Start Test
   
    initial
    begin

        environment = new(intf1);

        environment.test_run();

    end

endprogram
