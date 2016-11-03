library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity lut is
    port(
        start_lut, clk, raz_err, reset: in std_logic;
        SYNDROME: in std_logic_vector(9 downto 0);

        end_lut: out std_logic;
        P1, P2: out std_logic_vector(4 downto 0);
        ERR: out std_logic_vector(1 downto 0)
    );
end lut;

library ieee;
use ieee.std_logic_1164.all;
use IEEE.numeric_std.all;

architecture arch_lut of lut is
    component ut_lut is
        port (
            clk, INC_P1, INC_P2, LD_SYNDROME, RAZ, RAZ_P2: in std_logic;
            SYNDROME: in std_logic_vector(9 downto 0);
            P1_MAX, P2_MAX, ERR1, ERR2: out std_logic;
            P1, P2: out std_logic_vector(4 downto 0)
        );
    end component;

    component uc_lut is
    port(
        end_lut, RAZ, RAZ_P2, LD_SYNDROME, INC_P1, INC_P2, LD_ERR: out std_logic;
        ERR: out std_logic_vector(1 downto 0);
        start_lut, P1_MAX, P2_MAX, ERR1, ERR2: in std_logic;
        reset, clk: in std_logic
    );
    end component;

    signal RAZ, RAZ_P2, LD_SYNDROME, INC_P1, INC_P2, ERR1, ERR2: std_logic;
    signal P1_MAX, P2_MAX: std_logic;
    signal in_ld_err: std_logic;
    signal in_err, reg_err: std_logic_vector(1 downto 0);
begin
    uut: ut_lut port map (
        clk => clk,
        INC_P1 => INC_P1,
        INC_P2 => INC_P2,
        LD_SYNDROME => LD_SYNDROME,
        RAZ => RAZ,
        RAZ_P2 => RAZ_P2,
        SYNDROME => SYNDROME,
        P1_MAX => P1_MAX,
        P2_MAX => P2_MAX,
        ERR1 => ERR1,
        ERR2 => ERR2,
        P1 => P1,
        P2 => P2
    );
    uuc: uc_lut port map (
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
        LD_ERR => in_ld_err,
        ERR =>in_err
    );

    process(clk)
    begin
        if rising_edge(clk) then
            if raz_err = '1' then
                reg_err <= "00";
            elsif in_ld_err = '1' then
                reg_err <= in_err;
            end if;
        end if;
    end process;

    ERR <= reg_err;
end architecture;

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity lut_test is
end lut_test;

architecture behavior of lut_test is
    component lut is
        port(
            start_lut, clk, raz_err: in std_logic;
            SYNDROME: in std_logic_vector(9 downto 0);

            end_lut: out std_logic;
            P1, P2: out std_logic_vector(4 downto 0);
            ERR: out std_logic_vector(1 downto 0);
            reset: in std_logic
        );
    end component;

    signal start_lut, clk, raz_err, reset: std_logic;
    signal SYNDROME: std_logic_vector(9 downto 0);
    signal end_lut, LD_ERR: std_logic;
    signal P1, P2: std_logic_vector(4 downto 0);
    signal ERR: std_logic_vector(1 downto 0);
    signal finish: std_logic;
begin

    uut: lut port map (
        reset => reset,
        clk => clk,
        start_lut => start_lut,
        end_lut => end_lut,
        raz_err => raz_err,
        SYNDROME => SYNDROME,
        P1 => P1,
        P2 => P2,
        ERR => ERR
    );

    process
    begin
        reset <= '1';
        wait for 10 ns;
        reset <= '0';
        SYNDROME <= "1110011010";
        start_lut <= '1';
        wait until rising_edge(clk);
        start_lut <= '0';
        wait until end_lut = '1';
        wait for 5 ns;
        wait for 45 ns;
        assert ERR = "11";
        start_lut <= '1';
        SYNDROME <= "0000110010";
        wait until rising_edge(clk);
        start_lut <= '0';
        wait for 1 ns;
        wait until end_lut = '1';
        wait for 55 ns;
        assert ERR = "10";
        assert unsigned(P1) = 14 ;
        assert unsigned(P2) = 17;
        start_lut <= '1';
        SYNDROME <= "1000101100";
        wait until rising_edge(clk);
        start_lut <= '0';
        wait for 1 ns;
        wait until end_lut = '1';
        wait for 55 ns;
        assert ERR = "01";
        assert unsigned(P1) = 17;
        raz_err <= '1';
        wait until rising_edge(clk);
        wait for 1 ns;
        assert err = "00";
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

