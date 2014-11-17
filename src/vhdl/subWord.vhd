-------------------------------------------------------------------------------
--! @file       subWord.vhd
--! @brief      AES substitude word function (SubWord)
--! @project    VLSI Book - AES-128 Example
--! @author     Michael Muehlberghuber (mbgh@iis.ee.ethz.ch)
--! @company    Integrated Systems Laboratory, ETH Zurich
--! @copyright  Copyright (C) 2014 Integrated Systems Laboratory, ETH Zurich
--! @date       2014-06-05
--! @updated    2014-06-05
--! @platform   Simulation: ModelSim; Synthesis: Synopsys
--! @standard   VHDL'93/02
-------------------------------------------------------------------------------
-- Revision Control System Information:
-- File ID      :  $Id: subWord.vhd 6 2014-06-12 12:49:55Z u59323933 $
-- Revision     :  $Revision: 6 $
-- Local Date   :  $Date: 2014-06-12 14:49:55 +0200 (Thu, 12 Jun 2014) $
-- Modified By  :  $Author: u59323933 $
-------------------------------------------------------------------------------
-- Major Revisions:
-- Date        Version   Author    Description
-- 2014-06-05  1.0       michmueh  Created
-------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

library work;
use work.aes128Pkg.all;

-------------------------------------------------------------------------------
--! @brief AES substitude word function (SubWord)
--!
--! Takes a word (i.e., four bytes) and substitudes the word using the
--! substitution box (S-box) of the Advanced Encryption Standard (AES). This is
--! done by instantiating four S-boxes, each operating on a single byte.
-------------------------------------------------------------------------------
entity subWord is
  
  port (
    --! @brief Input to the "SubWord" function.
    In_DI  : in  Word;
    --! @brief Substituted output of the "SubWord" function.
    Out_DO : out Word);

end entity subWord;


-------------------------------------------------------------------------------
--! @brief Structural architecture of the "SubWord" function.
-------------------------------------------------------------------------------
architecture Structural of subWord is

  -----------------------------------------------------------------------------
  -- Component declarations
  -----------------------------------------------------------------------------
  component sbox is
    port (
      In_DI  : in  Byte;
      Out_DO : out Byte);
  end component sbox;
  
begin  -- architecture structural

  -----------------------------------------------------------------------------
  -- Component instantiations
  -----------------------------------------------------------------------------
  sbox_0 : sbox
    port map (
      In_DI  => In_DI(0),
      Out_DO => Out_DO(0));
  sbox_1 : sbox
    port map (
      In_DI  => In_DI(1),
      Out_DO => Out_DO(1));
  sbox_2 : sbox
    port map (
      In_DI  => In_DI(2),
      Out_DO => Out_DO(2));
  sbox_3 : sbox
    port map (
      In_DI  => In_DI(3),
      Out_DO => Out_DO(3));
end architecture Structural;
