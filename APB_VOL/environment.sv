`include "transaction.sv"
`include "generator.sv"
`include "driver.sv"
`include "monitor.sv"
`include "scoreboard.sv"


class environment;
  //Handle of included files
  generator  gen; 
  driver     driv;
  monitor    mon;
  scoreboard scb;
  
  //declare 2 mailbox(from gen to driv and from mon to scb)
  mailbox m1;
  mailbox m2;
  
  virtual intf vif;
    
  function new(virtual intf vif);
    this.vif = vif;
    m1     = new();
    m2     = new();
    gen    = new(m1);
    driv   = new(vif, m1);
    mon    = new(vif, m2);
    scb    = new(m2); 
  endfunction
  
  task test();
    fork
      gen.main();
      driv.main();
      mon.main();
      scb.main();
    join
    wait(gen.ended.triggered);
  endtask
  //event e bak doğru mu diye
/*  task post_test();
    wait(gen.ended.triggered);
  endtask */
  
  
  task run; //inside run task, run the test() task
    test();
    $finish; 
  endtask
  
endclass
