/**
 * Module: keyExpansion
 * 
 * The present design implements the key expansion for the 128-bit version of
 * the Advanced Encryption Standard (AES). Since the design targets a
 * high-throughput implementation, the key expansion is implemented using
 * pipeline register between each roundkey calculation.
 * 
 * General Information:
 * File         - keyExpansion.vhd
 * Title        - AES-128 key expansion
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
 * File ID     - $Id: keyExpansion.sv 42 2014-10-30 12:17:09Z u59323933 $
 * Revision    - $Revision: 42 $
 * Local Date  - $Date: 2014-10-30 13:17:09 +0100 (Thu, 30 Oct 2014) $
 * Modified By - $Author: u59323933 $
 * 
 * Major Revisions:
 * 2014-10-16 (v1.0) - Created (mbgh)
 */

import aes128Pkg::*;

module keyExpansion (
	/**
	 * Port: Clk_CI
	 * System clock.
	 */
	input logic             Clk_CI,
	/**
	 * Port: Reset_RBI
	 * Asynchronous, active-high reset.
	 */
	input logic 				     Reset_RBI,
	/**
	 * Port: Start_SI
	 * Determines whether a new cipherkey has been applied or not.
	 * 
	 * 0 - No new cipherkey has been applied.
	 * 1 - New cipherkey has been applied.
	 */
	input logic 				     Start_SI,
	/**
	 * Port: Cipherkey_DI
	 * The cipher key (master key) for the encryption.
	 */
	input logic [127:0]     Cipherkey_DI,
	/**
	 * Port: Roundkeys_DO
	 * The generated round keys.
	 * */
	output roundkeyArrayType Roundkeys_DO);

	// --------------------------------------------------------------------------
	// Type definitions
	// --------------------------------------------------------------------------
	/**
	 * Type: byteArrayType
	 * An array holding 10 bytes.
	 */
	typedef logic [7:0] byteArrayType [0:9];
	/**
	 * Type: subWordArrayType
	 * An array holding 10 words.
	 */
	typedef Word subWordArrayType [0:9];
	/**
	 * Type: expkeyArrayType
	 * An array holding the 44 words, containing all of the roundkeys (including
	 * the cipherkey for the first round).
	 */
	typedef Word expkeyArrayType [0:43];
	/**
	 * Type: rconArrayType
	 * An array holding 10 words (for the round constants).
	 */
	typedef Word rconArrayType [0:9];


	// --------------------------------------------------------------------------
	// Constants
	// --------------------------------------------------------------------------
	const byteArrayType RCON = '{ 8'h01, 8'h02, 8'h04, 8'h08, 8'h10,
                                8'h20, 8'h40, 8'h80, 8'h1B, 8'h36 };
		 

	// --------------------------------------------------------------------------
	// Functions
	// --------------------------------------------------------------------------
	
	/**
	 * Function: to_logic
	 * 
	 * Converts four Words into a logic [127:0].
	 */
	function logic [127:0] to_logic;
		input Word          column0;
		input Word          column1;
		input Word          column2;
		input Word          column3;
		      logic [127:0] result;
		begin
			result = { column0[0], column0[1], column0[2], column0[3],
                 column1[0], column1[1], column1[2], column1[3],
                 column2[0], column2[1], column2[2], column2[3],
                 column3[0], column3[1], column3[2], column3[3]};
			to_logic = result;
		end
	endfunction : to_logic

	/**
	 * Function: xor_words
	 * 
	 * An exclusive-or (XOR) operation for two Words.
	 */
	function Word xor_words ;
		input Word left;
		input Word right;
          Word result;
		begin
			result[0] = left[0] ^ right[0];
			result[1] = left[1] ^ right[1];
			result[2] = left[2] ^ right[2];
			result[3] = left[3] ^ right[3];
			xor_words = result;
		end
	endfunction


	// --------------------------------------------------------------------------
	// Signals
	// --------------------------------------------------------------------------
	
	// ExpKey_D: Array of 32-bit words (each made up of four bytes) holding the
  // expanded key.
  expkeyArrayType ExpKey_DN, ExpKey_DP;

  // SubWordIn_D: Array holding the ten inputs, each of them one 32-word wide,
  // connected to the input of the AES S-box.
  subWordArrayType SubWordIn_D;

  // SubWordOut_D: Array holding the ten outputs, each of them one 32-word
  // wide, connected to the output of the AES S-box.
  subWordArrayType SubWordOut_D;

  // Rcon_D: Array holding the ten signals after the XOR operation with the
  // round constants.
  rconArrayType Rcon_D;

  // Roundkeys_D: Array holding all the roundkeys produced by the key epansion.
  roundkeyArrayType Roundkeys_D;

  // Shift register holding the enables for the roundkey registers.
  logic [0:9] EnRndKeys_SN, EnRndKeys_SP;

  // Indicates that all roundkey registers currently hold their correct value
  // and must not be enabled (e.g., no new cipherkey is provided to the design
  // and the corresponding roundkeys have already been derived).
	logic AllEnRndKeysOred_S;
  logic AllRndKeysDisabled_S;


	// --------------------------------------------------------------------------
	// Component instantiations
	// --------------------------------------------------------------------------

	// Generate the ten SubWord instances.
	genvar i;
	generate for (i=0; i<10; i=i+1)
		begin : gen_subWords
			subWord subWords (.In_DI(SubWordIn_D[i]), .Out_DO(SubWordOut_D[i]));
	 	end
	endgenerate


	// --------------------------------------------------------------------------
	// Output assignments
	// --------------------------------------------------------------------------
	
	// Connect the columns of the expanded key to the round key outputs.
	generate	for (i=0; i<11; i=i+1)
		begin : gen_outputKeys
			assign Roundkeys_DO[i] = to_logic( ExpKey_DP[4*i], ExpKey_DP[4*i+1], ExpKey_DP[4*i+2], ExpKey_DP[4*i+3] );
	 	end
	endgenerate


	// --------------------------------------------------------------------------
  // Calculation of further round key words.
	// --------------------------------------------------------------------------

  // Since the "RotWord" function only performs a byte-wise rotation of a word,
  // we can perform it either before or after the "SubWord" substitution.
	generate	for (i=0; i<10; i=i+1)
		begin : gen_roundKeysFirst
			assign SubWordIn_D[i] = ExpKey_DP[4*i+3];

			assign Rcon_D[i][0] = SubWordOut_D[i][1] ^ RCON[i];
			assign Rcon_D[i][1] = SubWordOut_D[i][2];
			assign Rcon_D[i][2] = SubWordOut_D[i][3];
			assign Rcon_D[i][3] = SubWordOut_D[i][0];
		end
	endgenerate

	
	// Next state computation of the expanded key (column-by-column
	// representation of the roundkeys).
	always_comb begin
		
		// Defaults
		ExpKey_DN = ExpKey_DP;
		
		// Use the first roundkey (i.e., the actual cipherkey) as the first four
		// 32-bit words (columns) of the expanded key.
		if (Start_SI == 1'b1) begin
			ExpKey_DN[0] = to_word(Cipherkey_DI[127:96]);	
			ExpKey_DN[1] = to_word(Cipherkey_DI[95:64]);
			ExpKey_DN[2] = to_word(Cipherkey_DI[63:32]);
			ExpKey_DN[3] = to_word(Cipherkey_DI[31:0]);
		end
		
		// Calculate the next expanded key only when the respective enable
		// signal is set.
		for (int j=0; j<10; j=j+1) begin
			if ( EnRndKeys_SP[j] == 1'b1 ) begin
				ExpKey_DN[4*(j+1)+0] = xor_words(Rcon_D[j], ExpKey_DP[4*j]);
				ExpKey_DN[4*(j+1)+1] = xor_words(Rcon_D[j], xor_words(ExpKey_DP[4*j], ExpKey_DP[4*j+1]));
				ExpKey_DN[4*(j+1)+2] = xor_words(Rcon_D[j], xor_words(ExpKey_DP[4*j], xor_words(ExpKey_DP[4*j+1], ExpKey_DP[4*j+2])));
				ExpKey_DN[4*(j+1)+3] = xor_words(Rcon_D[j], xor_words(ExpKey_DP[4*j], xor_words(ExpKey_DP[4*j+1], xor_words(ExpKey_DP[4*j+2], ExpKey_DP[4*j+3]))));
			end
		end
	end


	// --------------------------------------------------------------------------
  // Compute the next state logic for the shift register holding the enables for
  // the roundkeys.
	// --------------------------------------------------------------------------

	// The enables for the roundkeys are generated by a one-hot encoded shift
  // register, which gets the start signal as an input.
  always_comb begin
		// Otherwise shift the enables such that they are proceeded correctly
		// together with their current pipeline stage (this enables-holding shift
		// register serves as kind of a shimming register).
		EnRndKeys_SN = { 1'b0, EnRndKeys_SP[0:8] };

		if ( Start_SI == 1'b1 ) begin
			// Start signal is set, so shift in a '1'.
			EnRndKeys_SN = { 1'b1, EnRndKeys_SP[0:8] };
		end else if ( AllRndKeysDisabled_S == 1'b1 ) begin
			// Since none of the roundkeys currently holds a substantial value, we
			// do not even have to shift in the zeros, but just hold the current
			// state (this might be the case when the encryption pipeline has been
			// emptied and no encryption is going on anymore, i.e., no other
			// plaintext blocks have been provided).
			EnRndKeys_SN = EnRndKeys_SP;
		end
	end
	
	
	// --------------------------------------------------------------------------
  // Compute the signal indicating that none of the roundkey registers has to
  // be updated, i.e., no new cipherkey has to be propagated through the key
  // expansion pipeline registers.
  // --------------------------------------------------------------------------
	assign AllEnRndKeysOred_S = |EnRndKeys_SP;
	assign AllRndKeysDisabled_S = ~AllEnRndKeysOred_S;

	
  // --------------------------------------------------------------------------
	// Flip flops
	// --------------------------------------------------------------------------
	always_ff @(posedge Clk_CI, negedge Reset_RBI) begin
		if ( ~Reset_RBI ) begin
			ExpKey_DP    <= '{ default:0 };
			EnRndKeys_SP <= 0;
		end else begin
			ExpKey_DP    <= ExpKey_DN;
			EnRndKeys_SP <= EnRndKeys_SN;
		end
	end
	
endmodule // keyExpansion
