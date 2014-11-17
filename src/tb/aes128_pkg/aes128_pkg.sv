/**
 * Package: aes128_pkg
 * 
 * All the class declarations to be used throughout the verification environment
 * are loaded within this file. This prevents from loading or including packages
 * or classes twice and thereby risking some unpredictable behavior.
 * 
 * General Information:
 * File         - aes128_pkg.sv
 * Title        - AES-128 package for the UVM verification environment
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
 * File ID     - $Id: aes128_pkg.sv 24 2014-10-20 14:13:12Z u59323933 $
 * Revision    - $Revision: 24 $
 * Local Date  - $Date: 2014-10-20 16:13:12 +0200 (Mon, 20 Oct 2014) $
 * Modified By - $Author: u59323933 $
 * 
 * Major Revisions:
 * 2014-10-14 (v1.0) - Created (mbgh) 
 */
package aes128_pkg;
	 
// *****************************************************************************
// ***** Standard UVM package and macros
// *****************************************************************************	 
	import uvm_pkg::*;
`include "uvm_macros.svh"

	 
// *****************************************************************************
// ***** Any further package imports should come here.
// *****************************************************************************	 
	import mbgh_utils_pkg::*;


// *****************************************************************************
// ***** Include class templates in the order in which they should be compiled.
// *****************************************************************************

// Include some design-independent files.
`include "../utils/mbgh_macros.svh"
`include "../utils/mbgh_report_server.svh"

// Include the design-specific configuration object.
`include "aes128_config.svh"

// Include transactions.
`include "./txns/txn_data.svh"
`include "./txns/txn_request.svh"

// Include sequences.
`include "./seqs/seq_from_file.svh"

// Include the agent(s).
`include "./agnts/custom_ifc_agent/aes128_sequencer.svh"
`include "./agnts/custom_ifc_agent/aes128_driver.svh"
`include "./agnts/custom_ifc_agent/aes128_monitor.svh"
`include "./agnts/custom_ifc_agent/aes128_agent.svh"
`include "./agnts/custom_ifc_agent/aes128_predictor.svh"
`include "./agnts/custom_ifc_agent/aes128_comparator.svh"

// Include the environment.
`include "aes128_env.svh"
	 
// Include the test(s).
`include "./tests/aes128_test.svh"
	 
endpackage : aes128_pkg