/**
 * Module: cipherRound
 * 
 * Implements a single cipher round of the AES-128 encryption algorithm, which
 * can then be instantiated multiple times in order to create a high-throughput
 * architecture.
 *
 * General Information:
 * File         - cipherRound.vhd
 * Title        - AES-128 single cipher round
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
 * File ID     - $Id: cipherRound.sv 23 2014-10-20 09:23:20Z u59323933 $
 * Revision    - $Revision: 23 $
 * Local Date  - $Date: 2014-10-20 11:23:20 +0200 (Mon, 20 Oct 2014) $
 * Modified By - $Author: u59323933 $
 * 
 * Major Revisions:
 * 2014-10-16 (v1.0) - Created (mbgh)
 */

import aes128Pkg::*;

module cipherRound (
	/**
	 * Port: StateIn_DI
	 * The matrix to be fed into the cipher round.
	 */
	input Matrix StateIn_DI,
	/**
	 * Port: Roundkey_DI
	 * The roundkey to be used for the cipher round.
	 */
	input logic [127:0] Roundkey_DI,
	/**
	 * Port: StateOut_DO
	 * The output from the cipher round.
	 */
	output Matrix StateOut_DO );


	// --------------------------------------------------------------------------
	// Signals
	// --------------------------------------------------------------------------
	Matrix SubMatrixOut_D; // State after "SubMatrix".
	Matrix ShiftRowsOut_D; // State after "ShiftRows".
	Matrix MixMatrixOut_D; // State after "MixColumns".

	
	// --------------------------------------------------------------------------
	// Component instantiations
	// --------------------------------------------------------------------------
	subMatrix subMatrix_1 (.In_DI(StateIn_DI), .Out_DO(SubMatrixOut_D));
	mixMatrix mixMatrix_1 (.In_DI(ShiftRowsOut_D), .Out_DO(MixMatrixOut_D));

	assign ShiftRowsOut_D = shift_rows(SubMatrixOut_D);
	assign StateOut_DO    = xor_matrix_logic(MixMatrixOut_D, Roundkey_DI);
	
endmodule : cipherRound
