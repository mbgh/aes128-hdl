/**
 * Interface: aes128_ifc
 * 
 * An interface to the design under verification (DUV).
 * 
 * General Information:
 * File         - aes128_ifc.sv
 * Title        - AES-128 interface
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
 * File ID     - $Id: aes128_ifc.sv 24 2014-10-20 14:13:12Z u59323933 $
 * Revision    - $Revision: 24 $
 * Local Date  - $Date: 2014-10-20 16:13:12 +0200 (Mon, 20 Oct 2014) $
 * Modified By - $Author: u59323933 $
 * 
 * Major Revisions:
 * 2014-10-14 (v1.0) - Created (mbgh) 
 */
interface aes128_ifc();
	logic Clk_CI;
	logic Reset_RBI;
	logic Start_SI;
	logic NewCipherkey_SI;
	logic Busy_SO;
	logic [127:0] Plaintext_DI;
	logic [127:0] Cipherkey_DI;
	logic [127:0] Ciphertext_DO;
endinterface : aes128_ifc