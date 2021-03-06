class scoreboard;
  
  mailbox mon2scb; //mailbox decleration
  
  bit [31:0] sc_mem [0:255];
  int count;
  
  function new(mailbox mon2scb);
    this.mon2scb = mon2scb;
	foreach(sc_mem[i]) sc_mem[i] = 0;
  endfunction
  
  task main;
	
    transaction trans; //handle of transaction class
    forever begin
        mon2scb.get(trans); //get info from the mailbox
        
		trans.display("Scoreboard");
		
        //acts as reference model (verifying)
		
		if (trans.write_sel == 1) 
			 sc_mem[trans.addr] = trans.wdata;

		if (trans.write_sel == 0) begin
				assert (trans.rdata == sc_mem[trans.addr]) begin
					count++;
					$display("MATCH!! counter  = %0d", count);
				end else begin
					$display("MISMATCH!!");
					$fatal;
				end
			end
   
      end
  endtask
  
endclass
