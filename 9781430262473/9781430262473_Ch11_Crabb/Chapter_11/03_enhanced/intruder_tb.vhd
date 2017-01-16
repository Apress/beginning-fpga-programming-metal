-- Test bench for exercising enhanced pressure mat alarm

library ieee;
use ieee.std_logic_1164.all;
 
entity intruder_tb is
end intruder_tb;
 
architecture behavior of intruder_tb is 

    --Inputs
    signal BTN    : STD_LOGIC := '0';
    signal MAT    : STD_LOGIC := '1';
    signal EXTRST : STD_LOGIC := '1';
    signal CLK    : STD_LOGIC := '0';

    --Outputs
    signal LED    : STD_LOGIC_VECTOR(3 downto 0);
    signal BUZZ   : STD_LOGIC;

    -- Clock period definitions
    constant CLK_period : time := 20 ns;

begin

    -- Instantiate the Unit Under Test (UUT)
    uut : entity work.intruder
        generic map (
            MASTER_CYC => 2_500)
        port map (
            LED    => LED,
            BTN    => BTN,
            BUZZ   => BUZZ,
            MAT    => MAT,
            EXTRST => EXTRST,
            CLK    => CLK);

    -- Clock process definitions
    CLK_process : process
    begin
        wait for CLK_period / 2;
        CLK <= not CLK;
    end process;

    stim_proc : process
    begin
        -- hold reset state for 500 us
        wait for 500 us;

        -- very short trigger won't be caught
        wait for CLK_period * 3 / 4;
        MAT <= '0';
        wait for CLK_period / 2;
        MAT <= '1';
        wait for 500 us - (CLK_period * 5 / 4);

        -- press and release reset button while alarm is inactive
        BTN <= '1';
        wait for 500 us;
        BTN <= '0';
        wait for 500 us;

        -- try the other reset button as well
        EXTRST <= '0';
        wait for 500 us;
        EXTRST <= '1';
        wait for 500 us;

        -- trigger the alarm by activating the pressure mat input
        MAT <= '0';
        wait for 500 us;
        MAT <= '1';
        wait for 500 us;

        -- repeat the trigger condition
        MAT <= '0';
        wait for 500 us;
        MAT <= '1';
        wait for 500 us;

        -- press and release reset button while alarm is active
        BTN <= '1';
        wait for 500 us;
        BTN <= '0';
        wait for 500 us;

        -- check that the other reset button resets the alarm too
        MAT <= '0';
        wait for 500 us;
        MAT <= '1';
        wait for 500 us;
        EXTRST <= '0';
        wait for 500 us;
        EXTRST <= '1';
        wait for 500 us;

        -- try pressing each button while pressure mat is active
        MAT <= '0';
        wait for 500 us;
        BTN <= '1';
        wait for 500 us;
        BTN <= '0';
        wait for 500 us;
        EXTRST <= '0';
        wait for 500 us;
        EXTRST <= '1';
        wait for 500 us;
        MAT <= '1';
        wait for 500 us;

        -- what about the reverse - short mat pulse while reset is held?
        EXTRST <= '0';
        wait for 500 us;
        MAT <= '0';
        wait for 500 us;
        MAT <= '1';
        wait for 500 us;
        BTN <= '1';
        wait for 500 us;
        MAT <= '0';
        wait for 500 us;
        MAT <= '1';
        wait for 500 us;
        EXTRST <= '1';
        wait for 500 us;
        MAT <= '0';
        wait for 500 us;
        MAT <= '1';
        wait for 500 us;
        BTN <= '0';
        wait for 500 us;

        -- wait forever so process doesn't repeat
        wait;
    end process;
end;
