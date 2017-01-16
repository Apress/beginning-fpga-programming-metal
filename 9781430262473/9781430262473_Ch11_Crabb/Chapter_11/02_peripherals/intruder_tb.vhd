-- Test bench for exercising pressure mat alarm with additional
-- peripherals

library ieee;
use ieee.std_logic_1164.all;

entity intruder_tb is
end intruder_tb;

architecture behavior of intruder_tb is

     -- Component Declaration for the Unit Under Test (UUT)
     component intruder
         port (LED       : out STD_LOGIC_VECTOR(3 downto 0);
               BTN       : in  STD_LOGIC;
               BUZZ      : out STD_LOGIC;
               MAT       : in  STD_LOGIC;
               EXTRST    : in  STD_LOGIC;
               MEM_CEN   : out STD_LOGIC;
               BUSSW_OEN : out STD_LOGIC);
     end component;

    --Inputs
    signal BTN    : STD_LOGIC := '0';
    signal MAT    : STD_LOGIC := '1';
    signal EXTRST : STD_LOGIC := '1';

    --Outputs
    signal LED    : STD_LOGIC_VECTOR(3 downto 0);
    signal BUZZ   : STD_LOGIC;

begin

    -- Instantiate the Unit Under Test (UUT)
    uut : intruder port map (
        LED    => LED,
        BTN    => BTN,
        BUZZ   => BUZZ,
        MAT    => MAT,
        EXTRST => EXTRST);

    stim_proc : process
    begin
        -- hold reset state for 1 ms
        wait for 1 ms;

        -- press and release reset button while alarm is inactive
        BTN <= '1';
        wait for 1 ms;
        BTN <= '0';
        wait for 1 ms;

        -- try the other reset button as well
        EXTRST <= '0';
        wait for 1 ms;
        EXTRST <= '1';
        wait for 1 ms;

        -- trigger the alarm by activating the pressure mat input
        MAT <= '0';
        wait for 1 ms;
        MAT <= '1';
        wait for 1 ms;

        -- repeat the trigger condition
        MAT <= '0';
        wait for 1 ms;
        MAT <= '1';
        wait for 1 ms;

        -- press and release reset button while alarm is active
        BTN <= '1';
        wait for 1 ms;
        BTN <= '0';
        wait for 1 ms;

        -- try pressing each button while pressure mat is active
        MAT <= '0';
        wait for 1 ms;
        BTN <= '1';
        wait for 1 ms;
        BTN <= '0';
        wait for 1 ms;
        EXTRST <= '0';
        wait for 1 ms;
        EXTRST <= '1';
        wait for 1 ms;
        MAT <= '1';
        wait for 1 ms;

        -- what about the reverse - short mat pulse while reset is held?
        EXTRST <= '0';
        wait for 1 ms;
        MAT <= '0';
        wait for 1 ms;
        MAT <= '1';
        wait for 1 ms;
        BTN <= '1';
        wait for 1 ms;
        MAT <= '0';
        wait for 1 ms;
        MAT <= '1';
        wait for 1 ms;
        EXTRST <= '1';
        wait for 1 ms;
        MAT <= '0';
        wait for 1 ms;
        MAT <= '1';
        wait for 1 ms;
        BTN <= '0';
        wait for 1 ms;

        -- wait forever so process doesn't repeat
        wait;
    end process;

end;
