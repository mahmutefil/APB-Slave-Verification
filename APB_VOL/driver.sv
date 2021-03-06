
`define DRIV_IF vif.DRIVER.driver_cb
class driver;
  
  virtual intf vif;
  
  mailbox gen2driv;
      
  transaction trans;
  
   
  //constructor
  function new(virtual intf vif, mailbox gen2driv);
    this.vif = vif;
    this.gen2driv = gen2driv;    
  endfunction
  
   
  task main;  

		 
    forever begin

      gen2driv.get(trans);       

      if (trans.write_sel == 1) begin 
	     write(trans.addr, trans.wdata, trans.write_sel);
		 @(posedge vif.DRIVER.clk);
      end 
	  else begin
         read(trans.addr, trans.rdata);
		 @(posedge vif.DRIVER.clk);
      end
	  
      trans.display("Driver");  
    end

  endtask
  

  task write(logic [7:0] addr,
             logic [31:0] data,
			 logic tmp_write_sel = 1);

    `DRIV_IF.psel    <= 1;
    `DRIV_IF.pwrite  <= tmp_write_sel;
    `DRIV_IF.paddr   <= addr;
    `DRIV_IF.pwdata  <= data;
    `DRIV_IF.penable <= 0;

    @(posedge vif.DRIVER.clk);
    `DRIV_IF.pwrite  <= tmp_write_sel;
    `DRIV_IF.penable <= 1;
    `DRIV_IF.psel    <= 1;
	
	wait(`DRIV_IF.pready == 1);
    `DRIV_IF.psel    <= 0;
    `DRIV_IF.penable <= 0;
    //@(posedge vif.DRIVER.clk);

    
	
  endtask
  
  
  task read(logic [7:0] addr, output logic [31:0] rdata);

    `DRIV_IF.psel    <= 1;
    `DRIV_IF.paddr   <= addr;
    `DRIV_IF.penable <= 0;
    `DRIV_IF.pwrite  <= 0;

    @(posedge vif.DRIVER.clk);
    `DRIV_IF.penable <= 1;
	
	wait(`DRIV_IF.pready == 1);
    
    `DRIV_IF.psel    <= 0;
    `DRIV_IF.penable <= 0;
	
	//@(posedge vif.DRIVER.clk);

  endtask
  
  
endclass
