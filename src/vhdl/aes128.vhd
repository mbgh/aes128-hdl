-------------------------------------------------------------------------------
--! @file       aes128.vhd
--! @brief      High-throughput implementation of AES-128
--! @project    VLSI Book - AES-128 Example
--! @author     Michael Muehlberghuber (mbgh@iis.ee.ethz.ch)
--! @company    Integrated Systems Laboratory, ETH Zurich
--! @copyright  Copyright (C) 2014 Integrated Systems Laboratory, ETH Zurich
--! @date       2014-06-05
--! @updated    2014-10-15
--! @platform   Simulation: ModelSim; Synthesis: Synopsys
--! @standard   VHDL'93/02
-------------------------------------------------------------------------------
-- Revision Control System Information:
-- File ID      :  $Id: aes128.vhd 21 2014-10-17 16:06:52Z u59323933 $
-- Revision     :  $Revision: 21 $
-- Local Date   :  $Date: 2014-10-17 18:06:52 +0200 (Fri, 17 Oct 2014) $
-- Modified By  :  $Author: u59323933 $
-------------------------------------------------------------------------------
-- Major Revisions:
-- Date        Version   Author    Description
-- 2014-06-05  1.0       michmueh  Created
-- 2014-06-10  1.1       michmueh  Removed controlling FSM and replaced the
--                                 cipher state register enables computation
--                                 with a simple shift register.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.aes128Pkg.all;

-------------------------------------------------------------------------------
--! @brief High-throughput implementation of AES-128
--!
--! The present design implements the cipher of the 128-bit version of the
--! Advanced Encryption Standard (AES). Since the design targets a
--! high-throughput implementation, both the key expansion and the actual cipher
--! are pipeline.
--!
--! Inputs and outputs are registered. - While the plaintext and the ciphertext
--! are registered in the top entity, the cipherkey is registered within the key
--! expansion entity. Due to the input buffering, the actual encryption starts
--! with a delay of one clock cycle. After that, both the key expansion and the
--! encryption are executed "in parallel".
-------------------------------------------------------------------------------
entity aes128 is
  
  port (
    --! @brief System clock.
    Clk_CI : in std_logic;

    --! @brief Synchronous, active-high reset.
    Reset_RBI : in std_logic;

    --! @brief Starts the actual encryption process.
    --! <TABLE BORDER="0">
    --! <TR><TD>0</TD><TD>...</TD><TD>Do not start the encryption.</TD></TR>
    --! <TR><TD>1</TD><TD>...</TD><TD>Start the encryption (value has to be applied only for a single clock cycle).</TD></TR>
    --! </TABLE>
    Start_SI : in std_logic;

    --! @brief Determines whether a new cipherkey has been applied or not
    --! (i.e., whether the key expansion has to be performed or not).
    --! <TABLE BORDER="0">
    --! <TR><TD>0</TD><TD>...</TD><TD>No new cipherkey has been applied.</TD></TR>
    --! <TR><TD>1</TD><TD>...</TD><TD>A new cipherkey has been applied.</TD></TR>
    --! </TABLE>
    NewCipherkey_SI : in std_logic;

    --! @brief Determines whether a the module is currently processing or not.
    --! <TABLE BORDER="0">
    --! <TR><TD>0</TD><TD>...</TD><TD>Module is in IDLE mode.</TD></TR>
    --! <TR><TD>1</TD><TD>...</TD><TD>Module is currently encrypting.</TD></TR>
    --! </TABLE>
    Busy_SO : out std_logic;

    --! @brief The plaintext block to be encrypted.
    Plaintext_DI  : in  std_logic_vector(127 downto 0);
    --! @brief the cipherkey to be used for encryption.
    Cipherkey_DI  : in  std_logic_vector(127 downto 0);
    --! @brief The resulting ciphertext.
    Ciphertext_DO : out std_logic_vector(127 downto 0));

end entity aes128;

-------------------------------------------------------------------------------
--! @brief Behavioral architecture of AES-128.
-------------------------------------------------------------------------------
architecture Behavioral of aes128 is

  -----------------------------------------------------------------------------
  -- Types
  -----------------------------------------------------------------------------
  type stateArrayType is array (0 to 9) of Matrix;


  -----------------------------------------------------------------------------
  -- Component declarations
  -----------------------------------------------------------------------------
  component keyExpansion is
    port (
      Clk_CI       : in  std_logic;
      Reset_RBI    : in  std_logic;
      Start_SI     : in  std_logic;
      Cipherkey_DI : in  std_logic_vector(127 downto 0);
      Roundkeys_DO : out roundkeyArrayType);
  end component keyExpansion;

  component cipherRound is
    port (
      StateIn_DI  : in  Matrix;
      Roundkey_DI : in  std_logic_vector(127 downto 0);
      StateOut_DO : out Matrix);
  end component cipherRound;

  component subMatrix is
    port (
      In_DI  : in  Matrix;
      Out_DO : out Matrix);
  end component subMatrix;


  -----------------------------------------------------------------------------
  -- Functions
  -----------------------------------------------------------------------------
  -- purpose: Converts a std_logic_vector into a matrix. 
  function conv_matrix (
    input : std_logic_vector(127 downto 0))
    return Matrix is
    variable result : Matrix;
  begin  -- function conv_matrix
    result(0) := conv_word(input(127 downto 96));
    result(1) := conv_word(input(95 downto 64));
    result(2) := conv_word(input(63 downto 32));
    result(3) := conv_word(input(31 downto 0));
    return result;
  end function conv_matrix;

  -- purpose: Converts a matrix to a std_logic_vector. The 0-th byte of the
  --          first word of the matrix becomes the most significant byte of
  --          the std_logic_vector.
  function conv_std_logic_vector (
    input : Matrix)
    return std_logic_vector is
  begin  -- function conv_std_logic_vector
    return
      input(0)(0) & input(0)(1) & input(0)(2) & input(0)(3) &
      input(1)(0) & input(1)(1) & input(1)(2) & input(1)(3) &
      input(2)(0) & input(2)(1) & input(2)(2) & input(2)(3) &
      input(3)(0) & input(3)(1) & input(3)(2) & input(3)(3);
  end function conv_std_logic_vector;


  -----------------------------------------------------------------------------
  -- Signals
  -----------------------------------------------------------------------------

  -- Registers.
  signal Plaintext_DN, Plaintext_DP         : std_logic_vector(127 downto 0);
  signal CipherState_DN, CipherState_DP     : stateArrayType;
  signal Ciphertext_DN, Ciphertext_DP       : Matrix;
  signal EnCipherState_SN, EnCipherState_SP : unsigned(0 to 10);

  -- Some intermediate signals.
  signal Roundkeys_D               : roundkeyArrayType;
  signal LastSubMatrixOut_D        : Matrix;
  signal KeyExpStart_S             : std_logic;
  signal AllCipherStatesDisabled_S : std_logic;

  
begin  -- architecture Behavioral

  -----------------------------------------------------------------------------
  -- Component instantiations
  -----------------------------------------------------------------------------
  keyExpansion_1 : keyExpansion
    port map (
      Clk_CI       => Clk_CI,
      Reset_RBI    => Reset_RBI,
      Start_SI     => KeyExpStart_S,
      Cipherkey_DI => Cipherkey_DI,
      Roundkeys_DO => Roundkeys_D);

  -- S-boxes of the last round.
  lastSubMatrix : subMatrix
    port map (
      In_DI  => CipherState_DP(9),
      Out_DO => LastSubMatrixOut_D);

  -- Perform full rounds (i.e., rounds one to nine).
  gen_cipherRounds : for i in 1 to 9 generate
    cipherRounds : cipherRound
      port map (
        StateIn_DI  => CipherState_DP(i-1),
        Roundkey_DI => Roundkeys_D(i),
        StateOut_DO => CipherState_DN(i));
  end generate gen_cipherRounds;

  -----------------------------------------------------------------------------
  -- Next state logic
  -----------------------------------------------------------------------------
  -- Enable plaintext register only when start signal is set.
  Plaintext_DN <= Plaintext_DI when Start_SI = '1' else Plaintext_DP;

  -- The enables for the cipher states are generated by a one-hot encoded shift
  -- register, which gets the start signal as an input.
  EnCipherState_SN <=
    -- Start signal is set so shift in a '1'.
    '1' & EnCipherState_SP(0 to 9) when Start_SI = '1' else
    -- Since none of the cipher states currently holds a substantial value, we
    -- do not even have to shift in the zeros, but just hold the current state.
    EnCipherState_SP                    when AllCipherStatesDisabled_S = '1' else
    -- Otherwise shift the enables such that they are proceeded correctly with
    -- their current pipeline stage (this enables-holding shift register serves
    -- as kind of a shimming register).
    '0' & EnCipherState_SP(0 to 9);

  -- Perform last round (i.e., round without the "MixColumn" step) and
  -- calculate the final state, which is equal to the ciphertext.
  Ciphertext_DN <=
    shift_rows(LastSubMatrixOut_D) xor Roundkeys_D(10) when EnCipherState_SP(10) = '1' else
    Ciphertext_DP;

  -- Perform inital "AddRoundKey".
  CipherState_DN(0) <= conv_matrix(Roundkeys_D(0) xor Plaintext_DP);

  
  -----------------------------------------------------------------------------
  -- Compute the signal indicating that none of the cipher state register has
  -- to be enabled, i.e., no new plaintext data is provided at the input.
  -----------------------------------------------------------------------------
  pComb_CalcAllCipherStatesDisabled : process (EnCipherState_SP) is
    variable tmp : std_logic;
  begin  -- process pComb_CalcAllCipherStatesDisabled
    tmp := EnCipherState_SP(0);
    for i in 1 to 10 loop
      tmp := tmp or EnCipherState_SP(i);
    end loop;  -- i
    AllCipherStatesDisabled_S <= not tmp;
  end process pComb_CalcAllCipherStatesDisabled;


  -----------------------------------------------------------------------------
  -- The key expansion should only be initiated when both the start signal and
  -- the signal indicating a new cipherkey are set.
  -----------------------------------------------------------------------------
  KeyExpStart_S <= Start_SI and NewCipherkey_SI;
  

  -----------------------------------------------------------------------------
  -- Output assignment
  -----------------------------------------------------------------------------
  Ciphertext_DO <= conv_std_logic_vector(Ciphertext_DP);
  Busy_SO       <= not AllCipherStatesDisabled_S;

  -----------------------------------------------------------------------------
  -- Memories
  -----------------------------------------------------------------------------
  pSequ_FlipFlops : process (Clk_CI, Reset_RBI) is
  begin  -- process pSequ_FlipFlops
    if Reset_RBI = '0' then             -- asynchronous reset (active low)
      Plaintext_DP     <= (others => '0');
      EnCipherState_SP <= (others => '0');
      CipherState_DP   <= (others => ZERO_MATRIX);
      Ciphertext_DP    <= (others => ZERO_WORD);
    elsif Clk_CI'event and Clk_CI = '1' then  -- rising clock edge
      -- Next state computation for plaintext register is done outside this
      -- process.
      Plaintext_DP <= Plaintext_DN;

      -- Shift register holding the enables for the cipher states.
      EnCipherState_SP <= EnCipherState_SN;

      -- Matrix-wise enables for cipher states.
      if EnCipherState_SP(0) = '1' then CipherState_DP(0) <= CipherState_DN(0); end if;
      if EnCipherState_SP(1) = '1' then CipherState_DP(1) <= CipherState_DN(1); end if;
      if EnCipherState_SP(2) = '1' then CipherState_DP(2) <= CipherState_DN(2); end if;
      if EnCipherState_SP(3) = '1' then CipherState_DP(3) <= CipherState_DN(3); end if;
      if EnCipherState_SP(4) = '1' then CipherState_DP(4) <= CipherState_DN(4); end if;
      if EnCipherState_SP(5) = '1' then CipherState_DP(5) <= CipherState_DN(5); end if;
      if EnCipherState_SP(6) = '1' then CipherState_DP(6) <= CipherState_DN(6); end if;
      if EnCipherState_SP(7) = '1' then CipherState_DP(7) <= CipherState_DN(7); end if;
      if EnCipherState_SP(8) = '1' then CipherState_DP(8) <= CipherState_DN(8); end if;
      if EnCipherState_SP(9) = '1' then CipherState_DP(9) <= CipherState_DN(9); end if;

      -- Enable of ciphertext register.
      if EnCipherState_SP(10) = '1' then Ciphertext_DP <= Ciphertext_DN; end if;
      
    end if;
  end process pSequ_FlipFlops;
end architecture Behavioral;
