-------------------------------------------------------------------------------
--! @file       mixColumn.vhd
--! @brief      AES MixColumn operation (single column)
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
-- File ID      :  $Id: mixColumn.vhd 6 2014-06-12 12:49:55Z u59323933 $
-- Revision     :  $Revision: 6 $
-- Local Date   :  $Date: 2014-06-12 14:49:55 +0200 (Thu, 12 Jun 2014) $
-- Modified By  :  $Author: u59323933 $
-------------------------------------------------------------------------------
-- Major Revisions:
-- Date        Version   Author    Description
-- 2014-06-05  1.0       michmueh  Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library work;
use work.aes128Pkg.all;

-------------------------------------------------------------------------------
--! @brief AES MixColumn operation (single column)
--!
--! The present design implements the MixColumn operation of the Advanced
--! Encryption Standard (AES).
-------------------------------------------------------------------------------
entity mixColumn is
  
  port (
    --! @brief Input to the "MixColumn" function.
    In_DI  : in  Word;
    --! @brief Output of the "MixColumn" function.
    Out_DO : out Word);

end entity mixColumn;


-------------------------------------------------------------------------------
--! @brief Behavioral architecture of the "MixColumn" function.
-------------------------------------------------------------------------------
architecture Behavioral of mixColumn is

  -----------------------------------------------------------------------------
  -- Signals
  -----------------------------------------------------------------------------
  signal Byte0_D, Byte0Doubled_D, Byte0Tripled_D : Byte;
  signal Byte1_D, Byte1Doubled_D, Byte1Tripled_D : Byte;
  signal Byte2_D, Byte2Doubled_D, Byte2Tripled_D : Byte;
  signal Byte3_D, Byte3Doubled_D, Byte3Tripled_D : Byte;
  
begin  -- architecture Behavioral

  -----------------------------------------------------------------------------
  -- First Byte
  -----------------------------------------------------------------------------
  Byte0_D        <= In_DI(0);
  Byte0Doubled_D <= ((In_DI(0)(6 downto 0) & '0') xor x"1B") when In_DI(0)(7) = '1'
                    else (In_DI(0)(6 downto 0) & '0');
  Byte0Tripled_D <= Byte0Doubled_D xor Byte0_D;

  -----------------------------------------------------------------------------
  -- Second Byte
  -----------------------------------------------------------------------------
  Byte1_D        <= In_DI(1);
  Byte1Doubled_D <= ((In_DI(1)(6 downto 0) & '0') xor x"1B") when In_DI(1)(7) = '1'
                    else (In_DI(1)(6 downto 0) & '0');
  Byte1Tripled_D <= Byte1Doubled_D xor Byte1_D;

  -----------------------------------------------------------------------------
  -- Third Byte
  -----------------------------------------------------------------------------
  Byte2_D        <= In_DI(2);
  Byte2Doubled_D <= ((In_DI(2)(6 downto 0) & '0') xor x"1B") when In_DI(2)(7) = '1'
                    else (In_DI(2)(6 downto 0) & '0');
  Byte2Tripled_D <= Byte2Doubled_D xor Byte2_D;

  -----------------------------------------------------------------------------
  -- Fourth Byte
  -----------------------------------------------------------------------------
  Byte3_D        <= In_DI(3);
  Byte3Doubled_D <= ((In_DI(3)(6 downto 0) & '0') xor x"1B") when In_DI(3)(7) = '1'
                    else (In_DI(3)(6 downto 0) & '0');
  Byte3Tripled_D <= Byte3Doubled_D xor Byte3_D;

  -----------------------------------------------------------------------------
  -- Output Assignment
  -----------------------------------------------------------------------------
  Out_DO(0) <= Byte0Doubled_D xor Byte1Tripled_D xor Byte2_D xor Byte3_D;
  Out_DO(1) <= Byte0_D xor Byte1Doubled_D xor Byte2Tripled_D xor Byte3_D;
  Out_DO(2) <= Byte0_D xor Byte1_D xor Byte2Doubled_D xor Byte3Tripled_D;
  Out_DO(3) <= Byte0Tripled_D xor Byte1_D xor Byte2_D xor Byte3Doubled_D;

end architecture Behavioral;
