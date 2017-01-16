-- Enhanced pressure mat alarm with debounced button inputs
--
-- MASTER_CYC sets master divider period in terms of CLK signal period
-- FLASH_DIV sets duration of each LED flash in master divider periods
-- CHIRP_DIV sets duration of chirp and pause in master divider periods
-- BUZZ_DIV sets maximum time buzzer for buzzer to sound after trigger
--     is removed in master divider periods
-- BOUNCE_CYC sets button debounce time in terms of CLK signal period
--
-- LED is active-high output for bank of four status LEDs
-- BTN is active-high reset button input
-- BUZZ is active-high output for buzzer
-- MAT is active-low pressure mat input
-- EXTRST is active-low input for additional reset button
-- CLK is master clock input
--
-- LED(0) and LED(1) flash in alternation while alarm is active
-- LED(2) lights while either reset button is depressed
-- LED(3) lights while trigger condition is in effect
-- buzzer chirps for 10 s after alarm is triggered
--
-- Alarm is triggered by pressure mat and remains active until either
-- reset button is pressed.  Buzzer chirps from when alarm activates
-- until alarm is deactivated or set time elapses after trigger
-- condition is removed, whichever comes first.

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity intruder is
    generic (MASTER_CYC : integer := 2_500_000; -- 50 ms at 50 MHz
             FLASH_DIV  : integer := 5;         -- 250 ms in 50 ms units
             CHIRP_DIV  : integer := 1;         -- 50 ms in 50 ms units
             BUZZ_DIV   : integer := 200;       -- 10 s in 50 ms units
             BOUNCE_CYC : integer := 1_000_000); -- 20 ms at 50 MHz
    port (LED       : out STD_LOGIC_VECTOR (3 downto 0);
          BTN       : in  STD_LOGIC;
          BUZZ      : out STD_LOGIC;
          MAT       : in  STD_LOGIC;
          EXTRST    : in  STD_LOGIC;
          CLK       : in  STD_LOGIC;
          MEM_CEN   : out STD_LOGIC;
          BUSSW_OEN : out STD_LOGIC);
end intruder;

architecture Behavioral of intruder is

    type bool_pair is array (0 to 1) of boolean;

    signal trigger    : boolean;
    signal reset      : boolean;
    signal alarm      : boolean   := false;

    signal btn_val    : bool_pair := (others => false);
    signal extrst_val : bool_pair := (others => false);

    signal flash      : boolean   := false;
    signal chirp      : boolean   := false;

    signal master_cnt : integer range 0 to MASTER_CYC - 1 := 0;
    signal buzz_cnt   : integer range 0 to BUZZ_DIV       := 0;

    function BoolToLogic(b : boolean) return STD_LOGIC is
    begin
        if b then
            return '1';
        else
            return '0';
        end if;
    end function BoolToLogic;

    -- bp(0) holds current value, bp(1) holds previous value
    -- returns true when value transistions from false to true
    function DetectEdge(bp : bool_pair) return boolean is
    begin
        return bp(0) and not bp(1);
    end function DetectEdge;

begin

    LED <= BoolToLogic(trigger)
        & BoolToLogic(btn_val(0) or extrst_val(0))
        & BoolToLogic(alarm and flash)
        & BoolToLogic(alarm and not flash);
    BUZZ <= BoolToLogic(buzz_cnt /= 0 and chirp);

    MEM_CEN <= '1';
    BUSSW_OEN <= '0';

    trigger <= MAT = '0';
    reset <= DetectEdge(btn_val) or DetectEdge(extrst_val);

    alarm_proc : process (CLK)
    begin
        if CLK'event and CLK = '1' then
            if trigger then
                alarm <= true;
            elsif reset then
                alarm <= false;
            end if;
        end if;
    end process;

    button_buffer : process (CLK)
        variable btn_debounce    : integer range 0 to BOUNCE_CYC := 0;
        variable extrst_debounce : integer range 0 to BOUNCE_CYC := 0;
    begin
        if CLK'event and CLK = '1' then
            btn_val(1) <= btn_val(0);
            if btn_debounce /= 0 then
                btn_debounce := btn_debounce - 1;
            elsif btn_val(0) /= (BTN = '1') then
                btn_val(0) <= BTN = '1';
                btn_debounce := BOUNCE_CYC;
            end if;

            extrst_val(1) <= extrst_val(0);
            if extrst_debounce /= 0 then
                extrst_debounce := extrst_debounce - 1;
            elsif extrst_val(0) /= (EXTRST = '0') then
                extrst_val(0) <= EXTRST = '0';
                extrst_debounce := BOUNCE_CYC;
            end if;
        end if;
    end process;

    free_timing : process (CLK)
        variable flash_cnt : integer range 0 to FLASH_DIV - 1 := 0;
        variable chirp_cnt : integer range 0 to CHIRP_DIV - 1 := 0;
    begin
        if CLK'event and CLK = '1' then
            if master_cnt /= MASTER_CYC - 1 then
                master_cnt <= master_cnt + 1;
            else
                master_cnt <= 0;

                if flash_cnt = FLASH_DIV - 1 then
                    flash_cnt := 0;
                    flash <= not flash;
                else
                    flash_cnt := flash_cnt + 1;
                end if;

                if chirp_cnt = chirp_DIV - 1 then
                    chirp_cnt := 0;
                    chirp <= not chirp;
                else
                    chirp_cnt := chirp_cnt + 1;
                end if;
            end if;
        end if;
    end process;

    buzz_timing : process (CLK)
    begin
        if CLK'event and CLK = '1' then
            if trigger then
                buzz_cnt <= BUZZ_DIV;
            elsif reset then
                buzz_cnt <= 0;
            elsif master_cnt = MASTER_CYC - 1 and buzz_cnt /= 0 then
                buzz_cnt <= buzz_cnt - 1;
            end if;
        end if;
    end process;

end Behavioral;
