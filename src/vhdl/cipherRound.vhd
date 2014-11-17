-------------------------------------------------------------------------------
--! @file       cipherRound.vhd
--! @brief      AES-128 single cipher round
--! @project    VLSI Book - AES-128 Example
--! @author     Michael Muehlberghuber (mbgh@iis.ee.ethz.ch)
--! @company    Integrated Systems Laboratory, ETH Zurich
--! @copyright  Copyright (C) 2014 Integrated Systems Laboratory, ETH Zurich
--! @date       2014-06-05
--! @updated    2014-06-05
--! @platform   Simulation: ModelSim; Synthesis: Synopsys, Xilinx XST/Vivado
--! @standard   VHDL'93/02
-------------------------------------------------------------------------------
-- Revision Control System Information:
-- File ID      :  $Id: cipherRound.vhd 6 2014-06-12 12:49:55Z u59323933 $
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
--! @brief AES-128 single cipher round
--!
--! Implements a single cipher round of the AES-128 encryption algorithm, which
--! can then be instantiated multiple times in order to create a high-throughput
--! architecture.
-------------------------------------------------------------------------------
entity cipherRound is
  
  port (
    --! @brief The internal state of AES being applied to this round.
    StateIn_DI  : in  Matrix;
    --! @brief The roundkey to be used for the current AES round.
    Roundkey_DI : in  std_logic_vector(127 downto 0);
    --! @brief The resulting state of AES after applying this round.
    StateOut_DO : out Matrix);

end entity cipherRound;

-------------------------------------------------------------------------------
--! @brief Behavioral architecture description of a single AES round.
-------------------------------------------------------------------------------
architecture Behavioral of cipherRound is

  -----------------------------------------------------------------------------
  -- Component declarations
  -----------------------------------------------------------------------------
  component subMatrix is
    port (
      In_DI  : in  Matrix;
      Out_DO : out Matrix);
  end component subMatrix;

  component mixMatrix is
    port (
      In_DI  : in  Matrix;
      Out_DO : out Matrix);
  end component mixMatrix;

  -----------------------------------------------------------------------------
  -- Signals
  -----------------------------------------------------------------------------
  signal SubMatrixOut_D : Matrix;       -- State after "SubMatrix".
  signal ShiftRowsOut_D : Matrix;       -- State after "ShiftRows".
  signal MixMatrixOut_D : Matrix;       -- State after "MixColumns".

  
begin  -- architecture Behavioral

  -----------------------------------------------------------------------------
  -- Component instantiations
  -----------------------------------------------------------------------------
  subMatrix_1 : subMatrix
    port map (
      In_DI  => StateIn_DI,
      Out_DO => SubMatrixOut_D);

  mixMatrix_1 : entity work.mixMatrix
    port map (
      In_DI  => ShiftRowsOut_D,
      Out_DO => MixMatrixOut_D);

  ShiftRowsOut_D <= shift_rows(SubMatrixOut_D);
  StateOut_DO    <= MixMatrixOut_D xor Roundkey_DI;

end architecture Behavioral;
