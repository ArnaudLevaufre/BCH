library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity uc_master is
    port(
        clk: in std_logic;
        decode, raz: in std_logic;
        syndrome: in std_logic_vector(9 downto 0);
        nb_words: in unsigned(1 downto 0);
        start_syndrome, start_lut, start_corr: out std_logic;
        end_syndrome, end_lut, end_corr: in std_logic;
        ask_irq, raz_err, r_fifo, w_fifo: out std_logic
    );
end uc_master;

architecture arch_uc_master of uc_master is
    type state is (REPOS, SYN, LUT, CORR);
    signal current_state, next_state: state;
    signal nb_processed: std_logic_vector(1 downto 0);
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if raz = '1' then
                current_state <= REPOS;
            else
                current_state <= next_state;
            end if;
        end if;
    end process;

    process(current_state, decode, end_syndrome, end_lut, end_corr)
    begin
        raz_err <= '0';
        start_syndrome <= '0';
        start_lut <= '0';
        start_corr <= '0';
        ask_irq <= '0';
        w_fifo <= '0';
        r_fifo <= '0';

        next_state <= current_state;
        case current_state is
            when REPOS =>
                if decode = '1' then
                    nb_processed <= "00";
                    next_state <= SYN;
                    start_syndrome <= '1';
                end if;
            when SYN =>
                if end_syndrome = '1' then
                    if syndrome = "0000000000" then
                        next_state <= CORR;
                        start_corr <= '1';
                        raz_err <= '1';
                    else
                        next_state <= LUT;
                        start_lut <= '1';
                    end if;
                end if;
            when LUT =>
                if end_lut = '1' then
                    next_state <= CORR;
                    start_corr <= '1';
                end if;
            when CORR =>
                if end_corr = '1' then
                    nb_processed <= std_logic_vector(unsigned(nb_processed) + 1);
                    if to_integer(unsigned(nb_processed)) = to_integer(nb_words - 1) then
                        ask_irq <= '1';
                        next_state <= REPOS;
                    else
                        next_state <= SYN;
                        start_syndrome <= '1';
                    end if;
                    r_fifo <= '1';
                    w_fifo <= '1';
                end if;
        end case;
    end process;
end arch_uc_master;

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.uc_master;

entity uc_master_test is
end uc_master_test;

architecture arch_uc_master_test of uc_master_test is
    signal clk: std_logic;
    signal finish: std_logic;
    signal decode, raz: std_logic;
    signal start_syndrome, end_syndrome: std_logic;
    signal start_lut, end_lut: std_logic;
    signal start_corr, end_corr: std_logic;
    signal syndrome: std_logic_vector(9 downto 0);
    signal nb_words: unsigned(1 downto 0);
    signal ask_irq, raz_err: std_logic;
begin
    in_uc_master: entity uc_master port map(
        clk => clk,
        raz => raz,
        decode => decode,
        syndrome => syndrome,
        start_syndrome => start_syndrome,
        end_syndrome => end_syndrome,
        start_lut => start_lut,
        end_lut => end_lut,
        start_corr => start_corr,
        end_corr => end_corr,
        nb_words => nb_words,
        raz_err => raz_err,
        ask_irq => ask_irq
    );
    process
    begin
        raz <= '1';
        decode <= '0';
        nb_words <= "10";
        end_syndrome <= '0';
        syndrome <= "0000000000";
        end_lut <= '0';
        end_corr <= '0';
        wait for 41 ns;
        raz <= '0';

        decode <= '1';
        wait for 39 ns;
        decode <= '0';
        assert start_syndrome = '1';
        wait for 41 ns;
        assert start_syndrome = '0';

        end_syndrome <= '1';
        wait for 39 ns;
        assert start_corr <= '1'; -- Since syndrome == 0, skip lut
        end_syndrome <= '0';
        wait for 40 ns;
        end_corr <= '1';
        wait for 40 ns;
        end_corr <= '0';
        assert start_syndrome = '1';
        syndrome <= "0000000001";
        wait for 80 ns;
        end_syndrome <= '1';
        wait for 40 ns;
        end_syndrome <= '0';
        assert start_lut = '1';
        wait for 40 ns;
        end_lut <= '1';
        wait for 40 ns;
        end_lut <= '0';
        assert start_corr = '1';
        wait for 40 ns;
        end_corr <= '1';
        wait for 40 ns;
        assert ask_irq = '1';
        end_corr <= '0';
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

end arch_uc_master_test;
