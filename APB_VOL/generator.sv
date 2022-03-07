class generator;
  
  transaction trans; 
  
  mailbox gen2driv; //creating mailbox 
  
  event ended;
  
  int num = 20000;//2000
  
  
  function new(mailbox gen2driv);
    this.gen2driv = gen2driv;
  endfunction
  
  task main();
    
    for (int i=0; i<num; i++) begin
      trans = new();
      trans.randomize();
      $display("t = %0t [Generator] Loop = %0d / %0d create next item", $time, i+1, num);
      gen2driv.put(trans);
	  
	  trans.cg_apb.sample();
	  $display("Coverage of apb=%0.2f %%", trans.cg_apb.get_coverage());
    end
    $display("t = %0t [Generator] Done generation of %0d items", $time,  num);
    trans.display("Generator");
    -> ended; //triggering indicates the end of generation
    
 
  endtask
  
endclass
