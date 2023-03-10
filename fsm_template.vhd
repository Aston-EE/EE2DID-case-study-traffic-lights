--------------------------------------------------------------------------------
-- Title       : Finite State Machine Template
-- Project     : EE2DDS Practical Work
-- Author      : John A.R. Williams
-- Copyright   : 2017-2023 Aston University
--------------------------------------------------------------------------------
-- Description :
-- A three process finite state machine design template in VHDL as per Xilinx
-- recommendations
--
-- To declare you own state bit mapping in architecture use e.g.
-- attribute enum_encoding : string;
-- attribute enum_encoding of state_type : type is "001 010 100 110 111 101";
--
-- We can also specify an automatic encoding regime to be used
-- This is implementation dependant. For vivado legitimate values are
-- "auto","gray","johnson","one_hot","sequential" or "user"
-- default is "auto" e.g.
-- attribute fsm_encoding: string;
-- attribute fsm_encoding of state is "johnson";
-- 
-- see https://www.xilinx.com/support/answers/60799.html
-- for more info and attributes
--------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity fsm is
  port (
    clk: in std_logic; -- system clock
    reset: in std_logic; -- reset (synchronous preferred)
    -- list other inputs here e.g.
    x :in std_logic;
    -- list outputs here e.g.
    parity: out std_logic
    );
end fsm;

architecture rtl of fsm is
  -- list states names for state type here e.g. S0,S1 etc
  type state_type is ( );
  signal state,next_state: state_type; -- current and next state
  
begin

  -- Clocked Process for synchronous (clocked) operation
  SYNC_PROC: process (clk) 
  begin
    if rising_edge(clk) then
      if (reset = '1') then -- here we have a synchronous reset (preferred)
        state <= S0;        -- assign state to reset state value
      else
        state <= next_state;
      end if;
    end if;
  end process;

  -- Combinational Process for the output decoding.
  -- for a Moore model it will be sensitive to state only
  -- for a Mealy model it will also be sensitive to immediate inputs 
  OUTPUT_DECODE: process (state)
  begin
    -- assign default outputs here to ensure all outputs are set for each case
    
    -- case statement for each state which sets outputs as required
    -- Mealy outputs will also test inputs
    case (state) is
      when S0 =>
        -- .....
      when others => -- when others catchall safe output
    end case;
  end process;

  -- Combinational process for next state decoding
  -- sensitive to state change and inputs
  NEXT_STATE_DECODE: process (state, <input list> )
  begin
    -- assign a default next state if appropriate
    -- next_state <= ...;
    
    -- case statement checking current state
    -- and checking inputs to determine next state.
    case (state) is
      when S0 =>
      when others =>  -- have when others catchall to go to a safe state
        next_state <= S0;
    end case;
  end process;
  
end rtl;
