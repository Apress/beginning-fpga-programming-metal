-- Test bench for exercising LED scanner

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY scanner_tb IS
END scanner_tb;

ARCHITECTURE behavior OF scanner_tb IS

    -- Component Declaration for the Unit Under Test (UUT)
    COMPONENT scanner
        PORT (CLK : IN  std_logic;
              LED : OUT std_logic_vector(3 downto 0));
    END COMPONENT;

    --Inputs
    signal CLK : std_logic := '0';

    --Outputs
    signal LED : std_logic_vector(3 downto 0);

    -- Clock period definitions
    constant CLK_period : time := 20 ns;

BEGIN

    -- Instantiate the Unit Under Test (UUT)
    uut : scanner PORT MAP (CLK => CLK, LED => LED);

    -- Clock process definitions
    CLK_process : process
    begin
        CLK <= '0';
        wait for CLK_period / 2;
        CLK <= '1';
        wait for CLK_period / 2;
    end process;

    -- Stimulus process
    stim_proc : process
    begin
        -- hold reset state for 100 ns.
        wait for 100 ns;

        wait for CLK_period * 10;

        -- insert stimulus here

        wait;
    end process;

END;
