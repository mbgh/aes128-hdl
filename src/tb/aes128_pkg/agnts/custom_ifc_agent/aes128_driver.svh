/**
 * Class: aes128_driver
 * 
 * The driver receives the sequences from the sequencer and translates it into
 * the "pin wiggles" required by the DUV, which is connected via the virtual
 * interface to the driver.
 * 
 * General Information:
 * File         - aes128_driver.svh
 * Title        - UVM driver for the custom interface to the AES-128 design
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
 * File ID     - $Id: aes128_driver.svh 24 2014-10-20 14:13:12Z u59323933 $
 * Revision    - $Revision: 24 $
 * Local Date  - $Date: 2014-10-20 16:13:12 +0200 (Mon, 20 Oct 2014) $
 * Modified By - $Author: u59323933 $
 * 
 * Major Revisions:
 * 2014-10-14 (v1.0) - Created (mbgh) 
 */
class aes128_driver extends uvm_driver #(txn_request);
	 
	// Tell the UVM factory about the driver.
	`uvm_component_utils(aes128_driver)

	// Virtual interface to the interface to be used to talk to the DUT. The
	// actual interface will be obtained from the configuration database.
	virtual aes128_ifc duv_ifc;

	// Handles to some other configuration parameters, which will be read from
	// the configuration database.
	time STIM_APP_DEL;
	 	 
	// Declaration of the configuration object.
	aes128_config aes128_cfg;

	// Since our DUV has a fixed latency of 12 clock cycles and therefore, no
	// specific output interface, we somehow need to tell the monitor when to
	// check for the actual responses. Hence, we use a uvm_put_port in order to
	// tell the monitor when we send valid data to the DUV by providing it the
	// "Start" signal. The monitor then knows that 12 clock cycles later, it has
	// to analyze the output of the DUV.
	uvm_put_port #(logic) drv2mon_port;

	// Constructor of the class.
	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction : new

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);

		// Get the DUT configuration from the configuration database.
		if(!uvm_config_db #(aes128_config)::get(this, "", "DUV_CONFIG", aes128_cfg))
			`uvm_fatal("CONFIG_FATAL", "Can't get the dut_config")

		// Get the stimuli application delay from the configuration database.
		if(!uvm_config_db #(time)::get(this, "", "STIM_APP_DEL", STIM_APP_DEL))
			`uvm_fatal("CONFIG_FATAL", "Cant't get the stimuli application delay")

		// Create the uvm_put_port to be used to tell the monitor when we have
		// sent some data to the DUT.
		drv2mon_port = new("drv2mon_port", this);
			
	endfunction : build_phase

	function void connect_phase(uvm_phase phase);
		super.connect_phase(phase);

		// Connect the DUT interface from the configuration database to the local
		// one.
		duv_ifc = aes128_cfg.duv_ifc;
	endfunction : connect_phase
	 
	task run_phase(uvm_phase phase);

		forever
			begin
				// Create a new transaction object.
				txn_request txn;
					 
				// Wait for the positive clock edge.
				@(posedge duv_ifc.Clk_CI);

				// Obtain the transaction from the sequencer (this will happen once
				// the sequence calls the finish_item method).
				seq_item_port.get_next_item(txn);

				// Now that we have received the transaction, we can actually wiggle
				// the pins of the DUV using the virtual interface.
				#STIM_APP_DEL;
				`mm_info(("Applying new data to DUV: %s", txn.convert2string()), UVM_MEDIUM)
				duv_ifc.Plaintext_DI    = txn.plaintext;
				duv_ifc.Cipherkey_DI    = txn.cipherkey;
				duv_ifc.Start_SI        = txn.start;
				duv_ifc.NewCipherkey_SI = txn.new_cipherkey;

				// Tell the monitor whether the data we have just sent to the DUV is
				// actually a new plaintext block or just some other transaction with
				// no new valid plaintext block (for which it must not analyze the
				// resulting output, i.e., ciphertext). Note that the "put"
				// communication is a "blocking" communication, since it blocks the
				// current thread until the TLM FIFO can take some data.
				drv2mon_port.put(txn.start);
					 
				// Signal the sequencer that we are done with the transaction.
				seq_item_port.item_done();
			end
	endtask : run_phase
endclass : aes128_driver
