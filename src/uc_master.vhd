library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity uc_master is
    port(
        clk: in std_logic;
        decode, reset: in std_logic;
        syndrome: in std_logic_vector(9 downto 0);
        nb_words: in unsigned(1 downto 0);
        start_syndrome, start_lut, start_corr: out std_logic;
        end_syndrome, end_lut, end_corr: in std_logic;
        ask_irq, raz_err, corr_out_ld: out std_logic;
        initFifo: out std_logic
    );
end uc_master;

architecture arch_uc_master of uc_master is
    type state is (REPOS, SYN, LUT, CORR);
    signal current_state, next_state: state;
    signal nb_processed: std_logic_vector(1 downto 0);
begin
    process(clk, reset)
    begin
        if reset = '1' then
            current_state <= REPOS;
            initFifo <= '1';
        elsif rising_edge(clk) then
            initFifo <= '0';
            current_state <= next_state;
        end if;
    end process;

    process(clk, current_state, decode, end_syndrome, end_lut, end_corr, syndrome, nb_words, nb_processed)
    begin
        raz_err <= '0';
        start_syndrome <= '0';
        start_lut <= '0';
        start_corr <= '0';
        ask_irq <= '0';
        corr_out_ld <= '0';

        next_state <= current_state;

        if rising_edge(clk) then
            case current_state is
                when REPOS =>
                    if decode = '1' then
                        nb_processed <= "00";
                    end if;
                when CORR =>
                    if end_corr = '1' then
                        nb_processed <= std_logic_vector(unsigned(nb_processed) + 1);
                    end if;
                when SYN =>
                when LUT =>
            end case;
        end if;
        case current_state is
            when REPOS =>
                if decode = '1' then
                    next_state <= SYN;
                    start_syndrome <= '1';
                end if;
            when SYN =>
                start_syndrome <= '1';
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
                    if to_integer(unsigned(nb_processed)) = to_integer(nb_words - 1) then
                        ask_irq <= '1';
                        next_state <= REPOS;
                    else
                        next_state <= SYN;
                    end if;
                    corr_out_ld <= '1';
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
    signal decode, reset: std_logic;
    signal start_syndrome, end_syndrome: std_logic;
    signal start_lut, end_lut: std_logic;
    signal start_corr, end_corr: std_logic;
    signal syndrome: std_logic_vector(9 downto 0);
    signal nb_words: unsigned(1 downto 0);
    signal ask_irq, raz_err: std_logic;
begin
    in_uc_master: entity uc_master port map(
        clk => clk,
        reset => reset,
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
        reset <= '1';
        decode <= '0';
        nb_words <= "10";
        end_syndrome <= '0';
        syndrome <= "0000000000";
        end_lut <= '0';
        end_corr <= '0';
        wait for 41 ns;
        reset <= '0';

        decode <= '1';
        wait for 40 ns;
        decode <= '0';
        assert start_syndrome = '1';
        wait for 40 ns;

        end_syndrome <= '1';
        wait for 41 ns;
        assert start_corr <= '1'; -- Since syndrome == 0, skip lut
        end_syndrome <= '0';
        wait for 40 ns;
        assert start_syndrome = '0';
        end_corr <= '1';
        wait for 40 ns;
        end_corr <= '0';
        syndrome <= "0000000001";
        wait for 80 ns;
        assert start_syndrome = '1';
        end_syndrome <= '1';
        wait for 20 ns;
        assert start_lut = '1';
        wait for 20 ns;
        end_syndrome <= '0';
        wait for 40 ns;
        end_lut <= '1';
        wait for 20 ns;
        assert start_corr = '1';
        wait for 20 ns;
        end_lut <= '0';
        wait for 40 ns;
        end_corr <= '1';
        wait for 20 ns;
        assert ask_irq = '1';
        wait for 20 ns;
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
