library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity uc_lut is
    port(
        end_lut, RAZ, RAZ_P2, LD_SYNDROME, INC_P1, INC_P2, LD_ERR: out std_logic;
        ERR: out std_logic_vector(1 downto 0);
        start_lut, P1_MAX, P2_MAX, ERR1, ERR2: in std_logic;
        clk: in std_logic;
        reset: in std_logic
    );
end entity;

architecture arch_uc_lut of uc_lut is
    type state is (IDLE, LUT);
    signal current_state, next_state: state;
begin
    process(clk, reset)
    begin
        if reset = '1' then
            current_state <= IDLE;
        elsif rising_edge(clk) then
            current_state <= next_state;
        end if;
    end process;

    process(current_state, start_lut, P2_MAX, P1_MAX, ERR1, ERR2)
    begin
        RAZ <= '0';
        RAZ_P2 <= '0';
        LD_SYNDROME <= '0';
        INC_P1 <= '0';
        INC_P2 <= '0';
        LD_ERR <= '0';
        ERR <= "00";
        next_state <= current_state;
        end_lut <= '0';

        case current_state is
            when IDLE =>
                if start_lut = '1' then
                    next_state <= LUT;
                    RAZ <= '1';
                    RAZ_P2 <= '1';
                    LD_SYNDROME <= '1';
                end if;
            when LUT =>
                if P2_MAX = '1' then
                    INC_P1 <= '1';
                    RAZ_P2 <= '1';
                elsif ERR1 = '1' then
                    end_lut <= '1';
                    next_state <= IDLE;
                    LD_ERR <= '1';
                    ERR <= "01";
                elsif ERR2 = '1' then
                    end_lut <= '1';
                    next_state <= IDLE;
                    LD_ERR <= '1';
                    ERR <= "10";
                elsif P1_MAX = '1' then
                    end_lut <= '1';
                    next_state <= IDLE;
                    LD_ERR <= '1';
                    ERR <= "11";
                elsif P1_MAX = '0' or P2_MAX = '0' then
                    INC_P2 <= '1';
                end if;
        end case;
    end process;
end architecture;


library ieee;
use ieee.std_logic_1164.all;
use IEEE.numeric_std.all;

entity uc_lut_test is
end uc_lut_test;

architecture behavior of uc_lut_test is
    component uc_lut is
    port(
        end_lut, RAZ, RAZ_P2, LD_SYNDROME, INC_P1, INC_P2, LD_ERR: out std_logic;
        ERR: out std_logic_vector(1 downto 0);
        start_lut, P1_MAX, P2_MAX, ERR1, ERR2: in std_logic;
        reset, clk: in std_logic
    );
    end component;
    signal end_lut, RAZ, RAZ_P2, LD_SYNDROME, INC_P1, INC_P2, LD_ERR: std_logic;
    signal ERR: std_logic_vector(1 downto 0);

    signal start_lut, P1_MAX, P2_MAX, ERR1, ERR2: std_logic;
    signal clk, finish: std_logic;
    signal reset: std_logic;
begin
    uut: uc_lut port map (
        start_lut => start_lut,
        end_lut => end_lut,
        reset => reset,
        clk => clk,
        RAZ => RAZ,
        RAZ_P2 => RAZ_P2,
        INC_P1 => INC_P1,
        INC_P2 => INC_P2,
        LD_SYNDROME => LD_SYNDROME,
        P1_MAX => P1_MAX,
        P2_MAX => P2_MAX,
        ERR1 => ERR1,
        ERR2 => ERR2,
        LD_ERR => LD_ERR,
        ERR => ERR
    );

    stim_proc: process
    begin
        start_lut <= '0';
        err1 <= '0';
        err2 <= '0';
        p1_max <= '0';
        p2_max <= '0';
        reset <= '1';
        wait for 21 ns;
        reset <= '0';

        start_lut <= '1';
        wait for 1 ns;
        assert ld_syndrome = '1';
        assert raz = '1';
        assert raz_p2 = '1';
        wait for 19 ns;
        start_lut <= '0';
        assert ld_syndrome = '0';
        assert raz = '0';
        assert raz_p2 = '0';
        assert inc_p2 = '1';
        wait for 210 ns;
        p2_max <= '1';
        wait for 1 ns;
        assert raz_p2 = '1';
        assert inc_p1 = '1';
        assert inc_p2 = '0';
        wait until rising_edge(clk);
        p2_max <= '0';
        wait for 1 ns;
        assert inc_p2 = '1';
        wait until rising_edge(clk);
        err1 <= '1';
        wait until rising_edge(clk);
        assert err = "01";
        assert ld_err = '1';
        err1 <= '0';
        wait until rising_edge(clk);
        assert err = "00";
        assert ld_err = '0';


        start_lut <= '1';
        wait until rising_edge(clk);
        start_lut <= '0';
        wait until rising_edge(clk);
        assert end_lut = '0';
        err2 <= '1';
        wait until rising_edge(clk);
        assert err = "10";
        assert ld_err = '1';
        assert end_lut = '1';
        err2 <= '0';
        wait until rising_edge(clk);

        start_lut <= '1';
        wait until rising_edge(clk);
        start_lut <= '0';
        wait until rising_edge(clk);
        p1_max <= '1';
        wait until rising_edge(clk);
        assert err = "11";
        assert ld_err = '1';
        assert end_lut = '1';
        p1_max <= '0';
        wait until rising_edge(clk);

        finish <= '1';
        wait;
    end process;

    process
    begin
        if finish = '1' then
            wait;
        else
            clk <= '1';
            wait for 20 ns;
            clk <= '0';
            wait for 20 ns;
        end if;
    end process;
end architecture;

