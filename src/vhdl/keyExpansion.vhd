-------------------------------------------------------------------------------
--! @file       keyExpansion.vhd
--! @brief      AES-128 key expansion
--! @project    VLSI Book - AES-128 Example
--! @author     Michael Muehlberghuber (mbgh@iis.ee.ethz.ch)
--! @company    Integrated Systems Laboratory, ETH Zurich
--! @copyright  Copyright (C) 2014 Integrated Systems Laboratory, ETH Zurich
--! @date       2014-06-05
--! @updated    2014-10-30
--! @platform   Simulation: ModelSim; Synthesis: Synopsys
--! @standard   VHDL'93/02
-------------------------------------------------------------------------------
-- Revision Control System Information:
-- File ID      :  $Id: keyExpansion.vhd 43 2014-10-30 12:22:52Z u59323933 $
-- Revision     :  $Revision: 43 $
-- Local Date   :  $Date: 2014-10-30 13:22:52 +0100 (Thu, 30 Oct 2014) $
-- Modified By  :  $Author: u59323933 $
-------------------------------------------------------------------------------
-- Major Revisions:
-- Date        Version   Author    Description
-- 2014-06-05  1.0       michmueh  Created
-- 2014-06-10  1.1       michmueh  Removed controlling FSM an replaced the
--                                 roundkey enables with a simple shift
--                                 register.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.aes128Pkg.all;

-------------------------------------------------------------------------------
--! @brief AES-128 key expansion
--!
--! The present design implements the key expansion for the 128-bit version of
--! the Advanced Encryption Standard (AES). Since the design targets a
--! high-throughput implementation, the key expansion is implemented using
--! pipeline register between each roundkey calculation.
-------------------------------------------------------------------------------
entity keyExpansion is
  
  port (

    --! @brief System clock.
    Clk_CI : in std_logic;

    --! @brief Asynchronous, active-high reset.
    Reset_RBI : in std_logic;

    --! @brief Determines whether a new cipherkey has been applied or not.
    --! <TABLE BORDER="0">
    --! <TR><TD>0</TD><TD>...</TD><TD>No new cipherkey has been applied.</TD></TR>
    --! <TR><TD>1</TD><TD>...</TD><TD>New cipherkey has been applied.</TD></TR>
    --! </TABLE>
    Start_SI : in std_logic;

    --! @brief The cipher key (master key) for the encryption/decryption.
    Cipherkey_DI : in std_logic_vector(127 downto 0);

    --! @brief The generated round keys.
    Roundkeys_DO : out roundkeyArrayType);

end entity keyExpansion;


-------------------------------------------------------------------------------
--! @brief Behavioral architecture description of AES-128 key expansion.
-------------------------------------------------------------------------------
architecture Behavioral of keyExpansion is

  -----------------------------------------------------------------------------
  -- Type definitions
  -----------------------------------------------------------------------------
  type byteArrayType is array (0 to 9) of std_logic_vector(7 downto 0);
  type subWordArrayType is array (0 to 9) of Word;
  type expkeyArrayType is array (0 to 43) of Word;
  type rconArrayType is array (0 to 9) of Word;


  -----------------------------------------------------------------------------
  -- Constants
  -----------------------------------------------------------------------------
  constant RCON : byteArrayType := (
    x"01", x"02", x"04", x"08", x"10", x"20", x"40", x"80", x"1B", x"36");


  -----------------------------------------------------------------------------
  -- Function declarations
  -----------------------------------------------------------------------------
  -- purpose: Provides an exclusive-or (XOR) operation for words.
  function "xor" (
    left  : Word;
    right : Word) return Word is
    variable Result : Word;
  begin
    Result(0) := left(0) xor right(0);
    Result(1) := left(1) xor right(1);
    Result(2) := left(2) xor right(2);
    Result(3) := left(3) xor right(3);
    return Result;
  end "xor";

  -- purpose: Converts a word to a std_logic_vector. The 0-th byte of the word
  --          becomes the most significant byte of the std_logic_vector.
  function conv_std_logic_vector (
    input : Word)
    return std_logic_vector is
  begin  -- function conv_std_logic_vector
    return input(0) & input(1) & input(2) & input(3);
  end function conv_std_logic_vector;

  -- purpose: Converts four words (i.e., a matrix) to a std_logic_vector.
  function conv_std_logic_vector (
    column0 : Word;
    column1 : Word;
    column2 : Word;
    column3 : Word)
    return std_logic_vector is
  begin  -- function conv_std_logic_vector
    return
      column0(0) & column0(1) & column0(2) & column0(3) &
      column1(0) & column1(1) & column1(2) & column1(3) &
      column2(0) & column2(1) & column2(2) & column2(3) &
      column3(0) & column3(1) & column3(2) & column3(3);
  end function conv_std_logic_vector;


  -----------------------------------------------------------------------------
  -- Component declarations
  -----------------------------------------------------------------------------
  component subWord is
    port (
      In_DI  : in  Word;
      Out_DO : out Word);
  end component subWord;


  -----------------------------------------------------------------------------
  -- Signals
  -----------------------------------------------------------------------------

  -- ExpKey_D: Array of 32-bit words (each made up of four bytes) holding the
  -- expanded key.
  signal ExpKey_DN, ExpKey_DP : expkeyArrayType;

  -- SubWordIn_D: Array holding the ten inputs, each of them one 32-word wide,
  -- connected to the input of the AES S-box.
  signal SubWordIn_D : subWordArrayType;

  -- SubWordOut_D: Array holding the ten outputs, each of them one 32-word wide,
  -- connected to the output of the AES S-box.
  signal SubWordOut_D : subWordArrayType;

  -- Rcon_D: Array holding the ten signals after the XOR operation with the
  -- round constants.
  signal Rcon_D : rconArrayType;

  -- Roundkeys_D: Array holding all the roundkeys produced by the key epansion.
  signal Roundkeys_D : roundkeyArrayType;

  -- Shift register holding the enables for the roundkey registers.
  signal EnRndKeys_SN, EnRndKeys_SP :  std_logic_vector(0 to 9);

  -- Indicates that all roundkey registers currently hold their correct value
  -- and must not be enabled (e.g., no new cipherkey is provided to the design
  -- and the corresponding roundkeys have already been derived).
  signal AllRndKeysDisabled_S : std_logic;
  
  
begin  -- architecture rtl

  -----------------------------------------------------------------------------
  -- Component instantiations
  -----------------------------------------------------------------------------

  -- Generate the ten SubWord instances.
  gen_subWords : for i in 0 to 9 generate
    subWords : subWord
      port map (
        In_DI  => SubWordIn_D(i),
        Out_DO => SubWordOut_D(i));
  end generate gen_subWords;


  -----------------------------------------------------------------------------
  -- Output assignments
  -----------------------------------------------------------------------------
  -- Connect the columns of the expanded key to the round key outputs.
  gen_outputKeys : for i in 0 to 10 generate
    Roundkeys_DO(i) <= conv_std_logic_vector(
      ExpKey_DP(4*i), ExpKey_DP(4*i+1), ExpKey_DP(4*i+2), ExpKey_DP(4*i+3));
  end generate gen_outputKeys;


  -----------------------------------------------------------------------------
  -- Connect the cipherkey to the first four columns (i.e., words) of the
  -- expanded key.
  -----------------------------------------------------------------------------
  -- Use the first roundkey (i.e., the actual cipherkey) as the first four
  -- 32-bit words of the expanded key.
  ExpKey_DN(0) <= conv_word(Cipherkey_DI(127 downto 96)) when Start_SI = '1' else ExpKey_DP(0);
  ExpKey_DN(1) <= conv_word(Cipherkey_DI(95 downto 64))  when Start_SI = '1' else ExpKey_DP(1);
  ExpKey_DN(2) <= conv_word(Cipherkey_DI(63 downto 32))  when Start_SI = '1' else ExpKey_DP(2);
  ExpKey_DN(3) <= conv_word(Cipherkey_DI(31 downto 0))   when Start_SI = '1' else ExpKey_DP(3);


  -----------------------------------------------------------------------------
  -- Calculation of further round key words.
  -----------------------------------------------------------------------------
  -- Since the "RotWord" function only performs a byte-wise rotation of a word,
  -- we can perform it either before or after the "SubWord" substitution.
  gen_roundKeys : for i in 0 to 9 generate
    SubWordIn_D(i) <= ExpKey_DP(4*i+3);

    Rcon_D(i)(0) <= SubWordOut_D(i)(1) xor RCON(i);
    Rcon_D(i)(1) <= SubWordOut_D(i)(2);
    Rcon_D(i)(2) <= SubWordOut_D(i)(3);
    Rcon_D(i)(3) <= SubWordOut_D(i)(0);

    -- Calculate the next expanded key only when the respective enable signal
    -- is set.
    ExpKey_DN(4*(i+1)+0) <= Rcon_D(i) xor ExpKey_DP(4*i)                                                                when EnRndKeys_SP(i) = '1' else ExpKey_DP(4*(i+1)+0);
    ExpKey_DN(4*(i+1)+1) <= Rcon_D(i) xor ExpKey_DP(4*i) xor ExpKey_DP(4*i+1)                                           when EnRndKeys_SP(i) = '1' else ExpKey_DP(4*(i+1)+1);
    ExpKey_DN(4*(i+1)+2) <= Rcon_D(i) xor ExpKey_DP(4*i) xor ExpKey_DP(4*i+1) xor ExpKey_DP(4*i+2)                      when EnRndKeys_SP(i) = '1' else ExpKey_DP(4*(i+1)+2);
    ExpKey_DN(4*(i+1)+3) <= Rcon_D(i) xor ExpKey_DP(4*i) xor ExpKey_DP(4*i+1) xor ExpKey_DP(4*i+2) xor ExpKey_DP(4*i+3) when EnRndKeys_SP(i) = '1' else ExpKey_DP(4*(i+1)+3);
  end generate gen_roundKeys;


  -----------------------------------------------------------------------------
  -- Compute the next state logic for the shift register holding the enables for
  -- the roundkeys.
  -----------------------------------------------------------------------------
  -- The enables for the roundkeys are generated by a one-hot encoded shift
  -- register, which gets the start signal as an input.
  EnRndKeys_SN <=
    -- Start signal is set, so shift in a '1'.
    '1' & EnRndKeys_SP(0 to 8) when Start_SI = '1' else
    -- Since none of the roundkeys currently holds a substantial value, we do
    -- not even have to shift in the zeros, but just hold the current state
    -- (this might be the case when, the encryption pipeline has been emptied
    -- and no encryption is going on anymore, i.e., no other plaintext blocks
    -- have been provided).
    EnRndKeys_SP when AllRndKeysDisabled_S = '1' else
    -- Otherwise shift the enables such that they are proceeded correctly
    -- together with their current pipeline stage (this enables-holding shift
    -- register serves as kind of a shimming register).
    '0' & EnRndKeys_SP(0 to 8);


  -----------------------------------------------------------------------------
  -- Compute the signal indicating that none of the roundkey registers has to
  -- be updated, i.e., no new cipherkey has to be propagated through the key
  -- expansion pipeline registers.
  -----------------------------------------------------------------------------
  pComb_CalcAllRndKeysDisabled : process (EnRndKeys_SP) is
    variable tmp : std_logic;
  begin  -- process pComb_CalcAllRndKeysDisabled
    tmp := EnRndKeys_SP(0);
    for i in 1 to 9 loop
      tmp := tmp or EnRndKeys_SP(i);
    end loop;  -- i
    AllRndKeysDisabled_S <= not tmp;
  end process pComb_CalcAllRndKeysDisabled;


  -----------------------------------------------------------------------------
  -- Flip Flops
  -----------------------------------------------------------------------------
  pSequ_FlipFlops : process (Clk_CI, Reset_RBI) is
  begin  -- process p_FlipFlops
    if Reset_RBI = '0' then             -- asynchronous reset (active low)
      ExpKey_DP    <= (others => ZERO_WORD);
      EnRndKeys_SP <= (others => '0');
    elsif Clk_CI'event and Clk_CI = '1' then  -- rising clock edge
      ExpKey_DP    <= ExpKey_DN;
      EnRndKeys_SP <= EnRndKeys_SN;
    end if;
  end process pSequ_FlipFlops;
end architecture Behavioral;
