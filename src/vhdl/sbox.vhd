-------------------------------------------------------------------------------
--! @file       sbox.vhd
--! @brief      AES S-box
--! @project    VLSI Book - AES-128 Example
--! @author     Michael Muehlberghuber (mbgh@iis.ee.ethz.ch)
--! @company    Integrated Systems Laboratory, ETH Zurich
--! @copyright  Copyright (C) 2014 Integrated Systems Laboratory, ETH Zurich
--! @date       2014-06-05
--! @updated    2014-09-02
--! @platform   Simulation: ModelSim; Synthesis: Synopsys
--! @standard   VHDL'93/02
-------------------------------------------------------------------------------
-- Revision Control System Information:
-- File ID      :  $Id: sbox.vhd 10 2014-09-29 12:51:46Z u59323933 $
-- Revision     :  $Revision: 10 $
-- Local Date   :  $Date: 2014-09-29 14:51:46 +0200 (Mon, 29 Sep 2014) $
-- Modified By  :  $Author: u59323933 $
-------------------------------------------------------------------------------
-- Major Revisions:
-- Date        Version   Author    Description
-- 2014-06-05  1.0       michmueh  Created
-------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library work;
use work.aes128Pkg.all;

-------------------------------------------------------------------------------
--! @brief AES S-box
--!
--! The present design implements the S-box of the Advanced Encryption Standard
--! (AES). Since the overall AES structure is based on a byte-oriented design,
--! also the S-box hast been implemented such that a single byte can be
--! substituted. This S-box was realized using a "straight-forward" approach
--! using a LUT based on an array of constants. Thereby shifting all the
--! "effort" of the actual architecture over to the synthesizer.
-------------------------------------------------------------------------------
entity sbox is
  
  port (
    --! @brief Input to the S-box.
    In_DI  : in  Byte;
    --! @brief Substituted output of the S-box.
    Out_DO : out Byte);

end entity sbox;


-------------------------------------------------------------------------------
--! @brief AES S-box implementation based on a look-up table.
--!
--! AES S-box implementaion based on a look-up table (LUT), which has been
--! implemented "straight forward" by using an array of constants and thereby
--! shifting "all the work" of the actual S-box architecture over to the
--! synthesizer being used.
-------------------------------------------------------------------------------
architecture Lut of sbox is

  -----------------------------------------------------------------------------
  -- Type definitions
  -----------------------------------------------------------------------------
  subtype ByteInt is integer range 0 to 255;
  type ByteArray is array (0 to 255) of ByteInt;

  -----------------------------------------------------------------------------
  -- Constants
  -----------------------------------------------------------------------------
  constant SBOX : ByteArray := (
    99, 124, 119, 123, 242, 107, 111, 197, 48, 1, 103, 43, 254, 215, 171, 118,
    202, 130, 201, 125, 250, 89, 71, 240, 173, 212, 162, 175, 156, 164, 114, 192,
    183, 253, 147, 38, 54, 63, 247, 204, 52, 165, 229, 241, 113, 216, 49, 21,
    4, 199, 35, 195, 24, 150, 5, 154, 7, 18, 128, 226, 235, 39, 178, 117,
    9, 131, 44, 26, 27, 110, 90, 160, 82, 59, 214, 179, 41, 227, 47, 132,
    83, 209, 0, 237, 32, 252, 177, 91, 106, 203, 190, 57, 74, 76, 88, 207,
    208, 239, 170, 251, 67, 77, 51, 133, 69, 249, 2, 127, 80, 60, 159, 168,
    81, 163, 64, 143, 146, 157, 56, 245, 188, 182, 218, 33, 16, 255, 243, 210,
    205, 12, 19, 236, 95, 151, 68, 23, 196, 167, 126, 61, 100, 93, 25, 115,
    96, 129, 79, 220, 34, 42, 144, 136, 70, 238, 184, 20, 222, 94, 11, 219,
    224, 50, 58, 10, 73, 6, 36, 92, 194, 211, 172, 98, 145, 149, 228, 121,
    231, 200, 55, 109, 141, 213, 78, 169, 108, 86, 244, 234, 101, 122, 174, 8,
    186, 120, 37, 46, 28, 166, 180, 198, 232, 221, 116, 31, 75, 189, 139, 138,
    112, 62, 181, 102, 72, 3, 246, 14, 97, 53, 87, 185, 134, 193, 29, 158,
    225, 248, 152, 17, 105, 217, 142, 148, 155, 30, 135, 233, 206, 85, 40, 223,
    140, 161, 137, 13, 191, 230, 66, 104, 65, 153, 45, 15, 176, 84, 187, 22);

begin  -- architecture Lut

  -----------------------------------------------------------------------------
  -- Output assignments
  -----------------------------------------------------------------------------
  Out_DO <= std_logic_vector(to_unsigned(
    SBOX(to_integer(unsigned(In_DI))), 8));

end architecture Lut;
