/**
 * Class: aes128_monitor
 * 
 * The monitor is an absolutely passive UVM component, which solely observes the
 * communication to and from the DUV. It translates the DUV pin wiggles into
 * transactions and passes them on to some higher-level observing instances
 * (e.g., in order to check whether the outputs are functionally correct).
 * 
 * General Information:
 * File         - aes128_monitor.svh
 * Title        - Monitor to observe the comminucation with the DUV
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
 * File ID     - $Id: aes128_monitor.svh 24 2014-10-20 14:13:12Z u59323933 $
 * Revision    - $Revision: 24 $
 * Local Date  - $Date: 2014-10-20 16:13:12 +0200 (Mon, 20 Oct 2014) $
 * Modified By - $Author: u59323933 $
 * 
 * Major Revisions:
 * 2014-10-14 (v1.0) - Created (mbgh) 
 */
class aes128_monitor extends uvm_monitor;

	// Tell the UVM factory about the driver.
	`uvm_component_utils(aes128_monitor)

	// Virtual interface to the interface to be used to observe the DUT. The
	// actual interface will be obtained from the configuration database.
	virtual aes128_ifc duv_ifc;

	// Handles to some other configuration parameters, which will be read from
	// the configuration database.
	time RESP_ACQ_DEL;
	 	 
	// Declaration of the configuration object.
	aes128_config aes128_cfg;

	// An analysis port(s) to provide the observed data to some subscribers.
	uvm_analysis_port #(txn_data) rsp_ap;
	uvm_analysis_port #(txn_request) req_ap;
	 
	// Since our DUV has a fixed latency of 12 clock cycles and therefore, no
	// specific output interface, we somehow need to tell the monitor when to
	// check for the actual responses. Hence, we use a uvm_get_port in order to
	// get informed byt the driver when actual data has been sent to the
	// DUV. This is accomplished by providing the monitor the value of the
	// "Start" signal each time the driver assigns new data to the DUV. If this
	// start signal is set, the monitor knows that 12 clock cycles later, it has
	// to analyze the output of the DUV.
	uvm_get_port #(logic) drv2mon_port;

	// Constructor of the class.
	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction : new

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);

		// Create the analysis ports.
		req_ap = new ("req_ap", this);
		rsp_ap = new ("rsp_ap", this);
			
		// Get the DUT configuration from the configuration database.
		if(!uvm_config_db #(aes128_config)::get(this, "", "DUV_CONFIG", aes128_cfg))
			`uvm_fatal("CONFIG_FATAL", "Can't get the dut_config")

		// Get the response acquisition delay from the configuration database.
		if(!uvm_config_db #(time)::get(this, "", "RESP_ACQ_DEL", RESP_ACQ_DEL))
			`uvm_fatal("CONFIG_FATAL", "Cant't get the response acquisition delay")

		// Create the uvm_get_port used to receive data from the driver.
		drv2mon_port = new("drv2mon_port", this);
			
	endfunction : build_phase

	function void connect_phase(uvm_phase phase);
		super.connect_phase(phase);

		// Connect the DUT interface from the configuration database to the local
		// one.
		duv_ifc = aes128_cfg.duv_ifc;
	endfunction : connect_phase
	 
	virtual task run_phase(uvm_phase phase);
		logic newPlaintext;
		logic [11:0] plaintextValidity = 0;

		// Create new transaction obejct(s).
		txn_data rsp_txn = new(), rsp_txn_cln;
		txn_request req_txn = new(), req_txn_cln;
	
		forever
			begin
				
				// First of all, wait until the driver is currently sending a new
				// plaintext block to the DUV. If the data contains some new valid
				// input data, we need to analyze the result after our fixed DUV
				// latency of 12 clock cycles.
				drv2mon_port.get(newPlaintext);

				// Now let all of the subscribers know that some data has been sent
				// to the DUV.
				req_txn.load_data(duv_ifc.Plaintext_DI, duv_ifc.Cipherkey_DI,
        									duv_ifc.Ciphertext_DO, duv_ifc.Start_SI,
													duv_ifc.NewCipherkey_SI);
				$cast(req_txn_cln, req_txn.clone());
				req_ap.write(req_txn_cln);
					 
				// Looks like there was a bit in the TLM FIFO between the driver and
				// the monitor determining whether a new plaintext block has been
				// sent to the DUV ('0' if a clock cycle passed without sending a new
				// plaintext block and '1' if a clock cycle passed during which a new
				// plaintext block has been sent). Store this bit in the MSB of our
				// "shift register" and shift the rest of the register to the
				// right. Since the shift register has a size equal to the latency of
				// our DUV, the LSB of the register always tells us whether there is
				// some output data at the DUV we need to analyze or not.
				plaintextValidity = { newPlaintext, plaintextValidity[11:1] };
					 
				if ( newPlaintext == 1 ) begin
					`mm_info(("Driver sending new plaintext block to DUV."), UVM_DEBUG)
				end

				// Wait for the positive clock edge.
				@(posedge duv_ifc.Clk_CI);

				// If the LSB of our shift register indicates that there is valid
				// data on the output of the DUV, we need to analyze it.
				if ( plaintextValidity[0] == 1 ) begin
					#RESP_ACQ_DEL;
					`mm_info(("Now analyzing the resulting ciphertext."), UVM_DEBUG)
					rsp_txn.load_data(duv_ifc.Plaintext_DI, duv_ifc.Cipherkey_DI, duv_ifc.Ciphertext_DO);
					$cast(rsp_txn_cln, rsp_txn.clone());
					rsp_ap.write(rsp_txn_cln);
				end
			end
	endtask : run_phase 
endclass : aes128_monitor
