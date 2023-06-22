--------------------------------------------------------------------------------
-- Title       : Testbench for timed traffic lights
-- Project     : EE2DDS Practical Work
-- Author      : John A.R. Williams
-- Copyright   : 2017-2023 Aston University
--------------------------------------------------------------------------------
-- Description :
-- Testbench for the timed traffic lights
--------------------------------------------------------------------------------
-- Revisions     :
-- Date       Version Author                Description
-- 2021/06/04 1.0     John A.R. Williams    Created
-- 2021/06/07 1.0     John A.R. Williams    Checked
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
 
entity priority_ssm_testbench is
end priority_ssm_testbench;
 
architecture behaviour of priority_ssm_testbench is

  constant clk_period   : time := 100 ns;
  constant no_ticks     : integer := 600;
  constant clk_div      : integer :=3; -- how often increase time signal
  
  component priority_ssm is
  port (
    clk     : in STD_LOGIC;
    time        : in UNSIGNED(5 downto 0);
    start_timer : out STD_logic;
    sensor: std_logic;
    Rmin,Amin,Gmin,Rmaj,Amaj,Gmaj : out STD_LOGIC
    );
  end component;

  subtype light_state is std_logic_vector(5 downto 0);
  signal lights: light_state; -- actual light state

  type table_entry is record
    lights: light_state; -- expected light state
    min_duration: integer; -- and  min time to be held
    max_duration: integer; -- max time to be held
    signal_set_time: integer; -- if >0 then the hold and sensor signals will be
    -- set after this time in this state
    sensor,hold: std_logic;
  end record;

  type table_vector is array (natural range<>) of table_entry;
  constant seq: table_vector :=
    (
      -- lights min max set sens hold
      -- sensor operation - it clears
      ("110100",2,2,0,'0','0'), -- RAR
      ("001100",15,15,10,'1','0'), --GR - with sensor set after 10 seconds
      ("010100",4,4,0,'0','0'), -- AR -- sensor not changed
      ("100110",2,2,0,'0','0'), -- RRA
      ("100001",10,30,5,'0','0'), --RG - car clears after 5 seconds
      ("100010",4,4,0,'0','0'), -- RA
      ("110100",2,2,0,'0','0'), -- RAR and check back to beginning
      -- sensor operation - it doesn't clear
      ("001100",15,15,10,'1','0'), --GR - with sensor set after 10 seconds
      ("010100",4,4,0,'0','0'), -- AR -- sensor not changed
      ("100110",2,2,0,'0','0'), -- RRA
      ("100001",10,30, 0,'0','0'), --RG - sensor doesn't clear
      ("100010",4,4,0,'0','0'), -- RA
      ("110100",2,2,0,'0','0'), -- RAR and check back to beginning - minor busy
      -- check sensor occurs before 30 sec up
      ("001100",15,15,0,'0','0'), --GR - with sensor not changed
      ("010100",4,4,0,'0','0'), -- AR -- sensor not changed
      ("100110",2,2,0,'0','0'), -- RRA
      ("100001",10,16, 15,'0','0'), --RG - clears after 15 sec
      ("100010",4,4,0,'0','0'), -- RA
      ("110100",2,2,0,'0','0') -- RAR and check back to beginning
     
      );
  signal current: table_entry;

  signal time : UNSIGNED(5 downto 0):=(others=>'0');

  signal clk,clk_en,start_timer,finished,hold,sensor: std_logic:='0';

  signal count: integer:=0; -- internal counting
  
  function to_string (a : std_logic_vector) return string is
    variable b    : string (1 to a'length) := (others => NUL);
    variable stri : integer                := 1;
  begin
    for i in a'range loop
      b(stri) := std_logic'image(a((i)))(2);
      stri    := stri+1;
    end loop;
    return b;
  end function;

 
begin
  uut: priority_ssm port map (
    clk => clk,
    time => time,
    start_timer => start_timer,
    sensor => sensor,
    -- hold => hold,
    Rmaj => lights(5),
    Amaj => lights(4),
    Gmaj => lights(3),
    Rmin => lights(2),
    Amin => lights(1),
    Gmin => lights(0)
    );
  
  clk_gen: process -- generate clk
  begin
    while finished<='0' loop
      clk <= '0';
      wait for clk_period/2 ;
      clk <= '1' ;
      wait for clk_period/2;
    end loop;
    wait;
  end process clk_gen;

  timer: process(clk) -- generate timer signals
  begin
    if rising_edge(clk) then
      count<=count+1; 
      assert(count<no_ticks) report "Simulation time exceeded" severity failure;
      if (count mod clk_div)=0 then
        time<=time+1;
      end if;
      if start_timer='1' then
        time<=(others=>'0');
      end if;
    end if;
  end process;

  test_sequence: process -- check sequence
    variable expected: table_entry;
    variable i,duration: integer;
    variable prev: light_state; -- stores previous light state to check changes
  begin
    finished<='0';
    prev:=lights;
    for i in seq'range loop
      expected := seq(i);
      -- check lights are as expected
      assert(lights=expected.lights)
        report "Expected "&to_string(expected.lights)& " but got "&to_string(lights);
      -- if a signal is to be set then set it after delay
      if expected.signal_set_time /=0 then
        wait until to_integer(time)=seq(i).signal_set_time;
        hold<=seq(i).hold;
        sensor<=seq(i).sensor;
      end if;
      -- wait for lights to change
      wait until lights /= prev;
      -- check duration was within range
      assert to_integer(time)>=expected.min_duration and
        to_integer(time)<=expected.max_duration
        report "Incorrect duration " & integer'image(to_integer(time)) & " expected " & integer'image(expected.min_duration) & "<=t<" & integer'image(expected.max_duration) ;
      prev:=lights;
    end loop;
    finished<='1';
    wait;
  end process;
  

end behaviour;
