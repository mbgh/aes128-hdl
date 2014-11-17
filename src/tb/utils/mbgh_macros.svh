/**
 * Title: mbgh_macros
 * 
 * This file contains a couple of project-independent SystemVerilog macros,
 * including reporting macros and the like. 
 * 
 * General Information:
 * File         - mbgh_macros.svh
 * Title        - Project-independent macros by Michael Muehlberghuber
 * Author       - Michael Muehlberghuber (mbgh@iis.ee.ethz.ch)
 * Company      - Integrated Systems Laboratory, ETH Zurich
 * Copyright    - Copyright (C) 2014 Integrated Systems Laboratory, ETH Zurich
 * File Created - 2014-10-14
 * Last Updated - 2014-10-14
 * Platform     - Simulation=QuestaSim; Synthesis=Synopsys
 * Standard     - SystemVerilog 1800-2009
 * 
 * Revision Control System Information:
 * File ID     - $Id: mbgh_macros.svh 24 2014-10-20 14:13:12Z u59323933 $
 * Revision    - $Revision: 24 $
 * Local Date  - $Date: 2014-10-20 16:13:12 +0200 (Mon, 20 Oct 2014) $
 * Modified By - $Author: u59323933 $
 * 
 * Major Revisions:
 * 2014-10-14 (v1.0) - Created (mbgh)
 * 
 * References:
 * [1] - https://www.vmmcentral.org/vmartialarts/2012/04/customizing-uvm-messages-without-getting-a-sunburn/
 */

/**
 * Macro: mm_info
 * A custom info macro, which should substitute the uvm_report_info function.
 * The command is mainly based on the one to be found at [1]. Note that all IDs
 * get replaced with the full hierarchy (since those IDs are usually not used
 * very meaningful and you do not want to think about a certain ID each time
 * you write an info message). You will need parenthesis around the first
 * parameter of the custom info command even when there are no parameters
 * (e.g., `mm_info(("Test"), UVM_FULL) and *not* `mm_info("Test", UVM_FULL).
 * This is due to the fact that we use the $sformatf function and macros are
 * pretty dumb.
 */
`define mm_info(MSG, VERBOSITY) \
begin \
	if(uvm_report_enabled(VERBOSITY,UVM_INFO,get_full_name())) \
  	uvm_report_info(get_full_name(), $sformatf MSG, 0, `uvm_file, `uvm_line); \
end

/**
 * Macro: mm_warn
 * A custom warn macro, which should substitute the uvm_report_warning function.
 * The command is mainly based on the one to be found at [1]. Note that all IDs
 * get replaced with the full hierarchy (since those IDs are usually not used
 * very meaningful and you do not want to think about a certain ID each time
 * you write an info message). You will need parenthesis around the first
 * parameter of the custom warning command even when there are no parameters
 * (e.g., `mm_warn(("Test"), UVM_FULL) and *not* `mm_warn("Test", UVM_FULL).
 * This is due to the fact that we use the $sformatf function and macros are
 * pretty dumb.
 */
`define mm_warn(MSG) \
begin \
	if(uvm_report_enabled(UVM_NONE,UVM_WARNING,get_full_name())) \
		uvm_report_warning(get_full_name(), $sformatf MSG, UVM_NONE, `uvm_file, `uvm_line); \
end

/**
 * Macro: mm_error
 * A custom error macro, which should substitute the uvm_report_error function.
 * The command is mainly based on the one to be found at [1]. Note that all IDs
 * get replaced with the full hierarchy (since those IDs are usually not used
 * very meaningful and you do not want to think about a certain ID each time
 * you write an info message). You will need parenthesis around the first
 * parameter of the custom error command even when there are no parameters
 * (e.g., `mm_error(("Test"), UVM_FULL) and *not* `mm_error("Test", UVM_FULL).
 * This is due to the fact that we use the $sformatf function and macros are
 * pretty dumb.
 */
`define mm_error(MSG) \
begin \
	if(uvm_report_enabled(UVM_NONE,UVM_ERROR,get_full_name())) \
		uvm_report_error(get_full_name(), $sformatf MSG, UVM_NONE, `uvm_file, `uvm_line); \
end

/**
 * Macro: mm_fatal
 * A custom fatal macro, which should substitute the uvm_report_fatal function.
 * The command is mainly based on the one to be found at [1]. Note that all IDs
 * get replaced with the full hierarchy (since those IDs are usually not used
 * very meaningful and you do not want to think about a certain ID each time
 * you write an info message). You will need parenthesis around the first
 * parameter of the custom fatal command even when there are no parameters
 * (e.g., `mm_fatal(("Test"), UVM_FULL) and *not* `mm_fatal("Test", UVM_FULL).
 * This is due to the fact that we use the $sformatf function and macros are
 * pretty dumb.
 */
`define mm_fatal(MSG) \
begin \
	if(uvm_report_enabled(UVM_NONE,UVM_FATAL,get_full_name())) \
  	uvm_report_fatal(get_full_name(), $sformatf MSG, UVM_NONE, `uvm_file, `uvm_line); \
end

			 
/**
 * Macro: mm_info_static
 * This is the counterpart to the <mm_info> macro for static classes. This is
 * required since static classes cannot handle calls to the get_full_name()
 * function.
 */
`define mm_info_static(MSG) \
begin \
	string full_name = {type_name, "::<static>"}; \
	if(uvm_report_enabled(UVM_NONE, UVM_INFO, full_name)) \
		uvm_top.uvm_report_info(full_name, $sformatf MSG, 0, `uvm_file, `ufm_line); \
end 

/**
 * Macro: mm_warn_static
 * This is the counterpart to the <mm_warn> macro for static classes. This is
 * required since static classes cannot handle calls to the get_full_name()
 * function.
 */
`define mm_warn_static(MSG) \
begin \
	string full_name = {type_name, "::<static>"}; \
	if(uvm_report_enabled(UVM_NONE, UVM_WARNING, full_name)) \
		uvm_top.uvm_report_warning(full_name, $sformatf MSG, 0, `uvm_file, `ufm_line); \
end 

/**
 * Macro: mm_error_static
 * This is the counterpart to the <mm_error> macro for static classes. This is
 * required since static classes cannot handle calls to the get_full_name()
 * function.
 */
`define mm_error_static(MSG) \
begin \
	string full_name = {type_name, "::<static>"}; \
	if(uvm_report_enabled(UVM_NONE, UVM_ERROR, full_name)) \
		uvm_top.uvm_report_error(full_name, $sformatf MSG, 0, `uvm_file, `ufm_line); \
end 

/**
 * Macro: mm_fatal_static
 * This is the counterpart to the <mm_fatal> macro for static classes. This is
 * required since static classes cannot handle calls to the get_full_name()
 * function.
 */
`define mm_fatal_static(MSG) \
begin \
	string full_name = {type_name, "::<static>"}; \
	if(uvm_report_enabled(UVM_NONE, UVM_FATAL, full_name)) \
		uvm_top.uvm_report_fatal(full_name, $sformatf MSG, 0, `uvm_file, `ufm_line); \
end 

/**
 * Macro: mm_info_ifc
 * This is the counterpart to the <mm_info> macro for interfaces. This is
 * required since interfaces cannot handle calls to the get_full_name()
 * function.
 */
`define mm_info_ifc(MSG) \
	uvm_top.uvm_report_info($sformatf("%m"), $sformatf MSG, 0, `uvm_file, `uvm_line);

/**
 * Macro: mm_warn_ifc
 * This is the counterpart to the <mm_warn> macro for interfaces. This is
 * required since interfaces cannot handle calls to the get_full_name()
 * function.
 */
`define mm_warn_ifc(MSG) \
	uvm_top.uvm_report_warning($sformatf("%m"), $sformatf MSG, 0, `uvm_file, `uvm_line);
	
/**
 * Macro: mm_error_ifc
 * This is the counterpart to the <mm_error> macro for interfaces. This is
 * required since interfaces cannot handle calls to the get_full_name()
 * function.
 */
`define mm_err_ifc(MSG) \
	uvm_top.uvm_report_error($sformatf("%m"), $sformatf MSG, 0, `uvm_file, `uvm_line);

/**
 * Macro: mm_fatal_ifc
 * This is the counterpart to the <mm_fatal> macro for interfaces. This is
 * required since interfaces cannot handle calls to the get_full_name()
 * function.
 */
`define mm_fatal_ifc(MSG) \
	uvm_top.uvm_report_fatal($sformatf("%m"), $sformatf MSG, 0, `uvm_file, `uvm_line);