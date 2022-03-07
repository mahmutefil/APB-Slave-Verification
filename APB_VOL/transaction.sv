`define DRIV_IF vif.DRIVER.driver_cb

class transaction;

	randc bit write_sel;
	randc bit[7:0] addr;
	randc bit[31:0] wdata;
         bit[31:0] rdata;
	
  
  //constraint c1 {addr > 0; addr < 27;};
  //constraint c2 {wdata > 0; wdata < 200;};
  

  covergroup cg_apb;
    coverpoint addr;
	coverpoint write_sel;
	cross_paddrXpwdata: cross addr, write_sel;
  endgroup

	
  
  
  function new();
	cg_apb = new();
  endfunction
  
  
  function void display(string name);
    $display("-------------------------");
    $display("- %s ",name);
    $display("-------------------------");
    $display("t = %0t , PADDR = %0h, PWDATA = %0h, write_sel = %d, PRDATA = %0h", $time, addr, wdata, write_sel, rdata);
  endfunction
  
  endclass
