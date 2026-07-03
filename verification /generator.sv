class generator;
    transaction trans;

    mailbox #(transaction) gen2drv;
    // Constructor
 
    function new(mailbox #(transaction) gen2drv);

        this.gen2drv = gen2drv;

    endfunction


    task main();

        repeat(20)
        begin

            trans = new();

            if(!trans.randomize())
                $error("Randomization Failed");

            trans.display("GENERATOR");

            gen2drv.put(trans);

        end

    endtask

endclass
