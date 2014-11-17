/**
 * Class: aes128_config
 * 
 * A UVM configuration object to be used by the test environment of the AES-128
 * example.
 * 
 * General Information:
 * File         - aes128_config.svh
 * Title        - UVM configuration object
 * Project      - VLSI Book - AES-128 Example
 * Author       - Michael Muehlberghuber (mbgh@iis.ee.ethz.ch)
 * Company      - Integrated Systems Laboratory, ETH Zurich
 * Copyright    - Copyright (C) 2014 Integrated Systems Laboratory, ETH Zurich
 * File Created - 2014-10-14
 * Last Updated - 2014-10-14
 * Platform     - Simulation=QuestaSim; Synthesis=Synopsys
 * Standard     - SystemVerilog 1800-2009
 * 
 * Revision Control System Information:
 * File ID     - $Id: aes128_config.svh 24 2014-10-20 14:13:12Z u59323933 $
 * Revision    - $Revision: 24 $
 * Local Date  - $Date: 2014-10-20 16:13:12 +0200 (Mon, 20 Oct 2014) $
 * Modified By - $Author: u59323933 $
 * 
 * Major Revisions:
 * 2014-10-14 (v1.0) - Created (mbgh) 
 */
class aes128_config extends uvm_object;

	// Tell the factory about the configuration.
	`uvm_object_utils(aes128_config)
	
	// The virtual interface to be used in order to connect to the DUV.
	virtual aes128_ifc duv_ifc;
	
	// The constructor of the class.
	function new (string name = "");
		super.new(name);
	endfunction : new
	
	// This method waits for the end of the active-low reset.
	task wait_for_reset;
		@( posedge duv_ifc.Reset_RBI );
	endtask : wait_for_reset
	
	// This method waits for n clock cycles.
	task wait_for_clock( int n = 1);
		repeat( n ) begin
			@( posedge duv_ifc.Clk_CI );
		end
	endtask : wait_for_clock
	
endclass : aes128_config