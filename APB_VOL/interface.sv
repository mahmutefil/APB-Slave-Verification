interface intf(input logic clk,rst_n);
  
  logic [7:0] paddr;
  logic [31:0] pwdata;
  logic [31:0] prdata; 
  logic psel, penable, pwrite; 
  logic pready;
  
  
    //driver clocking block
  clocking driver_cb @(posedge clk);
    default input #1step output #1ns;
    output paddr;
    output pwdata;
    input prdata;
    output psel;
	output penable;
	output pwrite;
    input pready; 
  endclocking
   
  //monitor clocking block  
  clocking monitor_cb @(posedge clk);
    default input #1step output #1ns;
    input paddr;
    input pwdata;
    input prdata;
    input psel;
	input penable;
	input pwrite;
    input pready;  
  endclocking
   
  //driver modport
  modport DRIVER  (clocking driver_cb,input clk,rst_n);
   
  //monitor modport 
  modport MONITOR (clocking monitor_cb,input clk,rst_n);
  
  
  
  
  
  //    assert: if you want scenario to be hold true then you write an assertion.
//    cover : Whether scenario ever happened in your simulation or not.


///////////////////////////////////UNKNOWN SIGNAL VALUE CHECK PART////////////////////////////////////////


//check whether at rising_edge(clk) reset and psel are valid
property SIGNAL_VALID(signal);
	@(posedge clk) disable iff(!rst_n)
	!$isunknown(signal);
endproperty: SIGNAL_VALID

RESET_VALID: assert property(SIGNAL_VALID(rst_n)); //or  RESET_VALID: cover property(SIGNAL_VALID(rst_n));
cov_RESET_VALID: cover property(SIGNAL_VALID(rst_n));
PSEL_VALID: assert property(SIGNAL_VALID(psel));   //or  PSEL_VALID: cover property(SIGNAL_VALID(psel));
cov_PSEL_VALID: cover property(SIGNAL_VALID(psel));



//check whether at rising_edge(clk), paddr pwrite and penable are valid in the rising edge of enable signal ($rose)
property CONTROL_SIGNAL_VALID(signal);
	@(posedge clk)
	$rose(psel) |-> !$isunknown(signal);  // |-> means (at the same clock edge)
endproperty: CONTROL_SIGNAL_VALID

PADDR_VALID:       assert property(CONTROL_SIGNAL_VALID(paddr));
cov_PADDR_VALID:   cover property (CONTROL_SIGNAL_VALID(paddr));
PWRITE_VALID:      assert property(CONTROL_SIGNAL_VALID(pwrite));
cov_PWRITE_VALID:  cover property (CONTROL_SIGNAL_VALID(pwrite));
PENABLE_VALID:     assert property(CONTROL_SIGNAL_VALID(penable));
cov_PENABLE_VALID: cover property (CONTROL_SIGNAL_VALID(penable));



//check whether pwdata is valid when pwrite = 1
property PWDATA_SIGNAL_VALID;
	@(posedge clk)
	($onehot(psel) && pwrite && pready) |-> !$isunknown(pwdata)[*1:$] ##1 $fell(penable);
endproperty: PWDATA_SIGNAL_VALID

PWDATA_VALID:     assert property(PWDATA_SIGNAL_VALID);
cov_PWDATA_VALID: cover property(PWDATA_SIGNAL_VALID);



//check whether penable is active for 1 clk cycle and signal is valid
//önce penable rising edge e bak sonra pready valid mi kontrol et ve penable o clk içinde 0 oluyor mu bak
property PENABLE_SIGNAL_VALID(signal);
	@(posedge clk)
	$rose(penable) |-> !$isunknown(signal)[*1:$] ##1 $fell(penable); // betwwn 1 clk cyle for the penable
endproperty: PENABLE_SIGNAL_VALID

PREADY_VALID:     assert property(PENABLE_SIGNAL_VALID(pready));
cov_PREADY_VALID: cover property (PENABLE_SIGNAL_VALID(pready));



//check whether prdata is valid when pwrite = 0
property PRDATA_SIGNAL_VALID;
	@(posedge clk)
	($onehot(penable && !pwrite && pready)) |-> !$isunknown(prdata)[*1:$] ##1 $fell(penable);
endproperty: PRDATA_SIGNAL_VALID

PRDATA_VALID:     assert property(PRDATA_SIGNAL_VALID);
cov_PRDATA_VALID: cover property (PRDATA_SIGNAL_VALID);





///////////////////////////////////TIMING RELATION CHECK PART////////////////////////////////////////

// check after the next rising edge of the pready, pready and penable swiches to 0 at the falling edge of the clk
property PREADY_DEASSERTED(signal);
	@(posedge clk)
	$rose(pready) |=> $fell(signal);  // |=> means after the next 
endproperty: PREADY_DEASSERTED

PREADY_DEASSERT:      assert property(PREADY_DEASSERTED(pready));
cov_PREADY_DEASSERT:  cover property (PREADY_DEASSERTED(pready));
PENABLE_DEASSERT:     assert property(PREADY_DEASSERTED(penable));
cov_PENABLE_DEASSERT: cover property (PREADY_DEASSERTED(penable));


// When PSEL is active, PENABLE goes high in next cycle.
property PSEL_TO_PENABLE_ACTIVE;
	@(posedge clk)
	//($rose(psel) && pwrite) || ($rose(psel) && !pwrite)  
	$rose(psel) |=> $rose(penable);
endproperty: PSEL_TO_PENABLE_ACTIVE

PSEL_TO_PENABLE:     assert property(PSEL_TO_PENABLE_ACTIVE);
cov_PSEL_TO_PENABLE: cover property(PSEL_TO_PENABLE_ACTIVE);





// From PSEL being active, the signal must be stable until end of transaction
property PSEL_ASSERT_SIGNAL_STABLE(signal);
	@(posedge clk)
  $rose(psel) |=> $stable(signal)[*1:$] ##1 $fell(penable);
endproperty: PSEL_ASSERT_SIGNAL_STABLE

PSEL_STABLE:       assert property(PSEL_ASSERT_SIGNAL_STABLE(psel));
cov_PSEL_STABLE:   cover property (PSEL_ASSERT_SIGNAL_STABLE(psel));
PWRITE_STABLE:     assert property(PSEL_ASSERT_SIGNAL_STABLE(pwrite));
cov_PWRITE_STABLE: cover property (PSEL_ASSERT_SIGNAL_STABLE(pwrite));
PADDR_STABLE:      assert property(PSEL_ASSERT_SIGNAL_STABLE(paddr));
cov_PADDR_STABLE:  cover property (PSEL_ASSERT_SIGNAL_STABLE(paddr));
PWDATA_STABLE:     assert property(PSEL_ASSERT_SIGNAL_STABLE(pwdata));
cov_PWDATA_STABLE: cover property (PSEL_ASSERT_SIGNAL_STABLE(pwdata));



// checck that the written data is found or not in the coming cycles for each adress
  property DATA_CHECK_VALID;
    int data;
       @(posedge clk) disable iff (!rst_n)
    ($onehot(pwrite), data=pwdata) |-> 
	strong (first_match (##[1:$] (prdata == data)));  //Use strong in assertions that may never complete
  endproperty: DATA_CHECK_VALID

DATA_CHECK_VALIDATITON:     assert property(DATA_CHECK_VALID);
cov_DATA_CHECK_VALIDATITON: cover property (DATA_CHECK_VALID);
  
  
  
  
  
  
  ////////////////////////// FSM VERIFICATION ////////////////////////////
  
  sequence setup_write;
   $onehot(psel) and $onehot(pwrite) and (!pready) and (!penable);
  endsequence 
  
  sequence setup_read;
    $onehot(psel) and (!pwrite) and (!pready) and (!penable);
  endsequence 
  
  sequence access_write;
    $onehot (penable) and $onehot (pready) and $stable (psel) and $stable (pwrite) and $stable (paddr) and $stable (pwdata);
  endsequence 
  
  sequence access_read;
    $onehot (penable) and $onehot (pready) and $stable (psel) and $stable (!pwrite) and $stable (paddr);
  endsequence 
   
   
   property apb_read_write(setup_r_w, access_r_w);
	@(posedge clk) disable iff (!rst_n) 
	setup_r_w |-> ##[1:$] access_r_w;
   endproperty: apb_read_write

APB_READ_CHECK:      assert property(apb_read_write(setup_read, access_read));
cov_APB_READ_CHECK:  cover property (apb_read_write(setup_read, access_read));
APB_WRITE_CHECK:     assert property(apb_read_write(setup_write, access_write));
cov_APB_WRITE_CHECK: cover property (apb_read_write(setup_write, access_write));




	property PADDR_VERIFIED(idx);
		@(posedge clk) disable iff(!rst_n)
				paddr inside{idx} && $rose(penable && pready) && pwrite  
					|-> ##[1:$] paddr inside{idx} && $rose(penable && pready) && !pwrite   ##1 $fell(penable);	
	endproperty: PADDR_VERIFIED
  
  
    generate 
	  for (genvar i=1; i<2**$size(paddr); i++) 
	  //$display("size is = %0d", $size(paddr)) ; 
	    begin 
		PADDR_VERIFICATION:  cover property ( PADDR_VERIFIED (i));  
        end 
	  
	endgenerate

  
  
endinterface
