/**
 * Module: aes128_top
 * 
 * This is the top module of the UVM verification environment. It is responsible
 * for instantiating the DUV, creating the clock and the reset, and determines
 * the timing-specific values such as the duty cycle of the clock, the duration
 * of the reset, the stimuli application time, and the response acquisition
 * time.
 * 
 * General Information:
 * File         - aes128_top.sv
 * Title        - Top-level module of the UVM verification environment
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
 * File ID     - $Id: aes128_top.sv 34 2014-10-22 10:55:12Z u59323933 $
 * Revision    - $Revision: 34 $
 * Local Date  - $Date: 2014-10-22 12:55:12 +0200 (Wed, 22 Oct 2014) $
 * Modified By - $Author: u59323933 $
 * 
 * Major Revisions:
 * 2014-10-14 (v1.0) - Created (mbgh)
 * 
 * References:
 * [1] - https://www.vmmcentral.org/vmartialarts/2012/04/customizing-uvm-messages-without-getting-a-sunburn/
 */
import uvm_pkg::*;
import aes128_pkg::*;

module aes128_top;

	// Timing of clock and simulation events.
	const time CLK_PHASE_HI     = 1ns;                         // Clock high time
	const time CLK_PHASE_LO     = 1ns;                         // Clock low time
	const time CLK_PERIOD       = CLK_PHASE_HI + CLK_PHASE_LO; // Clock period
	const time STIM_APP_DEL     = CLK_PERIOD*0.1;              // Stimuli application delay
	const time RESP_ACQ_DEL     = CLK_PERIOD*0.9;              // Response aquisition delay
	const int 	RESET_ACT_CYCLES = 5;                           // Number of active reset cycles to perform
	const time RESET_DEL        = STIM_APP_DEL;                // Delay after the last clock edge before withdrawing the reset
	
	// Variables for the "plusargs" to be read from the command line, when
	// running the simulation.
	integer 		fwidth; // Width of the file name string printed by the simulation.
	integer 		hwidth; // Width of the hierarchy string printed by the simulation.
	
	// --------------------------------------------------------------------------
	//
	//            CLK_PERIOD
	//  <------------------------->
	//  --------------            --------------
	//  |  A         |        T   |            |
	// --            --------------            --------------
	//  <-->
	//   STIM_APP_DEL
	//  <--------------------->
	//        RESP_ACQ_DEL
	//
	// --------------------------------------------------------------------------
	
	// Interface declaration.
	aes128_ifc duv_ifc();

	// Instantiate the DUT and connect the interface to it.
	aes128_wrapper duv_wrapper(.ifc(duv_ifc));

	initial begin
		// Tell the configuration database about our interface. Note that the name
		// of the top-level test is always "uvm_test_top". The first argument must
		// be null since we are in a top level module and not in a UVM component.
		uvm_config_db #(virtual aes128_ifc)::set(null, "uvm_test_top", "DUV_IFC",	duv_ifc);
	
		// Tell the configuration database about some other configuration
		// parameters, which will be required further down in the UVM hierarchy.
		uvm_config_db #(time)::set(null, "*", "STIM_APP_DEL", STIM_APP_DEL);
		uvm_config_db #(time)::set(null, "*", "RESP_ACQ_DEL", RESP_ACQ_DEL);
		
		// Call the test being specified via the command line.
		run_test();
	end
	
	// Replace the UVM report server with a different one as shown in [1].
	initial begin
		mbgh_report_server_c report_server;
		report_server = new("mbgh_report_server");
	
		// Use a plusargs in order to read the file name width and the hierarchy
		// width from the command line.
		if($value$plusargs("fname_width=%d", fwidth)) begin
			report_server.file_name_width = fwidth;
		end
		if($value$plusargs("hier_width=%d", hwidth)) begin
			report_server.hier_width = hwidth;
		end

		// Set the new report server as the default one.
		uvm_pkg::uvm_report_server::set_server(report_server);

		// Specify the timeformat to be used throughout the simulation.
		$timeformat(-9,0,"ns",8);
		
	end // initial begin
	
	// Clock generation.
	initial begin
		duv_ifc.Clk_CI = 1'b1;
		forever begin
			#CLK_PHASE_HI duv_ifc.Clk_CI = 1'b0;
			#CLK_PHASE_LO duv_ifc.Clk_CI = 1'b1;
		end
	end
	
	// Reset generation.
	initial begin
		duv_ifc.Reset_RBI = 1'b0;
		repeat(RESET_ACT_CYCLES) begin
			@(posedge duv_ifc.Clk_CI);
		end
		#RESET_DEL duv_ifc.Reset_RBI = 1'b1;
	end
	
endmodule : aes128_top