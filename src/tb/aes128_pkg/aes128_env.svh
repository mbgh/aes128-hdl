/**
 * Class: aes128_ifc
 * 
 * A UVM environment for the AES-128 example.
 * 
 * General Information:
 * File         - aes128_env.svh
 * Title        - UVM environment
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
 * File ID     - $Id: aes128_env.svh 24 2014-10-20 14:13:12Z u59323933 $
 * Revision    - $Revision: 24 $
 * Local Date  - $Date: 2014-10-20 16:13:12 +0200 (Mon, 20 Oct 2014) $
 * Modified By - $Author: u59323933 $
 * 
 * Major Revisions:
 * 2014-10-14 (v1.0) - Created (mbgh) 
 */
class aes128_env extends uvm_env;

	// Tell the UVM factory about the environment.
	`uvm_component_utils(aes128_env)
	
	// The default paths to the reports as defined by the environment (each test
	// may override these settings).
	const string INFO_RPT_PATH  = "./aes128_info.rpt";
	const string WARN_RPT_PATH  = "./aes128_warnings.rpt";
	const string ERROR_RPT_PATH = "./aes128_errors.rpt";
	
	// The multi-channel descriptor (MCD) to the reports.
	int info_file;
	int warn_file;
	int error_file;
		 
	// Declare all of the required components.
	aes128_agent agnt;
	aes128_predictor pred;
	aes128_comparator comp;
	uvm_tlm_fifo #(txn_data) pred2comp_fifo;
	
	// Constructor of the class.
	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction: new
	
	function void build_phase(uvm_phase phase);
		// Allocate the declared components using the factory.
		agnt = aes128_agent::type_id::create("agnt", this);
		pred = aes128_predictor::type_id::create("pred", this);
		comp = aes128_comparator::type_id::create("comp", this);
		pred2comp_fifo = new("pred2comp_fifo", this);
	endfunction: build_phase
	
	// The connect phase is called bottom up.
	function void connect_phase(uvm_phase phase);
		super.connect_phase(phase);
		
		// Connect the predictor and the connector using the defined UVM TLM FIFO.
		pred.pred2comp_pp.connect(pred2comp_fifo.put_export);
		comp.pred2comp_gp.connect(pred2comp_fifo.get_export);
	
		// Connect the analysis ports of the agent to the analysis FIFOs of the
		// predictor and the comparator.
		agnt.mon_req_ap.connect(pred.req_fifo.analysis_export);
		agnt.mon_rsp_ap.connect(comp.act_rsp_fifo.analysis_export);
	endfunction : connect_phase
	
	function void end_of_elaboration_phase(uvm_phase phase);
		// Open the different report files.
		info_file  = $fopen(INFO_RPT_PATH);
		warn_file  = $fopen(WARN_RPT_PATH);
		error_file = $fopen(ERROR_RPT_PATH);
	
		// Declare the severity action and the log file for warnings.
		set_report_severity_action(UVM_WARNING, UVM_DISPLAY | UVM_LOG);
		set_report_severity_file(UVM_WARNING, warn_file);

		// Declare the severity action and the log file for errors.
		set_report_severity_action(UVM_ERROR, UVM_DISPLAY | UVM_LOG);
		set_report_severity_file(UVM_ERROR, error_file);
	
		// Uncomment to print the status of the reporting system (action-, and
		// file-specific settings).
		//dump_report_state();
		
	endfunction : end_of_elaboration_phase
	
	function void uvm_extract_phase(uvm_phase phase);
		// Close the report files.
		$fclose(info_file);
		$fclose(warn_file);
		$fclose(error_file);
	endfunction : uvm_extract_phase
	
endclass : aes128_env
