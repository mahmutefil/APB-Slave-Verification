`define MON_IF vif.MONITOR.monitor_cb

class monitor;
  
  virtual intf vif; //virtual interface decleration
  
  mailbox mon2scb;  //Mailbox decleration
  
  function new(virtual intf vif, mailbox mon2scb);
    this.vif     = vif;
    this.mon2scb = mon2scb;
  endfunction
  
  
  
  task main;
  
	bit [7:0] addr_temp;
	bit [31:0] wdata_temp;

	
    forever begin
        transaction trans; //handle of transaction class
        trans = new(); //constructor or create object for trans
        
		
     @(posedge vif.MONITOR.clk);	
     while(`MON_IF.psel == 0) begin
			@(posedge vif.MONITOR.clk);	
      
      	if(`MON_IF.pwrite) begin
			addr_temp  = `MON_IF.paddr;
			wdata_temp = `MON_IF.pwdata;
      		@(posedge vif.MONITOR.clk);
	        assert (`MON_IF.penable == 1);
 
			while(`MON_IF.pready == 0) begin
				assert (`MON_IF.penable == 1);
				assert (`MON_IF.pwrite == 1);
				assert (addr_temp  == `MON_IF.paddr);
				assert (wdata_temp == `MON_IF.pwdata);
				@(posedge vif.MONITOR.clk);
		    end

			trans.write_sel = 1;
			trans.addr      = `MON_IF.paddr;
			trans.wdata     = `MON_IF.pwdata;

          
          
        end else begin
            addr_temp = `MON_IF.paddr;
			@(posedge vif.MONITOR.clk);	
            assert (`MON_IF.penable == 1);
          
			while(`MON_IF.pready == 0) begin
				assert (`MON_IF.penable == 1);
                assert (`MON_IF.pwrite == 0);
				assert (addr_temp == `MON_IF.paddr);
				@(posedge vif.MONITOR.clk);
		    end

			trans.write_sel = 0;
			trans.addr  = `MON_IF.paddr;
			trans.rdata = `MON_IF.prdata;
		end
    end
      
            
		mon2scb.put(trans); //put sampled value to mon2scb mailbox
        trans.display("Monitor");
    end
    
  endtask
  
endclass
