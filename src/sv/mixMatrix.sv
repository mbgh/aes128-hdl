/**
 * Module: mixMatrix
 * 
 * The present design applies the "MixColumns" operation of the Advanced
 * Encryption Standard (AES) to all four columns of the AES State.
 *
 * General Information:
 * File         - mixMatrix.vhd
 * Title        - AES state MixColumn
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
 * File ID     - $Id: mixMatrix.sv 23 2014-10-20 09:23:20Z u59323933 $
 * Revision    - $Revision: 23 $
 * Local Date  - $Date: 2014-10-20 11:23:20 +0200 (Mon, 20 Oct 2014) $
 * Modified By - $Author: u59323933 $
 * 
 * Major Revisions:
 * 2014-10-16 (v1.0) - Created (mbgh)
 */

import aes128Pkg::*;

module mixMatrix (
	/**
	 * Port: In_DI
	 * 32 bit input to the MixMatrix function.
	 */
	input Matrix In_DI,
	/**
	 * Port: Out_DO
	 * 32 bit output from the MixMatrix function.
	 */
	output Matrix Out_DO );

	// --------------------------------------------------------------------------
	// Component instantiations
	// --------------------------------------------------------------------------
	mixColumn mixColumn_0 (.In_DI(In_DI[0]), .Out_DO(Out_DO[0]));
	mixColumn mixColumn_1 (.In_DI(In_DI[1]), .Out_DO(Out_DO[1]));
	mixColumn mixColumn_2 (.In_DI(In_DI[2]), .Out_DO(Out_DO[2]));
	mixColumn mixColumn_3 (.In_DI(In_DI[3]), .Out_DO(Out_DO[3]));
	
endmodule : mixMatrix
