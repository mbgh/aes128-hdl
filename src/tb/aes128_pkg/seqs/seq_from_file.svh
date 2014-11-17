/**
 * Class: seq_from_file
 * 
 * This sequence reads the stimuli from an earlier prepared file and passes the
 * transactions on to the driver, which then drives the actual DUV.
 * 
 * General Information:
 * File         - seq_from_file.svh
 * Title        - A sequence reading the stimuli from a file
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
 * File ID     - $Id: seq_from_file.svh 24 2014-10-20 14:13:12Z u59323933 $
 * Revision    - $Revision: 24 $
 * Local Date  - $Date: 2014-10-20 16:13:12 +0200 (Mon, 20 Oct 2014) $
 * Modified By - $Author: u59323933 $
 * 
 * Major Revisions:
 * 2014-10-14 (v1.0) - Created (mbgh) 
 */
class seq_from_file extends uvm_sequence #(txn_request);

	// Tell the factory about the sequence.
	`uvm_object_utils(seq_from_file)

	// Declaration of the configuration object.
	aes128_config aes128_cfg;

	// Virtual interface to the interface to be used to talk to the DUT. The
	// actual interface will be obtained from the configuration database.
	virtual aes128_ifc duv_ifc;

	// File path to the test vector file.
	const string TV_FILE_PATH = "../simvectors/aes128.tv";

	// Character(s) to be used as the comment identifier. Line of the test vector
	// file starting with this character will be ignored.
	const string COMMENT_IDENTIFIER = "%";
	 
	// The constructor of the class. Note that the constructor does not have a
	// parent, since they are not part of the component hierarchy.
	function new (string name = "");
		super.new(name);
	endfunction : new

	// The most interesting part of a sequence is the body task. As usually for
	// tasks, the body task will actually take some time during the simulation.
	task body;

		txn_request txn;   // The actual transaction to be sent to the driver.
		int tvFile;        // The multi-channel descriptor (MCD) to the test vector file.
		int bytesRead;     // Number of bytes read from the respective test vector file line.
		int linesRead;     // Number of lines read from the test vector file.
		string currLine;   // The current line of the test vector file.
		int itemsMatched;  // Number of items matched when parsing a test vector line.
		int tvRead = 0;    // Number of test vectors read from the test vector file.
		int pass_count;    // Number of passed test vectors.
		int fail_count;    // Number of failed test vectors.
			
		// Open the test vector file from which the stimuli and expected responses
		// should be read.
		tvFile = $fopen(TV_FILE_PATH, "r");

		// Check whether the file has been found or not.
		if (!tvFile)
			`uvm_fatal("SEQUENCE_FILE", "Testvector file not found");

		//  We need to wait until the initial reset has been withdrawn. Hence
		//  get the configuration object from the configuration database, which
		//  provides us some nice wait_for_XXX functions.
		if(!uvm_config_db #(aes128_config)::get(null, get_full_name(), "DUV_CONFIG", aes128_cfg)) begin
			`uvm_fatal("SEQUENCE FILE", "Can't get the DUV configuration")
		end

		// Connect the DUV interface from the configuration database to the
		// local handle tot he DUV interface.
		duv_ifc = aes128_cfg.duv_ifc;

		// Wait until the initial reset has been withdrawn.
		aes128_cfg.wait_for_reset();
		`mm_info(("Reset withdrawn. Start with actual data transfer."), UVM_HIGH)

		// We want to start our actual data transfer at a new rising clock edge
		// (and not depending on the previous waiting for the reset or the
		// like). Hence, let us wait for the next rising clock edge.
		// actual data transfer.
		@(posedge duv_ifc.Clk_CI);
			
		// Now, let us read the stimuli from the already opened file until
		// there are no stimuli left and tell the driver about the read data.
		while ( !$feof(tvFile) ) begin

			// Create a new transaction using the factory for each of the test
			// vectors contained in the test vector file.
			txn = txn_request::type_id::create("txn");
				 
			// Read a full line of the file.
			bytesRead = $fgets(currLine, tvFile);

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

			// The handshaking mechanism between the sequence and the driver are
			// the start_item and the finish_item methods. So let's start
			// creating some transactions. When start_item returns, this means
			// that the driver is ready to obtain the transaction.
			start_item(txn);

			// Parse the test vector line accordingly.
			itemsMatched = $sscanf( currLine, "%h %h %h %h", 
														 	txn.new_cipherkey,
														 	txn.plaintext,
															txn.cipherkey,
															txn.ciphertext);

			// Now that we have parsed a test vector from the test vector file, we
			// also have to set the start signal of the DUV indicating that we got
			// some valid stimuli.
			txn.start = 1'b1;
				 
			`mm_info(("Parsed test vector items: %d", itemsMatched), UVM_DEBUG)
			`mm_info(("Test vector read from file: %s", txn.convert2string()), UVM_FULL)
			
			// Finally the finish_item actually sends the transaction to the
			// driver.
			finish_item(txn);
		end // while ( !feof(tvFile) )

		// Provide some information about the test vectors found in the file.
		`mm_info(("Number of test vectors read from file: %d", tvRead), UVM_LOW);
		$fclose(tvRead);
			
		// Once we are done with reading all the test vector entries, we have to
		// make sure that none of the controlling signals will indicate any
		// further valid input data.
		start_item(txn);
		txn.start = 1'b0;
		txn.new_cipherkey = 1'b0;
		finish_item(txn);

		// Since our DUV has a fixed latency of 12 clock cycles, we need to wait
		// until the last output is available (note that already one clock cycle
		// passed in the previous "start/finish_item" block.
		for ( int i = 0; i < 11; i++ ) begin
			start_item(txn);
			finish_item(txn);
		end
			
		// Create a final clock cycle in order to see that the previously set
		// values have settled in the waveforms.
		start_item(txn);
		finish_item(txn);

		// Print a short summary about passed and failed test vectors.
		if(!uvm_config_db #(int)::get(null, "", "PASS_COUNT", pass_count))
			`mm_fatal(("Cant't get the test vector pass count"))

		if(!uvm_config_db #(int)::get(null, "", "FAIL_COUNT", fail_count))
			`uvm_fatal("CONFIG_FATAL", "Cant't get the test vector fail count.")

		`mm_info(("***** SUMMARY **************************************************************"), UVM_LOW)
		`mm_info(("Testvectors Passed: %d", pass_count), UVM_LOW)
		`mm_info(("Testvectors Failed: %d", fail_count), UVM_LOW)
		`mm_info(("****************************************************************************"), UVM_LOW)

	endtask : body
	 
endclass : seq_from_file
