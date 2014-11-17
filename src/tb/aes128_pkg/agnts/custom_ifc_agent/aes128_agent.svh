/**
 * Class: aes128_agent
 * 
 * A UVM agent containing an appropriate sequencer, driver, and monitor in order
 * to stimulate the DUV and observe the resulting outputs.
 * 
 * General Information:
 * File         - aes128_agent.svh
 * Title        - UVM agent for the custom interface to the AES-128 design
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
 * File ID     - $Id: aes128_agent.svh 24 2014-10-20 14:13:12Z u59323933 $
 * Revision    - $Revision: 24 $
 * Local Date  - $Date: 2014-10-20 16:13:12 +0200 (Mon, 20 Oct 2014) $
 * Modified By - $Author: u59323933 $
 * 
 * Major Revisions:
 * 2014-10-14 (v1.0) - Created (mbgh) 
 */
class aes128_agent extends uvm_agent;

	// Tell the UVM factory about the agent.
	`uvm_component_utils(aes128_agent)

	// Declare all of the required components.
	aes128_sequencer sequencer;
	aes128_driver driver;
	aes128_monitor monitor;

	// Analysis ports to provide the observed data from the monitor on to some
	// subscribers.
	uvm_analysis_port #(txn_data) mon_rsp_ap;
	uvm_analysis_port #(txn_request) mon_req_ap;

	// FIFO to directly connect the driver and the monitor. This is required
	// since our DUV does not have an appropriate output interface, but has a
	// fixed latency of 12 clock cycles instead. Therefore, we use this TLM FIFO
	// to tell the monitor when we are applying new data to the DUV. The monitor
	// can then obtain the corresponding output data 12 clock cycles later.
	uvm_tlm_fifo #(logic) drv2mon_fifo;
		 
	// Constructor of the class.
	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction : new

	// The build phase is called top down.
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
			
		// Create the components using the factory.
		sequencer    = aes128_sequencer::type_id::create("sequencer", this);
		driver       = aes128_driver::type_id::create("driver", this);
		monitor      = aes128_monitor::type_id::create("monitor", this);
		drv2mon_fifo = new("drv2mon_fifo", this);

		// Create the analysis ports.
		mon_req_ap = new ("mon_req_ap", this);
		mon_rsp_ap = new ("mon_rsp_ap", this);
	endfunction : build_phase

	// The connect phase is called bottom up.
	function void connect_phase(uvm_phase phase);
		super.connect_phase(phase);
		
		// Connect the driver and the sequencer.
		driver.seq_item_port.connect(sequencer.seq_item_export);

		// Connect the driver and the monitor using the specified TLM FIFO.
		driver.drv2mon_port.connect(drv2mon_fifo.put_export);
		monitor.drv2mon_port.connect(drv2mon_fifo.get_export);

		// Pass through the analysis ports of the monitor.
		monitor.rsp_ap.connect(mon_rsp_ap);
		monitor.req_ap.connect(mon_req_ap);
			
	endfunction : connect_phase
	 
endclass : aes128_agent
