/**
 * Type: aes128_sequencer
 * 
 * Usually we just use a base sequencer, which can be defined as shown in the
 * example below.
 * 
 * General Information:
 * File         - aes128_sequencer.svh
 * Title        - The UVM sequencer for the AES-128 design
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
 * File ID     - $Id: aes128_sequencer.svh 24 2014-10-20 14:13:12Z u59323933 $
 * Revision    - $Revision: 24 $
 * Local Date  - $Date: 2014-10-20 16:13:12 +0200 (Mon, 20 Oct 2014) $
 * Modified By - $Author: u59323933 $
 * 
 * Major Revisions:
 * 2014-10-14 (v1.0) - Created (mbgh) 
 */
typedef uvm_sequencer #(txn_request) aes128_sequencer;
