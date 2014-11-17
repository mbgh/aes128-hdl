/**
 * Module: subMatrix
 * 
 * Takes a matrix (i.e., 16 bytes) and substitutes the matrix using the
 * substitution box (S-box) of the Advanced Encryption Standard (AES). This is
 * done by instantiating four "SubWord" entities, each operating on a single
 * word.
 * 
 * General Information:
 * File         - subMatrix.vhd
 * Title        - AES substitute matrix function
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
 * File ID     - $Id: subMatrix.sv 23 2014-10-20 09:23:20Z u59323933 $
 * Revision    - $Revision: 23 $
 * Local Date  - $Date: 2014-10-20 11:23:20 +0200 (Mon, 20 Oct 2014) $
 * Modified By - $Author: u59323933 $
 * 
 * Major Revisions:
 * 2014-10-16 (v1.0) - Created (mbgh)
 */

import aes128Pkg::*;

module subMatrix (
	/**
	 * Port: In_DI
	 * 16 byte input to be substituted using the AES S-box.
	 */
	input Matrix In_DI,
	/**
	 * Port: Out_DO
	 * Substituted 12 bytes.
	 */
	output Matrix Out_DO );

	// --------------------------------------------------------------------------
	// Component instantiations
	// --------------------------------------------------------------------------
	subWord subWord_0 (.In_DI(In_DI[0]), .Out_DO(Out_DO[0]));
	subWord subWord_1 (.In_DI(In_DI[1]), .Out_DO(Out_DO[1]));
	subWord subWord_2 (.In_DI(In_DI[2]), .Out_DO(Out_DO[2]));
	subWord subWord_3 (.In_DI(In_DI[3]), .Out_DO(Out_DO[3]));
	
endmodule // subMatrix
