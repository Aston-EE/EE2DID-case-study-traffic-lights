--------------------------------------------------------------------------------
-- Title       : Testbench for traffic light timer logic
-- Project     : EE2DDS Practical Work
-- Author      : John A.R. Williams
-- Copyright   : 2021 Dr. J.A.R. Williams, Aston University
--------------------------------------------------------------------------------
-- Description :
-- Testbench for traffic light timer logic
--------------------------------------------------------------------------------
-- Revisions   :
-- Date       Version Author                Description
-- 2021/06/04 1.0     John A.R. Williams    Created
-- 2021/06/07 1.1     John A.R. Williams    Checked
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
 
entity timer_testbench is
end timer_testbench;
 
architecture behaviour of timer_testbench is

  constant clk_period   : time := 100 ns;
  constant no_ticks     : integer := 100;
  constant clk_div      : integer :=2; -- how often to assert clk_en
  
  component timer is
    port (
      clk         : in STD_LOGIC; -- system clock
      clk_en      : in STD_LOGIC; -- timing clock (e.g. 1Hz)
      start_timer : in STD_LOGIC; -- reset time to 0
      time         : out UNSIGNED(5 downto 0) -- the output count
    );
  end component;

  signal clk,clk_en,start_timer: std_logic:='0';
  signal count: integer:=0; -- internal counting
  
    
begin
  uut: timer port map (
    clk => clk,
    clk_en => clk_en,
    start_timer => start_timer
    );
  
  clk1: process -- generate clk and clk_div
  begin
    start_timer<='1';
    while count<no_ticks loop
      clk <= '1';
      wait for clk_period/2 ;
      clk <= '0' ;
      wait for clk_period/2;
      count<=count+1;
      if (count mod clk_div)=0 then
        clk_en<='1';
      else
        clk_en<='0';
      end if;
      if (count=30) then
        start_timer<='1';
      else
        start_timer<='0';
      end if;
    end loop;
    wait;
  end process clk1;

end behaviour;
