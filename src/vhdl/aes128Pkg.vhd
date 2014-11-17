-------------------------------------------------------------------------------
--! @file       aes128Pkg.vhd
--! @brief      AES-128 Package
--! @project    VLSI Book - AES-128 Example
--! @author     Michael Muehlberghuber (mbgh@iis.ee.ethz.ch)
--! @company    Integrated Systems Laboratory, ETH Zurich
--! @copyright  Copyright (C) 2014 Integrated Systems Laboratory, ETH Zurich
--! @date       2014-06-05
--! @updated    2014-10-16
--! @platform   Simulation: ModelSim; Synthesis: Synopsys
--! @standard   VHDL'93/02
-------------------------------------------------------------------------------
-- Revision Control System Information:
-- File ID      :  $Id: aes128Pkg.vhd 21 2014-10-17 16:06:52Z u59323933 $
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

-------------------------------------------------------------------------------
--! @brief AES-128 package
--!
--! A package for the 128-bit version of the Advanced Encryption Standard (AES)
--! design. A couple of types, constants, and functions are defined herein,
--! which are used throughout the whole design.
-------------------------------------------------------------------------------
package aes128Pkg is

  -----------------------------------------------------------------------------
  -- Type definitions
  -----------------------------------------------------------------------------
  subtype Byte is std_logic_vector(7 downto 0);
  type Word is array (0 to 3) of Byte;
  type Matrix is array (0 to 3) of Word;
  type roundkeyArrayType is array (0 to 10) of std_logic_vector(127 downto 0);


  -----------------------------------------------------------------------------
  -- Constants
  -----------------------------------------------------------------------------
  constant ZERO_BYTE   : Byte   := (others => '0');
  constant ZERO_WORD   : Word   := (others => ZERO_BYTE);
  constant ZERO_MATRIX : Matrix := (others => ZERO_WORD);

  
  -----------------------------------------------------------------------------
  -- Function declarations
  -----------------------------------------------------------------------------
  function conv_word (
    input : std_logic_vector(31 downto 0))
    return Word;
  
  function shift_rows(
    input : Matrix)
    return Matrix;

  function "xor" (
    left  : Matrix;
    right : std_logic_vector)
    return Matrix;

end package aes128Pkg;

package body aes128Pkg is

  -----------------------------------------------------------------------------
  -- Function definitions
  -----------------------------------------------------------------------------

  -- purpose: Converts a std_logic_vector into a word. 
  function conv_word (
    input : std_logic_vector(31 downto 0))
    return Word is
    variable result : Word;
  begin  -- function conv_word
    result(0) := input(31 downto 24);
    result(1) := input(23 downto 16);
    result(2) := input(15 downto 8);
    result(3) := input(7 downto 0);
    return result;
  end function conv_word;

  -- purpose: Performs the 'ShiftRows' operation using a "Matrix" as input and
  --          output.
  function shift_rows (
    input : Matrix)
    return Matrix is
    variable result : Matrix;
  begin  -- function shift_rows

    -- First Row
    result(0)(0) := input(0)(0);
    result(1)(0) := input(1)(0);
    result(2)(0) := input(2)(0);
    result(3)(0) := input(3)(0);
    -- Second Row
    result(0)(1) := input(1)(1);
    result(1)(1) := input(2)(1);
    result(2)(1) := input(3)(1);
    result(3)(1) := input(0)(1);
    -- Third Row
    result(0)(2) := input(2)(2);
    result(1)(2) := input(3)(2);
    result(2)(2) := input(0)(2);
    result(3)(2) := input(1)(2);
    -- Fourth Row
    result(0)(3) := input(3)(3);
    result(1)(3) := input(0)(3);
    result(2)(3) := input(1)(3);
    result(3)(3) := input(2)(3);

    return result;
  end function shift_rows;

  -- purpose: Provides an exclusive-or (XOR) operation for a matrix and a
  -- std_logic_vector input.
  function "xor" (
    left  : Matrix;
    right : std_logic_vector)
    return Matrix is
    variable result : Matrix;
  begin
    -- First Column
    result(0)(0) := left(0)(0) xor right(127 downto 120);
    result(0)(1) := left(0)(1) xor right(119 downto 112);
    result(0)(2) := left(0)(2) xor right(111 downto 104);
    result(0)(3) := left(0)(3) xor right(103 downto 96);
    -- Second Column
    result(1)(0) := left(1)(0) xor right(95 downto 88);
    result(1)(1) := left(1)(1) xor right(87 downto 80);
    result(1)(2) := left(1)(2) xor right(79 downto 72);
    result(1)(3) := left(1)(3) xor right(71 downto 64);
    -- Third Column
    result(2)(0) := left(2)(0) xor right(63 downto 56);
    result(2)(1) := left(2)(1) xor right(55 downto 48);
    result(2)(2) := left(2)(2) xor right(47 downto 40);
    result(2)(3) := left(2)(3) xor right(39 downto 32);
    -- Fourth Column
    result(3)(0) := left(3)(0) xor right(31 downto 24);
    result(3)(1) := left(3)(1) xor right(23 downto 16);
    result(3)(2) := left(3)(2) xor right(15 downto 8);
    result(3)(3) := left(3)(3) xor right(7 downto 0);
    return result;
  end "xor";
  
end package body aes128Pkg;
