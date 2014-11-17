/**
 * Module: mixColumn
 * 
 * The present design implements the MixColumn operation of the Advanced
 * Encryption Standard (AES).
 *
 * General Information:
 * File         - mixColumn.vhd
 * Title        - AES MixColumn operation (single column)
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
 * File ID     - $Id: mixColumn.sv 23 2014-10-20 09:23:20Z u59323933 $
 * Revision    - $Revision: 23 $
 * Local Date  - $Date: 2014-10-20 11:23:20 +0200 (Mon, 20 Oct 2014) $
 * Modified By - $Author: u59323933 $
 * 
 * Major Revisions:
 * 2014-10-16 (v1.0) - Created (mbgh)
 */

import aes128Pkg::*;

module mixColumn (
	/**
	 * Port: In_DI
	 * 32 bit input to the MixColumn function.
	 */
	input Word In_DI,
	/**
	 * Port: Out_DO
	 * 32 bit output from the MixColumn function.
	 */
	output Word Out_DO );

	// --------------------------------------------------------------------------
	// Signals
	// --------------------------------------------------------------------------
	Byte Byte0_D, Byte0Doubled_D, Byte0Tripled_D;
  Byte Byte1_D, Byte1Doubled_D, Byte1Tripled_D;
  Byte Byte2_D, Byte2Doubled_D, Byte2Tripled_D;
  Byte Byte3_D, Byte3Doubled_D, Byte3Tripled_D;


 	// --------------------------------------------------------------------------
  // First Byte
	// --------------------------------------------------------------------------
	assign Byte0_D        = In_DI[0];
  assign Byte0Doubled_D = (In_DI[0][7] == 1'b1) ? ({ In_DI[0][6:0], 1'b0 } ^ 8'h1B) : ({ In_DI[0][6:0], 1'b0 });
  assign Byte0Tripled_D = Byte0Doubled_D ^ Byte0_D;

	// --------------------------------------------------------------------------
  // Second Byte
	// --------------------------------------------------------------------------
	assign Byte1_D        = In_DI[1];
  assign Byte1Doubled_D = (In_DI[1][7] == 1'b1) ? ({ In_DI[1][6:0], 1'b0 } ^ 8'h1B) : ({ In_DI[1][6:0], 1'b0 });
  assign Byte1Tripled_D = Byte1Doubled_D ^ Byte1_D;

	// --------------------------------------------------------------------------
  // Third Byte
	// --------------------------------------------------------------------------
  assign Byte2_D        = In_DI[2];
  assign Byte2Doubled_D = (In_DI[2][7] == 1'b1) ? ({ In_DI[2][6:0], 1'b0 } ^ 8'h1B) : ({ In_DI[2][6:0], 1'b0 });
	assign Byte2Tripled_D = Byte2Doubled_D ^ Byte2_D;

	// --------------------------------------------------------------------------
  // Fourth Byte
	// --------------------------------------------------------------------------
  assign Byte3_D        = In_DI[3];
  assign Byte3Doubled_D = (In_DI[3][7] == 1'b1) ? ({ In_DI[3][6:0], 1'b0 } ^ 8'h1B) : ({ In_DI[3][6:0], 1'b0 });
	assign Byte3Tripled_D = Byte3Doubled_D ^ Byte3_D;

	// --------------------------------------------------------------------------
  // Output Assignment
	// --------------------------------------------------------------------------
  assign Out_DO[0] = Byte0Doubled_D ^ Byte1Tripled_D ^ Byte2_D ^ Byte3_D;
  assign Out_DO[1] = Byte0_D ^ Byte1Doubled_D ^ Byte2Tripled_D ^ Byte3_D;
  assign Out_DO[2] = Byte0_D ^ Byte1_D ^ Byte2Doubled_D ^ Byte3Tripled_D;
  assign Out_DO[3] = Byte0Tripled_D ^ Byte1_D ^ Byte2_D ^ Byte3Doubled_D;
	
endmodule : mixColumn
