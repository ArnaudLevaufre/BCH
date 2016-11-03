library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.all;

entity bch is
    port(
        clk: in std_logic;
        raz: in std_logic;
        r, w: in std_logic;
        D_in: in std_logic_vector(31 downto 0);
        D_out: out std_logic_vector(31 downto 0);
        addr: in std_logic_vector(63 downto 0) -- TODO: Find out the right size
    );
end bch;

architecture arch_bch of bch is
    signal corr_out_ld, ask_irq, decode, raz_err: std_logic;
    signal start_syndrome, start_lut, start_corr: std_logic;
    signal end_syndrome, end_lut, end_corr: std_logic;
    signal words: unsigned(1 downto 0);
    signal corr_out, FifoOut: std_logic_vector(31 downto 0);
    signal in_syndrome: std_logic_vector(9 downto 0);
    signal clear, ld_syn_buf, calc: std_logic;
    signal P1, P2: std_logic_vector(4 downto 0);
    signal ERR: std_logic_vector(1 downto 0);
begin
    comp_avalon: entity avalon port map(
        clk => clk,
        raz => raz,

        r => r,
        w => w,
        D_in => D_in,
        D_out => D_out,
        addr => addr,

        corr_out_ld => corr_out_ld,
        corr_out => corr_out,
        ask_irq => ask_irq,
        decode => decode,
        words => words,
        FifoOut => FifoOut
    );

    comp_uc_master: entity uc_master port map(
        clk => clk,
        raz => raz,

        decode => decode,
        nb_words => words,
        syndrome => in_syndrome,

        start_syndrome => start_syndrome,
        start_lut => start_lut,
        start_corr => start_corr,
        end_syndrome => end_syndrome,
        end_lut => end_lut,
        end_corr => end_corr,

        ask_irq => ask_irq,
        raz_err => raz_err
    );

    comp_syndrome: entity syndrome port map(
        clk => clk,
        reset => raz,

        start_syn => start_syndrome,
        end_syn => end_syndrome,

        data_in => FifoOut,
        syndrome => in_syndrome
    );

    comp_lut: entity lut port map(
        clk => clk,
        reset => raz,

        start_lut => start_lut,
        end_lut => end_lut,

        syndrome => in_syndrome,
        raz_err => raz_err,
        P1 => P1,
        P2 => P2,
        ERR => ERR
    );

end arch_bch;


library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity bch_test is
end bch_test;

architecture arch_bch_test of bch_test is
begin
end arch_bch_test;
