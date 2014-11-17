/**
 * Class: txn_data
 * 
 * A transaction containing only the data being transferred between the DUV and
 * its environment.
 *
 * Note: There is no reason to extend a user transaction directly from
 * uvm_transaction. Always use uvm_sequence_item as the base class.
 * 
 * General Information:
 * File         - txn_data.svh
 * Title        - Data transaction of the AES-128 DUV
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
 * File ID     - $Id: txn_data.svh 24 2014-10-20 14:13:12Z u59323933 $
 * Revision    - $Revision: 24 $
 * Local Date  - $Date: 2014-10-20 16:13:12 +0200 (Mon, 20 Oct 2014) $
 * Modified By - $Author: u59323933 $
 * 
 * Major Revisions:
 * 2014-10-14 (v1.0) - Created (mbgh) 
 */
class txn_data extends uvm_sequence_item;
	 
	// Tell the factory about the transaction. Since transactions are no UVM
	// components, but get directly extended from the uvm_object, they do not use
	// the uvm_components_utils macro to register to the factory, but the
	// uvm_object_utils macro.
	`uvm_object_utils(txn_data)

	// Data fields/attributes required for the transaction.
	logic[127:0] cipherkey;
	logic[127:0] plaintext;
	logic[127:0] ciphertext;

	// The constructor of the class. Note that the constructor does not have a
	// parent, since they are not part of the component hierarchy.
	function new (string name = "");
		super.new(name);
	endfunction : new

	// Provide a nice string in order to print the transaction using the do_print
	// method or the convert2string function directly.
	function string convert2string();
		return $sformatf("Cipherkey=%h, Plaintext=%h, Ciphertext=%h", cipherkey, plaintext, ciphertext);
	endfunction : convert2string

	// Implement the do_copy function since it is used, for instance, by the
	// clone method of UVM.
	virtual function void do_copy(uvm_object rhs);
		txn_data RHS;
		super.do_copy(rhs);
		$cast(RHS,rhs);
		cipherkey = RHS.cipherkey;
		plaintext = RHS.plaintext;
		ciphertext = RHS.ciphertext;
	endfunction : do_copy

	// Create a function that allows simple loading of data into the
	// transaction.
	function void load_data(logic[127:0] _plaintext, logic[127:0] _cipherkey, logic[127:0] _ciphertext);
		cipherkey  = _cipherkey;
		plaintext  = _plaintext;
		ciphertext = _ciphertext;
	endfunction : load_data

	// Create a function that allows to compare two transactions.
	virtual function bit comp(uvm_object rhs);
		txn_data RHS;
		$cast(RHS, rhs);
		// Return one if all of the member variables are equal.
		return ((RHS.cipherkey == cipherkey) && (RHS.plaintext == plaintext) && (RHS.ciphertext == ciphertext));
	endfunction : comp

	virtual function bit comp_ciphertext(uvm_object rhs);
		txn_data RHS;
		$cast(RHS, rhs);
		// Return one of the ciphertexts are equal.
		return (RHS.ciphertext == ciphertext);
	endfunction : comp_ciphertext
	 
endclass : txn_data
