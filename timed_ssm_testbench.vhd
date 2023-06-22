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
 
entity timed_ssm_testbench is
end timed_ssm_testbench;
 
architecture behaviour of timed_ssm_testbench is

  constant clk_period   : time := 100 ns;
  constant no_ticks     : integer := 300;
  constant clk_div      : integer :=3; -- how often increase time signal
  
  component timed_ssm is
  port (
    clk     : in STD_LOGIC;
    time        : in UNSIGNED(5 downto 0);
    start_timer : out STD_logic;
    Rmin,Amin,Gmin,Rmaj,Amaj,Gmaj : out STD_LOGIC
    );
  end component;

  subtype light_state is std_logic_vector(5 downto 0);
  type table_entry is record
    lights: light_state; -- light state
    duration: integer; -- and how long they are held
  end record;
  type table_vector is array (natural range<>) of table_entry;
  
  constant seq: table_vector :=
    (("110100",2), -- RAR
     ("001100",30), --GR
     ("010100",4), -- AR
     ("100110",2), -- RRA
     ("100001",30), --RG
     ("100010",4), -- RA
     ("110100",2) -- and check back to beginning
     );

  signal lights: light_state; -- actual light state

  signal time : UNSIGNED(5 downto 0):=(others=>'0');

  signal clk,clk_en,start_timer,finished: std_logic:='0';

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
  uut: timed_ssm port map (
    clk => clk,
    time => time,
    start_timer => start_timer,
    Rmaj => lights(5),
    Amaj => lights(4),
    Gmaj => lights(3),
    Rmin => lights(2),
    Amin => lights(1),
    Gmin => lights(0)
    );
  
  clk_gen: process -- generate clk and timer signals
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
    variable expected: light_state;
    variable i,duration: integer;
    variable prev: light_state; -- stores previous light state to check changes
  begin
    finished<='0';
    prev:=lights;
    for i in seq'range loop
      expected := seq(i).lights;
      duration := seq(i).duration;
      -- check lights are as expected
      assert(lights=expected)
        report "Expected "&to_string(expected)& " but got "&to_string(lights);
      -- wait for ligits to change
      wait until lights /= prev;
      -- check duration was correct
      assert to_integer(time)=duration
        report "Incorrect duration " & integer'image(to_integer(time)) & " expected " & integer'image(duration);
      prev:=lights;
    end loop;
    finished<='1';
    wait;
  end process;
  

end behaviour;
