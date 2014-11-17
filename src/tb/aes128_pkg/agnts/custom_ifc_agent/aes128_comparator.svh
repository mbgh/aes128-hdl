/**
 * Class: aes128_comparator
 * 
 * The comparater will receive the actual responses from the monitor and the
 * expected responses from the predictor. It will then compare the two and print
 * some reporting.
 * 
 * General Information:
 * File         - aes128_comparator.svh
 * Title        - Comparator to compare the actual and the expected responses
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
 * File ID     - $Id: aes128_comparator.svh 24 2014-10-20 14:13:12Z u59323933 $
 * Revision    - $Revision: 24 $
 * Local Date  - $Date: 2014-10-20 16:13:12 +0200 (Mon, 20 Oct 2014) $
 * Modified By - $Author: u59323933 $
 * 
 * Major Revisions:
 * 2014-10-14 (v1.0) - Created (mbgh) 
 */
class aes128_comparator extends uvm_agent;

	// Tell the UVM factory about the agent.
	`uvm_component_utils(aes128_comparator)

	// Create a TLM analysis FIFO for receiving the DUV requests observed by the
	// monitor.
	uvm_tlm_analysis_fifo #(txn_data) act_rsp_fifo;

	// Create a get port, which receives the expected responses from the
	// predictor.
	uvm_get_port #(txn_data) pred2comp_gp;
	 
	// Create the transactions for the actual and the expected responses.
	txn_data act_rsp_txn, exp_rsp_txn;

	// Constructor of the class (this usually looks identical for all tests).
	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction : new

	// The build phase is called top down.
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
			
		// Allocate the required components in the build phase.
		act_rsp_fifo = new("act_rsp_fifo", this);
		pred2comp_gp = new("pred2comp_gp", this);
	endfunction : build_phase

	task run_phase(uvm_phase phase);

		// Counters to count the passed/failed test vectors.
		int pass_count = 0;
		int fail_count = 0;

		// Initial values of the pass/fail count (in case there are no
		// passes/fails). 
		uvm_config_db #(int)::set(null, "*", "PASS_COUNT", pass_count);
		uvm_config_db #(int)::set(null, "*", "FAIL_COUNT", fail_count);
		
		forever begin
			// Wait until we get some new data from the monitor.
			act_rsp_fifo.get(act_rsp_txn);

			// Get the corresponding expected response from the predictor via the
			// UVM get port. Actually there should always be some expected
			// response, since we only read it from the provided file.
			if ( !pred2comp_gp.try_get(exp_rsp_txn) )
				`mm_fatal(("No expected responses available."))

			// Check whether the ciphertexts are equal.
			if ( act_rsp_txn.comp_ciphertext(exp_rsp_txn) ) begin
				pass_count++;
				`mm_info(("PASSED: Cipherkey=%h, Plaintext=%h, Ciphertext=%h",
									exp_rsp_txn.cipherkey, exp_rsp_txn.plaintext, act_rsp_txn.ciphertext), UVM_MEDIUM)

				// Store the pass counter in the configuration database to obtain it
				// later on from another UVM component.
				uvm_config_db #(int)::set(null, "*", "PASS_COUNT", pass_count);
					
			end else begin
				fail_count++;
				`mm_error(("ERROR: Cipherkey=%h, Plaintext=%h, Expected Ciphertext=%h, Actual Ciphertext=%h",
									 exp_rsp_txn.cipherkey, exp_rsp_txn.plaintext, exp_rsp_txn.ciphertext, act_rsp_txn.ciphertext))

				// Store the fail counter in the configuration database to obtain it
				// later on from another UVM component.
				uvm_config_db #(int)::set(null, "*", "FAIL_COUNT", fail_count);
			end // else
		end // forever 
	endtask : run_phase
	 
endclass : aes128_comparator
