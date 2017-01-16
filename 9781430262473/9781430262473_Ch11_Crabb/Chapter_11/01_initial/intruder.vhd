-- Initial implementation of pressure mat alarm
--
-- LED is active-high output for bank of four status LEDs
-- BTN is active-high reset button input
-- MAT is active-low pressure mat input
--
-- LED(0) lights while trigger condition is in effect
-- LED(1) lights while reset condition is in effect
-- LED(2) and LED(3) light while alarm is active
--
-- Alarm is triggered by pressure mat and remains active until reset
-- button is pressed

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity intruder is
    port (LED       : out STD_LOGIC_VECTOR (3 downto 0);
          BTN       : in  STD_LOGIC;
          MAT       : in  STD_LOGIC;
          MEM_CEN   : out STD_LOGIC;
          BUSSW_OEN : out STD_LOGIC);
end intruder;

architecture Behavioral of intruder is

    signal trigger : STD_LOGIC;
    signal reset   : STD_LOGIC;
    signal alarm   : STD_LOGIC := '0';

begin

    alarm <= '1' when trigger = '1'
        else '0' when reset = '1'
        else alarm;

    LED <= (0 => trigger, 1 => reset, others => alarm);
    reset <= BTN;
    trigger <= not MAT;

    MEM_CEN <= '1';
    BUSSW_OEN <= '0';

end Behavioral;
