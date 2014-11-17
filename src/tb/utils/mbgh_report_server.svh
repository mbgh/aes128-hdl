/**
 * Class: mbgh_report_server_c
 * 
 * This class provides a custom UVM report server in order to provide a nicer
 * log output in the simulator when using the UVM reporting macros. The class is
 * based on the one to be found at [1]. 
 * 
 * General Information:
 * File         - mbgh_report_server.svh
 * Title        - Project-independent UVM reporting server
 * Author       - Michael Muehlberghuber (mbgh@iis.ee.ethz.ch)
 * Company      - Integrated Systems Laboratory, ETH Zurich
 * Copyright    - Copyright (C) 2014 Integrated Systems Laboratory, ETH Zurich
 * File Created - 2014-10-14
 * Last Updated - 2014-10-14
 * Platform     - Simulation=QuestaSim; Synthesis=Synopsys
 * Standard     - SystemVerilog 1800-2009
 * 
 * Revision Control System Information:
 * File ID     - $Id: mbgh_report_server.svh 24 2014-10-20 14:13:12Z u59323933 $
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


class mbgh_report_server_c extends uvm_report_server;
	`uvm_object_utils(mbgh_report_server_c)

	string filename_cache[string];
	string hier_cache[string];

	int    unsigned file_name_width = 28;
	int    unsigned hier_width = 60;

	uvm_severity_type sev_type;
	string prefix, time_str, code_str, fill_char, file_str, hier_str;
	int    last_slash, flen, hier_len;

	function new(string name="mbgh_report_server");
		super.new();
	endfunction : new

	virtual function string compose_message(uvm_severity severity, string name, string id, string message,
                                          string filename, int line);
	// format filename & line-number
	last_slash = filename.len() - 1;
	if(file_name_width > 0) begin
		if(filename_cache.exists(filename))
			file_str = filename_cache[filename];
		else begin
			while(filename[last_slash] != "/" && last_slash != 0)
				last_slash--;
			file_str = (filename[last_slash] == "/") ?
									filename.substr(last_slash+1, filename.len()-1) :
									filename;

			flen = file_str.len();
			file_str = (flen > file_name_width) ?
									file_str.substr((flen - file_name_width), flen-1) :
									{{(file_name_width-flen){" "}}, file_str};
			filename_cache[filename] = file_str;
		end
		$swrite(file_str, "%s(%6d) ", file_str, line);
	end else
		file_str = "";

		// format hier
		hier_len = id.len();
		if(hier_width > 0) begin
			if(hier_cache.exists(id))
				hier_str = hier_cache[id];
			else begin
				if(hier_len > 13 && id.substr(0,12) == "uvm_test_top.") begin
					id = id.substr(13, hier_len-1);
					hier_len -= 13;
				end
				if(hier_len < hier_width)
					hier_str = {id, {(hier_width - hier_len){" "}}};
				else if(hier_len > hier_width)
					hier_str = id.substr(hier_len - hier_width, hier_len - 1);
				else
					hier_str = id;
				hier_str = {"[", hier_str, "]"};
				hier_cache[id] = hier_str;
			end
		end else
			hier_str = "";
		
		// format time
		$swrite(time_str, " {%t}", $time);

		// determine fill character
		sev_type = uvm_severity_type'(severity);
		case(sev_type)
			UVM_INFO:    begin code_str = "%I"; fill_char = " "; end
			UVM_ERROR:   begin code_str = "%E"; fill_char = "_"; end
			UVM_WARNING: begin code_str = "%W"; fill_char = "."; end
			UVM_FATAL:   begin code_str = "%F"; fill_char = "*"; end
			default:     begin code_str = "%?"; fill_char = "?"; end
		endcase

		// create line's prefix (everything up to time)
		$swrite(prefix, "%s-%s%s%s", code_str, file_str, hier_str, time_str);
		if(fill_char != " ") begin
			for(int x = 0; x < prefix.len(); x++)
				if(prefix[x] == " ")
					// mbgh: Added a cast.
					// prefix.putc(x, fill_char);
					prefix.putc(x, byte'(fill_char));
		end

		// append message
		return {prefix, " ", message};
		
	endfunction : compose_message
endclass : mbgh_report_server_c