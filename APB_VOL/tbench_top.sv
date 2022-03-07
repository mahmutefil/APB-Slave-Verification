`include "interface.sv"
`include "test.sv"

module tbench_top();
  
  //clock and reset signal declaration
  bit clk;
  bit rst_n;
  
  //clock generation
  always #5 clk = ~clk;
  
  
// if [file exists work] {vdel -lib work -all}


  //reset Generation
  initial begin
    rst_n = 0;
    #6 rst_n = 1;  
    
   #500000 $stop;
  end
  
  //creatinng instance of interface, inorder to connect DUT and testcase
  intf i_intf(clk,rst_n);
  
  //Testcase instance, interface handle is passed to test as an argument
  test t1(i_intf);
  
  apb_slave DUT(
    .clk(i_intf.clk),
    .rst_n(i_intf.rst_n),
    .paddr(i_intf.paddr),
    .pwrite(i_intf.pwrite),
    .psel(i_intf.psel),
    .penable(i_intf.penable),
    .pwdata(i_intf.pwdata),
    .prdata(i_intf.prdata), 
    .pready(i_intf.pready) 
  );
    
  
endmodule
