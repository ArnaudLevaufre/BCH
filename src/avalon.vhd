library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.FIFO;

entity avalon is
    port(
        clk: in std_logic;
        reset: in std_logic;

        addr: in std_logic_vector(1 downto 0);
        r, w: in std_logic;
        D_in: in std_logic_vector(31 downto 0);
        D_out: out std_logic_vector(31 downto 0);
        FifoOut: out std_logic_vector(31 downto 0);

        ask_irq: in std_logic;
        words: out unsigned(1 downto 0);
        decode, irq_n: out std_logic;

        corr_out: in std_logic_vector(31 downto 0);
        corr_out_ld: in std_logic;

        initFifo: in std_logic
    );
end avalon;

architecture arch_avalon of avalon is
    signal in_decode, in_irqEn: std_logic;
    signal in_irq, in_empty, in_full: std_logic;
    signal in_words: unsigned(1 downto 0);
    signal FifoIn, in_FifoOut: std_logic_vector(31 downto 0);
    signal WrFifo, RdFifo: std_logic;
begin
    in_fifo: entity FIFO generic map(DATA_WIDTH => 32, FIFO_SIZE => 2) port map (
        clk => clk,
        initFifo => initFifo,
        WrFifo => WrFifo,
        RdFifo => RdFifo,
	    DataIn => FifoIn,
	    DataOut => in_FifoOut,
	    FifoEmpty => in_empty,
        FifoFull => in_full
    );

    process(reset, clk)
    begin
        if reset = '1' then
            in_words <= "00";
            in_decode <= '0';
            in_irqen <= '0';
            in_irq <= '1';
        elsif rising_edge(clk) then
            if r = '1' then
                if unsigned(addr) = 0 then
                    in_irq <= '1';
                end if;
            elsif w = '1' then
                if unsigned(addr) = 1 then
                    in_decode <= D_in(0);
                    in_irqEn <= D_in(1);
                elsif unsigned(addr) = 2 then
                    in_words <= in_words + 1;
                end if;
            end if;

            if ask_irq = '1' then
                in_decode <= '0';
                in_words <= "00";
                in_irq <= '0';
            end if;
        end if;
    end process;

    WrFifo <= '1' when ((unsigned(addr) = 2) and (w = '1')) or corr_out_ld = '1' else '0';
    RdFifo <= '1' when ((unsigned(addr) = 2) and (r = '1')) or corr_out_ld = '1' else '0';
    words <= in_words;
    decode <= in_decode;
    FifoIn <= corr_out when corr_out_ld = '1' else D_in;
    FifoOut <= in_FifoOut;
    irq_n <= in_irq when in_irqEn = '1' else '1';
    D_out <= (0 => in_irq, 1 => in_empty, 2 => in_full, others => '0') when r = '1' and unsigned(addr) = 0 else
             (0 => in_decode, 1 => in_irqEn, others => '0') when r = '1' and unsigned(addr) = 1 else
              in_FifoOut when unsigned(addr) = 2 and r = '1' else (others => '0');
end arch_avalon;

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.avalon;

entity avalon_test is
end avalon_test;

architecture arch_avalon_test of avalon_test is
    signal clk: std_logic;
    signal addr: std_logic_vector(1 downto 0) := (others => '0');
    signal r, w: std_logic;
    signal D_in, D_out: std_logic_vector(31 downto 0);
    signal ask_irq, decode: std_logic;
    signal words: unsigned(1 downto 0);
    signal finish: std_logic;
    signal reset: std_logic;
    signal FifoOut: std_logic_vector(31 downto 0);
    signal corr_out: std_logic_vector(31 downto 0);
    signal initfifo, corr_out_ld: std_logic;
begin
    in_avalon: entity avalon port map(
        clk => clk,
        addr => addr,
        reset => reset,
        r => r,
        w => w,
        D_in => D_in,
        D_out => D_out,
        ask_irq => ask_irq,
        words => words,
        decode => decode,
        FifoOut => FifoOut,
        corr_out => corr_out,
        corr_out_ld => corr_out_ld,
        initfifo => initfifo
    );
    process
    begin
        -- RAZ
        addr <= (others => '0');
        w <= '0';
        reset <= '1';
        ask_irq <= '0';
        r <= '0';
        corr_out_ld <= '0';
        corr_out <= (others => '0');
        D_in <= (others => '0');
        finish <= '0';
        initfifo <= '1';

        wait for 41 ns;
        reset <= '0';
        initfifo <= '0';

        -- Load 2 messages
        addr <= (1 => '1', others => '0');
        w <= '1';
        D_in <= "01010101010101010101010101010101";
        wait for 40 ns;
        D_in <= "00000000000000000000000000000011";
        w <= '1';
        assert FifoOut = "01010101010101010101010101010101";
        assert words = 1;
        wait for 40 ns;
        w <= '0';
        assert FifoOut = "01010101010101010101010101010101";
        assert words = 2;

        -- Start decoding
        addr <= (0 => '1', others => '0');
        w <= '1';
        wait for 40 ns;
        assert decode = '1';

        -- End of the first decode
        corr_out <= "10000000000000000000000000000011";
        corr_out_ld <= '1';
        wait for 40 ns;
        corr_out_ld <= '0';
        assert FifoOut = "00000000000000000000000000000011";

        -- Second decode
        corr_out <= "11000000000000000000000000000011";
        corr_out_ld <= '1';
        wait for 40 ns;
        corr_out_ld <= '0';
        ask_irq <= '1';
        assert FifoOut = "10000000000000000000000000000011";
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

end arch_avalon_test;
