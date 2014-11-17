-------------------------------------------------------------------------------
--! @file       mixMatrix.vhd
--! @brief      AES state MixColumn
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
-- File ID      :  $Id: mixMatrix.vhd 6 2014-06-12 12:49:55Z u59323933 $
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
--! @brief AES state MixColumn
--!
--! The present design applies the "MixColumns" operation of the Advanced
--! Encryption Standard (AES) to all four columns of the AES State.
-------------------------------------------------------------------------------
entity mixMatrix is
  
  port (
    --! @brief Input to the "MixMatrix" function.
    In_DI  : in  Matrix;
    --! @brief Output of the "MixMatrix" function.
    Out_DO : out Matrix);

end entity mixMatrix;


-------------------------------------------------------------------------------
--! @brief Structural architecture of the "MixMatrix" function.
-------------------------------------------------------------------------------
architecture Structural of mixMatrix is

  -----------------------------------------------------------------------------
  -- Component declarations
  -----------------------------------------------------------------------------
  component mixColumn is
    port (
      In_DI  : in  Word;
      Out_DO : out Word);
  end component mixColumn;
  
begin  -- architecture Structural

  -----------------------------------------------------------------------------
  -- Component instantiations
  -----------------------------------------------------------------------------
  gen_mixColumns : for i in 0 to 3 generate
    mixColumn : entity work.mixColumn
      port map (
        In_DI  => In_DI(i),
        Out_DO => Out_DO(i));
  end generate gen_mixColumns;

end architecture Structural;
