/**
 * Package: mbgh_utils
 * 
 * A utility-package which contains project-independent supporting code. 
 * 
 * General Information:
 * File         - mbgh_utils.svh
 * Title        - Project-independent supporting code
 * Author       - Michael Muehlberghuber (mbgh@iis.ee.ethz.ch)
 * Company      - Integrated Systems Laboratory, ETH Zurich
 * Copyright    - Copyright (C) 2014 Integrated Systems Laboratory, ETH Zurich
 * File Created - 2014-10-14
 * Last Updated - 2014-10-14
 * Platform     - Simulation=QuestaSim; Synthesis=Synopsys
 * Standard     - SystemVerilog 1800-2009
 * 
 * Revision Control System Information:
 * File ID     - $Id: mbgh_utils_pkg.sv 24 2014-10-20 14:13:12Z u59323933 $
 * Revision    - $Revision: 24 $
 * Local Date  - $Date: 2014-10-20 16:13:12 +0200 (Mon, 20 Oct 2014) $
 * Modified By - $Author: u59323933 $
 * 
 * Major Revisions:
 * 2014-10-14 (v1.0) - Created (mbgh)
 */
package mbgh_utils_pkg;
	
	/**
	 * Function: strip_leading_spaces
	 * Strips away leading spaces from a string.
	 */
	function string strip_leading_spaces(string inp);
		while(inp.substr(0, 0) == " ") begin
			inp = inp.substr(1, inp.len()-1);
		end
		return inp;
	endfunction : strip_leading_spaces

	/**
	 * Function: strip_trailing_spaces
	 * Strips away trailing spaces from a string.
	 */
	function string strip_trailing_spaces(string inp);
		while(inp.substr(inp.len()-1, inp.len()-1) == " ") begin
			inp = inp.substr(0, inp.len()-2);
		end
		return inp;
	endfunction : strip_trailing_spaces

endpackage : mbgh_utils_pkg
	 