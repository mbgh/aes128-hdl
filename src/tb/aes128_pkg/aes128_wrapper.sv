/**
 * Module: aes128_wrapper
 * 
 * A SystemVerilog wrapper for both the VHDL and the SystemVerilog DUV. Thereby
 * a unique interface is used by the verification environment for both designs.
 * 
 * General Information:
 * File         - aes128_wrapper.svh
 * Title        - SystemVerilog DUV (design under verification) wrapper
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
 * File ID     - $Id: aes128_wrapper.sv 24 2014-10-20 14:13:12Z u59323933 $
 * Revision    - $Revision: 24 $
 * Local Date  - $Date: 2014-10-20 16:13:12 +0200 (Mon, 20 Oct 2014) $
 * Modified By - $Author: u59323933 $
 * 
 * Major Revisions:
 * 2014-10-14 (v1.0) - Created (mbgh)
 */
module aes128_wrapper (aes128_ifc ifc);
	aes128 duv(
		.Clk_CI(ifc.Clk_CI),
		.Reset_RBI(ifc.Reset_RBI),
		.Start_SI(ifc.Start_SI),
		.NewCipherkey_SI(ifc.NewCipherkey_SI),
		.Busy_SO(ifc.Busy_SO),
		.Plaintext_DI(ifc.Plaintext_DI),
		.Cipherkey_DI(ifc.Cipherkey_DI),
		.Ciphertext_DO(ifc.Ciphertext_DO));
endmodule : aes128_wrapper	 
