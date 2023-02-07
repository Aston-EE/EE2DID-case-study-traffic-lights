--------------------------------------------------------------------------------
-- Title:        : Package with component declarations
-- Project       : EE2IDD Practical Work
-- Author        : John A.R. Williams
-- Copyright     : 2019 Dr. J.A.R. Williams, Aston University
--------------------------------------------------------------------------------
-- Purpose       : Package with component declarations for EE2IDD coursework 
--               : 
--------------------------------------------------------------------------------
-- Revisions     :
-- Date       Version Author                Description
-- 2019-04-06 1.0     John A.R. Williams    Created
--------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;
use IEEE.MATH_REAL.all;
use STD.textio.all;

package ee2idd is

  -- Synchronous binary counter with asynchronous reset and terminal count.
  component counter is
    generic (
      nbits  : integer := 4;            -- num bits for counter
      start  : integer := 0;            -- where count starts from
      finish : integer := 9             -- where count ends (inclusive)
      );
    port (
      clk   : in  std_logic;            -- system clock
      ce    : in  std_logic;            -- count enable
      reset : in  std_logic;            -- asynchronous reset
      count : out unsigned(nbits-1 downto 0);
      tc    : out std_logic := '0'  -- set to '1' at terminal count for cascading
      );
  end component;

  -- Clock prescaler - outputs enable pulse every n system clock pulses
  component clk_prescaler is
    generic (n :    integer);
    port (clk  : in std_logic; clk_div : out std_logic);
  end component;

  -- Synchronise and debounce logic level and event output from a button input.
  component debounce is
    port (
      clk                   : in  std_logic;  -- system clock
      clk_en                : in  std_logic;  -- low frequency sampling clock enable (e.g. 1kHz)
      button                : in  std_logic;  -- input from button
      debounced, down_event : out std_logic := '0'  -- debounced output
      );
  end component;

  -- Drive 4 digit 7 segment display from BCD input including decimal point.
  component display is
    port (
      clk      : in  std_logic;
      clk_en   : in  std_logic;  -- refresh clock enable should be <=1kHz
      bcd      : in  std_logic_vector(15 downto 0) := (others => '0');  -- 4 BCD digits
      dp_on    : in  std_logic_vector(3 downto 0)  := "0000";  -- dp on enable
      -- Outputs to connect directly to external display hardware
      segments : out std_logic_vector (6 downto 0);  -- 7 segments cathode drive
      dp       : out std_logic;         -- decimal point 
      anodes   : out std_logic_vector (3 downto 0)   -- anode drive (0 is on)
      );
  end component;

  -- return number of bits to address n elements
  function nbits(n : in integer) return integer;

  -- function to produce a string representation of a std_logic_vector
  function to_string (a : std_logic_vector) return string;

  -- wait for delay time then check v=tv and assert error if not
  procedure check_vector(v  : in std_logic_vector; delay : in time;
                         tv : in std_logic_vector);


end package;

package body EE2IDD is
  function nbits(n : in integer) return integer is
  begin
    return integer(ceil(log2(real(n))));
  end function nbits;

  function to_string (a : std_logic_vector) return string is
    variable b : string (1 to a'length) := (others => NUL);
  begin
    for i in a'range loop
      b(i) := std_logic'image(a((i)))(2);
    end loop;
    return b;
  end function to_string;

  procedure check_vector(
    v     : in std_logic_vector;
    delay : in time;
    tv    : in std_logic_vector
    ) is
  begin
    wait for delay;
    assert v = tv report to_string(tv) & " failed - output=" & to_string(v);
  end check_vector;

end package body EE2IDD;
