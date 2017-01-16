-- Bidirectional LED scanner a la KITT or the Cylons
--
-- CLK is 50 MHz clock input
-- LED is active-high output for a bank of four LEDs

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity scanner is
    port (CLK : in  STD_LOGIC;
          LED : out STD_LOGIC_VECTOR (3 downto 0));
end scanner;

architecture rtl of scanner is

    signal div_cnt : integer range 0 to 12_499_999 := 0;
    signal state   : integer range 1 to 6          := 1;

begin

    divider : process(CLK)
    begin
        if CLK'event and CLK = '1' then
            if div_cnt = 12_499_999 then
                div_cnt <= 0;
                if state = 6 then
                    state <= 1;
                else
                    state <= state + 1;
                end if;
            else
                div_cnt <= div_cnt + 1;
                state <= state;
            end if;
        end if;
    end process;

    with state select LED <=
        "1000" when 1,
        "0100" when 2|6,
        "0010" when 3|5,
        "0001" when 4;

end rtl;
