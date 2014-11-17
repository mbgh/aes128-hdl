/**
 * Class: aes128_test
 * 
 * A test, which takes reads the stimuli from a file, applies it to the DUV,
 * observes the resulting output and compares the actual responses against the
 * expected ones, which are also read from a file.
 *
 * Note: There is no reason to extend a user transaction directly from
 * uvm_transaction. Always use uvm_sequence_item as the base class.
 * 
 * General Information:
 * File         - aes128_test.svh
 * Title        - AES-128 Test
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
 * File ID     - $Id: aes128_test.svh 24 2014-10-20 14:13:12Z u59323933 $
 * Revision    - $Revision: 24 $
 * Local Date  - $Date: 2014-10-20 16:13:12 +0200 (Mon, 20 Oct 2014) $
 * Modified By - $Author: u59323933 $
 * 
 * Major Revisions:
 * 2014-10-14 (v1.0) - Created (mbgh) 
 */
class aes128_test extends uvm_test;

	// Tell the UVM factory that there is a test/class called "aes128_test".
	`uvm_component_utils(aes128_test)

	// Declaration of the configuration object.
	aes128_config aes128_cfg;
	 	 
	// Declare a handle to the environment.
	aes128_env env;
	 
	// Constructor of the class (this usually looks identical for all tests).
	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction : new

	function void build_phase(uvm_phase phase);

		super.build_phase(phase);
		
		// Create the configuration object.
		aes128_cfg = new();

		// Get all the DUV configuration settings.
		if(!uvm_config_db #(virtual aes128_ifc)::get(this, "", "DUV_IFC",	aes128_cfg.duv_ifc))
			`mm_fatal(("No DUV interface"));

		// Put the generated configuration object into the configuration database
		// such that any element looking for a "duv_config" component will get the
		// aes128_config_0 configuration object.
		uvm_config_db #(aes128_config)::set(this, "*", "DUV_CONFIG", aes128_cfg);

		// Instantiate the actual environment using a factory (i.e., using the
	 	// "create" keyword) instead of the constructor (i.e., the "new"
	 	// keyword).
	 	env = aes128_env::type_id::create("env", this);
			
	endfunction: build_phase

	virtual function void end_of_elaboration();
		// Per default, the verbosity level is at 200. Let's set up the verbosity
		// for the whole environment (and below) to 500. Note that we do not set
		// it up for the present test (i.e., uvm_info messages within this test
		// with a higher verbosity than 200 will not be printed). We usually use
		// the command line settings (+UVM_VERBOSITY) in order to set the
		// verbosity of the UVM components. So this should only be used when we
		// want to override the verbosity set of the command line option.
//		aes128_env_h.set_report_verbosity_level_hier(UVM_DEBUG);
	endfunction : end_of_elaboration
	 
	// The run phase is the only phase which actually takes time (the other
	// phases take zero  simulation time).
	virtual task run_phase(uvm_phase phase);

		// Stimulation of DUV must take place within this phase.
		seq_from_file seq;
		seq = seq_from_file::type_id::create("seq");
		
		// Use the raise_objection method to tell the UVM that we are not yet done
		// (i.e, something is still going on).
		phase.raise_objection(this);
			
		// Start the sequence by providing it the sequencer to be used.
		seq.start(env.agnt.sequencer);
			
		// Use the drop_objection method to tell the UVM that we are done with our
		// tasks (i.e., the test bench might be stopped if there are no other
		// objections anymore).
		phase.drop_objection(this);

		// NOTE: Objections should only be raised in tests and nowhere else.

	 endtask; // run_phase
	 
endclass: aes128_test
