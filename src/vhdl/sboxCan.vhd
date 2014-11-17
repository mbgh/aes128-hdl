-------------------------------------------------------------------------------
--! @file       sbox.vhd
--! @brief      AES Canright S-box
--! @project    VLSI Book - AES-128 Example
--! @author     Michael Muehlberghuber (mbgh@iis.ee.ethz.ch)
--! @company    Integrated Systems Laboratory, ETH Zurich
--! @copyright  Copyright (C) 2014 Integrated Systems Laboratory, ETH Zurich
--! @date       2014-06-05
--! @updated    2014-10-21
--! @platform   Simulation: ModelSim; Synthesis: Synopsys
--! @standard   VHDL'93/02
-------------------------------------------------------------------------------
-- Revision Control System Information:
-- File ID      :  $Id: sboxCan.vhd 30 2014-10-21 11:17:34Z u59323933 $
-- Revision     :  $Revision: 30 $
-- Local Date   :  $Date: 2014-10-21 13:17:34 +0200 (Tue, 21 Oct 2014) $
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
--! @brief AES S-box implementation based on the approach by D. Canright [1].
--!
--! AES S-box implementation based on the approach by D. Canright, which uses
--! the subfields GF(2^2) and GF(2^4) in order to realize the field inversion
--! in GF(2^8). Thereby the area footprint of the resulting architecture should
--! be significantly smaller than the LUT-based approach using only a constant
--! array and shifting the effort of the actual implementation over to the
--! synthesizer.
--!
--! @reference{[1], D. Canright\, "A Very Compact S-Box for AES"\, CHES'05\,
--!            http://dx.doi.org/10.1007/11545262_32}
-------------------------------------------------------------------------------
entity sbox is
  
  port (
    --! @brief Input to the S-box.
    In_DI  : in  Byte;
    --! @brief Substituted output of the S-box.
    Out_DO : out Byte);

end entity sbox;


-------------------------------------------------------------------------------
--! @brief Behavioral architecture of the Canright AES S-box.
-------------------------------------------------------------------------------
architecture Canright of sbox is

  -----------------------------------------------------------------------------
  -- Type definitions
  -----------------------------------------------------------------------------
  -- Array of bytes for storing constants required during the base conversion.
  type byteArrayType is array (0 to 7) of Byte;


  -----------------------------------------------------------------------------
  -- Constants
  -----------------------------------------------------------------------------
  constant A2X : byteArrayType := (x"98", x"F3", x"F2", x"48", x"09", x"81", x"A9", x"FF");
  constant X2S : byteArrayType := (x"58", x"2D", x"9E", x"0B", x"DC", x"04", x"03", x"24");

  -----------------------------------------------------------------------------
  -- Functions
  -----------------------------------------------------------------------------
  
  -- Multiply in GF(2^2).
  function mulG4 (
    inpOne : std_logic_vector(1 downto 0);
    inpTwo : std_logic_vector(1 downto 0))
    return std_logic_vector is
    variable a, b, c, d, e, p, q : std_logic;
  begin
    a := inpOne(1); b := inpOne(0);
    c := inpTwo(1); d := inpTwo(0);
    e := (a xor b) and (c xor d);
    p := (a and c) xor e;
    q := (b and d) xor e;
    return p & q;
  end function mulG4;

  -- Scale by N in GF(2^2) using normal basis.
  function sclNG4 (
    input : std_logic_vector(1 downto 0))
    return std_logic_vector is
  begin
    return (input(0) & (input(0) xor input(1)));
  end function sclNG4;

  -- Scale by N^2 in GF(2^2) using normal basis.
  function sclN2G4 (
    inp : std_logic_vector(1 downto 0))
    return std_logic_vector is
  begin
    return ((inp(0) xor inp(1)) & inp(1));
  end function sclN2G4;

  -- Square in GF(2^2) using normal basis (identical to inverse).
  function sqG4 (
    inp : std_logic_vector(1 downto 0))
    return std_logic_vector is
  begin
    return (inp(0) & inp(1));
  end function sqG4;

  -- Multiply in GF(2^4) using normal basis.
  function mulG16 (
    inpOne : std_logic_vector(3 downto 0);
    inpTwo : std_logic_vector(3 downto 0))
    return std_logic_vector is
    variable a, b, c, d, e, p, q : std_logic_vector(1 downto 0);
  begin
    a := inpOne(3 downto 2); b := inpOne(1 downto 0);
    c := inpTwo(3 downto 2); d := inpTwo(1 downto 0);
    e := mulG4(a xor b, c xor d);
    e := sclNG4(e);
    p := (mulG4(a, c) xor e);
    q := (mulG4(b, d) xor e);
    return p & q;
  end function mulG16;

  -- Square and scale by \nu in GF(2^4)/GF(2^2) using normal basis.
  function sqSclG16 (
    inp : std_logic_vector(3 downto 0))
    return std_logic_vector is
    variable p, q : std_logic_vector(1 downto 0);
  begin
    p := sqG4(inp(3 downto 2) xor inp(1 downto 0));
    q := sclN2G4(sqG4(inp(1 downto 0)));
    return p & q;
  end function sqSclG16;

  -- Inverse in GF(2^4) using normal basis.
  function invG16 (
    inp : std_logic_vector(3 downto 0))
    return std_logic_vector is
    variable a,b,c,d,e,p,q : std_logic_vector(1 downto 0);
  begin
    a := inp(3 downto 2); b := inp(1 downto 0);
    c := sclNG4(sqG4(a xor b));
    d := mulG4(a, b);
    e := sqG4(c xor d);
    p := mulG4(e, b);
    q := mulG4(e, a);
    return p & q;
  end function invG16;

  -- Inversion in GF(2^8) using normal basis.
  function invG256 (
    inp : std_logic_vector(7 downto 0))
    return std_logic_vector is
    variable a,b,c,d,e,p,q : std_logic_vector(3 downto 0);
  begin
    a := inp(7 downto 4); b:= inp(3 downto 0);
    c := sqSclG16(a xor b);
    d := mulG16(a, b);
    e := invG16(c xor d);
    p := mulG16(e, b);
    q := mulG16(e, a);
    return p & q;
  end function invG256;

  -- Base conversion in GF(2^8).
  function baseConv (
    input     : Byte;
    baseConst : byteArrayType)
    return Byte is
    variable tmp : Byte;
  begin
    tmp := ZERO_BYTE;
    for i in 0 to 7 loop
      if input(i) = '1' then
        tmp := tmp xor baseConst(7-i);
      end if;
    end loop;  -- i
    return tmp;
  end function baseConv;


  -----------------------------------------------------------------------------
  -- Signals
  -----------------------------------------------------------------------------
  signal NewBase_D : Byte;              --! @brief Value after first base conversion.
  signal Inverse_D : Byte;              --! @brief Inverse of input in new base.
  signal OldBase_D : Byte;              --! @brief Value after second base conversion.

  
begin  -- architecture Canright

  -- Perform inverse calculation in different basis.
  NewBase_D <= baseConv(In_DI, A2X);
  Inverse_D <= invG256(NewBase_D);
  OldBase_D <= baseConv(Inverse_D, X2S);

  -- Output assignment.
  Out_DO <= OldBase_D xor x"63";

end architecture Canright;
