library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.all;

entity bch is
    port(
        clk: in std_logic;
        reset_n: in std_logic;
        r, w: in std_logic;
        D_in: in std_logic_vector(31 downto 0);
        D_out: out std_logic_vector(31 downto 0);
        addr: in std_logic_vector(1 downto 0);
        irq_n: out std_logic
    );
end bch;

architecture arch_bch of bch is
    signal ask_irq, decode, raz_err: std_logic;
    signal start_syndrome, start_lut, start_corr: std_logic;
    signal end_syndrome, end_lut, end_corr: std_logic;
    signal words: unsigned(1 downto 0);
    signal corr_out, FifoOut: std_logic_vector(31 downto 0);
    signal in_syndrome: std_logic_vector(9 downto 0);
    signal clear, ld_syn_buf, calc: std_logic;
    signal P1: std_logic_vector(4 downto 0) := (others => '0');
    signal P2: std_logic_vector(4 downto 0) := (others => '0');
    signal ERR: std_logic_vector(1 downto 0);
    signal initFifo: std_logic;
    signal reset: std_logic;
begin
    reset <= '1' when reset_n = '0' else '0';
    comp_avalon: entity avalon port map(
        clk => clk,
        reset => reset,

        r => r,
        w => w,
        D_in => D_in,
        D_out => D_out,
        addr => addr,

        corr_out_ld => end_corr,
        corr_out => corr_out,
        ask_irq => ask_irq,
        decode => decode,
        words => words,
        FifoOut => FifoOut,
        initFifo => reset,
        irq_n => irq_n
    );

    comp_uc_master: entity uc_master port map(
        clk => clk,
        reset => reset,

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
        reset => reset,

        start_syn => start_syndrome,
        end_syn => end_syndrome,

        data_in => FifoOut,
        syndrome => in_syndrome
    );

    comp_lut: entity lut port map(
        clk => clk,
        reset => reset,

        start_lut => start_lut,
        end_lut => end_lut,

        syndrome => in_syndrome,
        raz_err => raz_err,
        P1 => P1,
        P2 => P2,
        ERR => ERR
    );

    comp_corr: entity corr port map(
        clk => clk,
        reset => reset,

        start_corr => start_corr,
        end_corr => end_corr,

        P1 => P1,
        P2 => P2,
        Err => ERR,
        D_out => FifoOut,
        D_CORR_OUT => corr_out
    );

end arch_bch;


library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.bch;

entity bch_test is
end bch_test;

architecture arch_bch_test of bch_test is
    signal finish, irq_n: std_logic;
    signal clk: std_logic;
    signal reset_n: std_logic;
    signal r, w: std_logic;
    signal D_in: std_logic_vector(31 downto 0) := (others => '0');
    signal D_out: std_logic_vector(31 downto 0);
    signal addr: std_logic_vector(1 downto 0) := (others => '0');
begin
    in_bch: entity bch port map(
        clk => clk,
        reset_n => reset_n,
        r => r,
        w => w,
        D_in => D_in,
        D_out => D_out,
        addr => addr,
        irq_n => irq_n
    );

    process begin
        r <= '0';
        w <= '0';
        reset_n <= '0';
        wait for 41 ns;
        reset_n <= '1';

        r <= '1';
        addr <= (1 => '0', others => '0');
        wait for 40 ns;
        r <= '0';

        addr <= (1 => '1', others => '0');
        w <= '1';
        D_in <= "01100011100011100010111001010110"; -- > 2 errors
        wait for 40 ns;
        D_in <= "01100011100011100000111001010111"; -- 2 errors
        wait for 40 ns;
        D_in <= "01100011100011100000110001010111"; -- 1 error
        wait for 40 ns;
        D_in <= "01100011100011100001110001010111"; -- 0 error
        wait for 40 ns;
        addr <= (0 => '1', others => '0');
        D_in <= (0 => '1', 1 => '1', others => '0');
        wait for 40 ns;
        w <= '0';
        wait until irq_n = '0';
        wait for 400 ns;
        r <= '1';
        addr <= (1 => '1', others => '0');
        wait for 1 ns;
        assert D_out = X"030E2E56";
        wait for 40 ns;
        assert D_out = X"020E1C57";
        wait for 40 ns;
        assert D_out = X"010E1C57";
        wait for 40 ns;
        assert D_out = X"000E1C57";
        wait for 40 ns;
        addr <= (others => '0');
        wait for 40 ns;
        assert irq_n = '1';

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
end arch_bch_test;
