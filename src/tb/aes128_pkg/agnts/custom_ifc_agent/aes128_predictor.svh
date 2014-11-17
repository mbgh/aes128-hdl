/**
 * Class: aes128_predictor
 * 
 * Usually, the predictor may use the obtained input data to the DUV (received
 * from the monitor) in order to feed it into a "golden model". Within this
 * example we simply read the expected responses from the file containing the
 * expected responses.
 * 
 * General Information:
 * File         - aes128_predictor.svh
 * Title        - A UVM component predicting the expected responses of the DUV
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
 * File ID     - $Id: aes128_predictor.svh 24 2014-10-20 14:13:12Z u59323933 $
 * Revision    - $Revision: 24 $
 * Local Date  - $Date: 2014-10-20 16:13:12 +0200 (Mon, 20 Oct 2014) $
 * Modified By - $Author: u59323933 $
 * 
 * Major Revisions:
 * 2014-10-14 (v1.0) - Created (mbgh) 
 */
class aes128_predictor extends uvm_agent;

	// Tell the UVM factory about the agent.
	`uvm_component_utils(aes128_predictor)

	// Create a TLM analysis FIFO for receiving the DUV requests observed by the
	// monitor.
	uvm_tlm_analysis_fifo #(txn_request) req_fifo;

	// Create a put port, which will pass on the expected responses to the
	// comparator.
	uvm_put_port #(txn_data) pred2comp_pp;

	// Create a new transaction to be sent to the comparator.
	txn_data exp_rsp_txn;

	// File path to the file containing the expected responses. In our example
	// both the stimuli and the expected responses are contained in a single
	// file. Hence, we are using the same file as the sequence uses, generating
	// the transactions for the driver.
	const string EXP_RSP_FILE_PATH = "../simvectors/aes128.tv";

	// Character(s) to be used as the comment identifier. Lines of the expected
	// responses file starting with this character will be ignored.
	const string COMMENT_IDENTIFIER = "%";

	// The multi-channel descriptor (MCD) to the file containing the expected
	// responses.
	int exp_rsp_file;

	// Constructor of the class.
	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction : new

	// The build phase is called top down.
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
			
		// Allocate the required components in the build phase.
		exp_rsp_txn  = new();
		req_fifo     = new("req_fifo", this);
		pred2comp_pp = new("pred2comp_pp", this);
	endfunction : build_phase

	function void end_of_elaboration_phase(uvm_phase phase);
		// Open the different log files.
		exp_rsp_file = $fopen(EXP_RSP_FILE_PATH, "r");

		if ( !exp_rsp_file )
			`mm_fatal(("Could not open expected response file."))
		
	endfunction : end_of_elaboration_phase
	 
	task run_phase(uvm_phase phase);

		int bytesRead;     // Number of bytes read from the respective test vector file line.
		int linesRead;     // Number of lines read from the test vector file.
		string currLine;   // The current line of the test vector file.
		int itemsMatched;  // Number of items matched when parsing a test vector line.
		int tvRead = 0;    // Number of test vectors read from the test vector file.

		// Declaration of the transaction object(s).
		txn_data exp_rsp_txn_cln;
		txn_request req_txn;

		// Data, which will be read from the expected responses file, but is not
		// used by the respective transaction.
		logic newCipherkey;

		// Since we do not apply the observed stimuli sent to the DUV to a golden
		// model, but solely read the expected responses from a file, let's loop
		// through this file line-by-line in order to get the next expected
		// responses. Usually if we would have a golden model to be fed with the
		// observed input data to the DUV, we could do a "forever" loop here.
		while ( !$feof(exp_rsp_file) ) begin

			// Read a full line of the file.
			bytesRead = $fgets(currLine, exp_rsp_file);

			// Do some post-processing of the line being read from the test vector
			// file (stripping of spaces, etc.).
			currLine = currLine.substr(0, currLine.len()-2); // Strip the new line.
			currLine = strip_leading_spaces(currLine);       // Strip leading spaces.
			currLine = strip_trailing_spaces(currLine);      // Strip trailing spaces.

			// When the line starts with the comment identifier or is an empty
			// line, we will skip it and go on with the next line.
			if(currLine.substr(0, COMMENT_IDENTIFIER.len()-1).compare(COMMENT_IDENTIFIER) == 0) begin
				continue;
			end else if (currLine.compare("") == 0) begin
				continue;
			end

			// Found a valid test vector in the test vector file.
			tvRead++;

			// Parse the test vector line accordingly.
			itemsMatched = $sscanf( currLine, "%h %h %h %h", 
															newCipherkey,
															exp_rsp_txn.plaintext,
															exp_rsp_txn.cipherkey,
															exp_rsp_txn.ciphertext);

			// Now we have read the expected responses (and the corresponding
			// stimuli) from the file. So we can wait until these data get applied
			// to the DUV and observed by the monitor.
			req_fifo.get(req_txn);
			`mm_info(("DUV received a new request."), UVM_DEBUG)
				 
			// ####################################################################
			// NOTE: Now that we have received a new input request for the DUV, we
			// would most-likely apply these stimuli to a "golden (reference)
			// model" (e.g., a C model). For the present example, we have already
			// read the expected responses from the provided file and pass them on
			// to the comparator.
			// ####################################################################

			// Pass the expected responses on to the comparator using the created
			// UVM put port.
			$cast(exp_rsp_txn_cln, exp_rsp_txn.clone());
			pred2comp_pp.put(exp_rsp_txn_cln);
				 
		end // while ( !feof(exp_resp_file) )

	endtask : run_phase

	function void uvm_extract_phase(uvm_phase phase);
		// Close the file containing the expected responses.
	 	$fclose(exp_rsp_file);
	endfunction : uvm_extract_phase
	 
endclass : aes128_predictor
