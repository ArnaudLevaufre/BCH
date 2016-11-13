library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity ut_lut is
    port(
        clk, INC_P1, INC_P2, LD_SYNDROME, RAZ, LD_P2: in std_logic;
        SYNDROME: in std_logic_vector(9 downto 0);
        P1_MAX, P2_MAX, ERR1, ERR2: out std_logic;
        P1, P2: out std_logic_vector(4 downto 0)
    );
end ut_lut;

architecture arch_ut_lut of ut_lut is
    type lut is array (0 to 30) of std_logic_vector(9 downto 0);
    constant table: lut := ("0000000001",
                            "0000000010",
                            "0000000100",
                            "0000001000",
                            "0000010000",
                            "0000100000",
                            "0001000000",
                            "0010000000",
                            "0100000000",
                            "1000000000",
                            "0010110111",
                            "0101101110",
                            "1011011100",
                            "0100001111",
                            "1000011110",
                            "0010001011",
                            "0100010110",
                            "1000101100",
                            "0011101111",
                            "0111011110",
                            "1110111100",
                            "1111001111",
                            "1100101001",
                            "1011100101",
                            "0101111101",
                            "1011111010",
                            "0101000011",
                            "1010000110",
                            "0110111011",
                            "1101110110",
                            "1001011011");
    signal S1, S2: std_logic_vector(9 downto 0);
    signal S1xS2: std_logic_vector(9 downto 0);
    signal R_P1: std_logic_vector(4 downto 0) := (others => '0');
    signal R_P2: std_logic_vector(4 downto 0) := (others => '0');
    signal R_SYNDROME: std_logic_vector(9 downto 0);
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if INC_P1 = '1' then
                R_P1 <= std_logic_vector(unsigned(R_P1) + 1);
            end if;
            if INC_P2 = '1' then
                R_P2 <= std_logic_vector(unsigned(R_P2) + 1);
            end if;
            if LD_SYNDROME = '1' then
                R_SYNDROME <= SYNDROME;
            end if;
            if RAZ = '1' then
                R_P1 <= (others => '0');
            end if;
            if LD_P2 = '1' then
                R_P2 <= R_P1;
            end if;
        end if;
    end process;

    S1 <= table(TO_INTEGER(unsigned(R_P1)));
    S2 <= table(TO_INTEGER(unsigned(R_P2) + 1));
    S1xS2 <= S1 xor S2;
    ERR1 <= '1' when S1 = R_SYNDROME else '0';
    ERR2 <= '1' when S1xS2 = R_SYNDROME else '0';
    P1_MAX <= '1' when unsigned(R_P1) = 29 else '0';
    P2_MAX <= '1' when (unsigned(R_P2) + 1) = 30 else '0';
    P1 <= R_P1;
    P2 <= std_logic_vector(unsigned(R_P2) + 1);
end arch_ut_lut;

library ieee;
use ieee.std_logic_1164.all;
use IEEE.numeric_std.all;

entity ut_lut_test is
end ut_lut_test;

architecture behavior of ut_lut_test is
    component ut_lut is
        port (
            clk, INC_P1, INC_P2, LD_SYNDROME, RAZ, LD_P2: in std_logic;
            SYNDROME: in std_logic_vector(9 downto 0);
            P1_MAX, P2_MAX, ERR1, ERR2: out std_logic;
            P1, P2: out std_logic_vector(4 downto 0)
        );
    end component;
    signal output: std_logic_vector(11 downto 0);
    signal ERR1, ERR2: std_logic;
    signal clk: std_logic;
    signal INC_P1: std_logic;
    signal INC_P2: std_logic;
    signal LD_SYNDROME: std_logic;
    signal RAZ: std_logic;
    signal LD_P2: std_logic;
    signal SYNDROME: std_logic_vector(9 downto 0);
    signal finish: std_logic := '0';
    signal P1: std_logic_vector(4 downto 0);
    signal P2: std_logic_vector(4 downto 0);
begin
    uut: ut_lut port map (
        clk => clk,
        INC_P1 => INC_P1,
        INC_P2 => INC_P2,
        LD_SYNDROME => LD_SYNDROME,
        RAZ => RAZ,
        LD_P2 => output(1),
        SYNDROME => SYNDROME,
        P1_MAX => output(0),
        P2_MAX => output(1),
        ERR1 => ERR1,
        ERR2 => ERR2,
        P1 => P1,
        P2 => P2
    );

    stim_proc: process
    begin
        RAZ <= '1';
        LD_P2 <= '1';
        wait for 105 ns;
        RAZ <= '0';
        LD_P2 <= '0';
        SYNDROME <= "0000000001";
        LD_SYNDROME <= '1';
        assert ERR1 = '0';
        wait for 40 ns;
        assert SYNDROME = "0000000001";
        assert unsigned(P1) = 0;
        assert unsigned(P2) = 1;
        assert ERR1 = '1';
        INC_P1 <= '1';
        INC_P2 <= '1';
        wait for 40 ns;
        LD_SYNDROME <= '0';
        assert unsigned(P1) = 1;
        assert unsigned(P2) = 2;
        wait for 40 ns;
        assert unsigned(P1) = 2;
        SYNDROME <= "0000011000";
        LD_SYNDROME <= '1';
        wait for 40 ns;
        INC_P1 <= '0';
        INC_P2 <= '0';
        assert ERR1 = '0';
        assert ERR2 = '1';
        wait for 40 ns;
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

