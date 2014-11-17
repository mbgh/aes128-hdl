/**
 * Package: aes128Pkg
 * 
 * A package for the 128-bit version of the Advanced Encryption Standard (AES)
 * design. A couple of types, constants, and functions are defined herein,
 * which are used throughout the whole design.
 * 
 * General Information:
 * File         - aes128Pkg.sv
 * Title        - AES-128 package
 * Project      - VLSI Book AES-128 Example
 * Author       - Michael Muehlberghuber (mbgh@iis.ee.ethz.ch)
 * Company      - Integrated Systems Laboratory, ETH Zurich
 * Copyright    - Copyright (C) 2014 Integrated Systems Laboratory, ETH Zurich
 * File Created - 2014-10-16
 * Last Updated - 2014-10-16
 * Platform     - Simulation=QuestaSim; Synthesis=Synopsys
 * Standard     - SystemVerilog 1800-2009
 * 
 * Revision Control System Information:
 * File ID     - $Id: aes128Pkg.sv 33 2014-10-22 07:26:02Z u59323933 $
 * Revision    - $Revision: 33 $
 * Local Date  - $Date: 2014-10-22 09:26:02 +0200 (Wed, 22 Oct 2014) $
 * Modified By - $Author: u59323933 $
 * 
 * Major Revisions:
 * 2014-10-16 (v1.0) - Created (mbgh)
 */

package aes128Pkg;
	
	// --------------------------------------------------------------------------
 	// Type definitions
	// --------------------------------------------------------------------------
	/**
	 * Type: Byte
	 * A synonym for a logic[7:0].
	 */
	typedef logic [7:0]		Byte;
	
	/**
	 * Type: Word
	 * A word made up of four <Bytes>.
	 */
	typedef Byte					Word [0:3];
	
	/**
	 * Type: Matrix
	 * A matrix made up of four <Words>.
	 */
	typedef Word        	Matrix [0:3];
	
	/**
	 * Type: roundkeyArrayType
	 * An array for holding 11 round keys (each of them represented using a
	 * logic[127:0]).
	 */
	typedef logic [127:0] roundkeyArrayType [0:10];


	// --------------------------------------------------------------------------
	// Functions
	// --------------------------------------------------------------------------
	
	/**
	 * Function: to_word
	 * 
	 * Converts a Word to a logic[31:0].
	 */
	function automatic Word to_word;
		input logic [31:0] inp;
		Word result;
		begin
			result[0] = inp[31:24];
			result[1] = inp[23:16];
			result[2] = inp[15:8];
			result[3] = inp[7:0];
			to_word = result;
		end
	endfunction : to_word
	
	/**
	 * Function: shift_rows
	 * 
	 * Shifts the rows of a provided Matrix as defined for AES.
	 */
	function automatic Matrix shift_rows;
		input Matrix inp;
		Matrix result;
		begin
			// First row
			result[0][0] = inp[0][0];
			result[1][0] = inp[1][0];
			result[2][0] = inp[2][0];
			result[3][0] = inp[3][0];
	
			// Second row
			result[0][1] = inp[1][1];
			result[1][1] = inp[2][1];
			result[2][1] = inp[3][1];
			result[3][1] = inp[0][1];
	
			// Third row
			result[0][2] = inp[2][2];
			result[1][2] = inp[3][2];
			result[2][2] = inp[0][2];
			result[3][2] = inp[1][2];

			// Fourth row
			result[0][3] = inp[3][3];
			result[1][3] = inp[0][3];
			result[2][3] = inp[1][3];
			result[3][3] = inp[2][3];

			shift_rows = result;
		end
	endfunction : shift_rows
	 
	/**
	 * Function: xor_matrix_logic
	 * 
	 * Perform an XOR operation given a Matrix and a logic[127:0].
	 */
	function automatic Matrix xor_matrix_logic;
		input Matrix left;
		input logic[127:0] right;
  	Matrix result;
		begin
			// First Column
			result[0][0] = left[0][0] ^ right[127:120];
			result[0][1] = left[0][1] ^ right[119:112];
			result[0][2] = left[0][2] ^ right[111:104];
			result[0][3] = left[0][3] ^ right[103:96];
			// Second Column
			result[1][0] = left[1][0] ^ right[95:88];
			result[1][1] = left[1][1] ^ right[87:80];
			result[1][2] = left[1][2] ^ right[79:72];
			result[1][3] = left[1][3] ^ right[71:64];
			// Third Column
			result[2][0] = left[2][0] ^ right[63:56];
			result[2][1] = left[2][1] ^ right[55:48];
			result[2][2] = left[2][2] ^ right[47:40];
			result[2][3] = left[2][3] ^ right[39:32];
			// Fourth Column
			result[3][0] = left[3][0] ^ right[31:24];
			result[3][1] = left[3][1] ^ right[23:16];
			result[3][2] = left[3][2] ^ right[15:8];
			result[3][3] = left[3][3] ^ right[7:0];
	
			xor_matrix_logic = result;
		end
	endfunction : xor_matrix_logic

endpackage : aes128Pkg
	 