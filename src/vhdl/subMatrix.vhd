-------------------------------------------------------------------------------
--! @file       subMatrix.vhd
--! @brief      AES substitute matrix function
--! @project    VLSI Book - AES-128 Example
--! @author     Michael Muehlberghuber (mbgh@iis.ee.ethz.ch)
--! @company    Integrated Systems Laboratory, ETH Zurich
--! @copyright  Copyright (C) 2014 Integrated Systems Laboratory, ETH Zurich
--! @date       2014-06-05
--! @updated    2014-10-17
--! @platform   Simulation: ModelSim; Synthesis: Synopsys
--! @standard   VHDL'93/02
-------------------------------------------------------------------------------
-- Revision Control System Information:
-- File ID      :  $Id: subMatrix.vhd 21 2014-10-17 16:06:52Z u59323933 $
-- Revision     :  $Revision: 21 $
-- Local Date   :  $Date: 2014-10-17 18:06:52 +0200 (Fri, 17 Oct 2014) $
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
--! @brief AES substitute matrix function
--!
--! Takes a matrix (i.e., 16 bytes) and substitutes the matrix using the
--! substitution box (S-box) of the Advanced Encryption Standard (AES). This is
--! done by instantiating four "SubWord" entities, each operating on a single
--! word.
-------------------------------------------------------------------------------
entity subMatrix is
  
  port (
    --! @brief Input to the "SubMatrix" function.
    In_DI  : in  Matrix;
    --! @brief Substituted output of the "SubMatrix" function.
    Out_DO : out Matrix);

end entity subMatrix;


-------------------------------------------------------------------------------
--! @brief Structural architecture of the "SubMatrix" function.
-------------------------------------------------------------------------------
architecture Structural of subMatrix is

  -----------------------------------------------------------------------------
  -- Component declarations
  -----------------------------------------------------------------------------
  component subWord is
    port (
      In_DI  : in  Word;
      Out_DO : out Word);
  end component subWord;
  
begin  -- architecture Structural

  -----------------------------------------------------------------------------
  -- Component instantiations
  -----------------------------------------------------------------------------
  gen_subWords: for i in 0 to 3 generate
    subWords : subWord
      port map (
        In_DI  => In_DI(i),
        Out_DO => Out_DO(i));
  end generate gen_subWords;

end architecture Structural;

