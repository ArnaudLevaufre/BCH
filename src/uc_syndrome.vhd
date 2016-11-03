library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity uc_syndrome is
  port(
    clk: in std_logic;
    reset: in std_logic;
    start_syn: in std_logic;
    end_syn: out std_logic;
    calc_syn: out std_logic;
    ld_syn_buff: out std_logic;
    clear_syn: out std_logic
  );
end entity uc_syndrome;

architecture arch_uc_syndrome of uc_syndrome is
  type state is (IDLE, DEC_SYN);
  signal current_state, next_state: state;
  signal count: std_logic_vector(4 downto 0);
  signal dec: std_logic;
  signal dec_flag: std_logic;
  signal dec_init: std_logic;
begin
    process(clk, reset)
    begin
        if reset = '1' then
            current_state <= IDLE;
        elsif rising_edge(clk) then
            current_state <= next_state;
        end if;
    end process;

    process(current_state, start_syn, dec_flag)
    begin
        next_state <= current_state;
        clear_syn <= '0';
        ld_syn_buff <= '0';
        end_syn <= '0';
        dec <= '0';
        dec_init <= '0';
        calc_syn <= '0';

        case current_state is
            when IDLE =>
                if start_syn = '1' then
                    ld_syn_buff <= '1';
                    clear_syn <= '1';
                    next_state <= DEC_SYN;
                    dec_init <= '1';
                end if;
            when DEC_SYN =>
                if dec_flag = '1' then
                    end_syn <= '1';
                    next_state <= IDLE;
                else
                    dec <= '1';
                    calc_syn <= '1';
                end if;
        end case;
    end process;

    process(clk)
    begin
        if rising_edge(clk) then
            dec_flag <= '0';
            if dec_init = '1' then
                count <= "11111";
            elsif dec = '1' then
                if count = "00001" then
                    dec_flag <= '1';
                else
                    dec_flag <= '0';
                end if;
                count <= std_logic_vector(unsigned(count) - 1);
            end if;
        end if;
    end process;

end architecture arch_uc_syndrome;


library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


entity uc_syndrome_test is
end uc_syndrome_test;

architecture behavior of uc_syndrome_test is
	component uc_syndrome is
        port(
            clk: in std_logic;
            reset: in std_logic;
            start_syn: in std_logic;
            end_syn: out std_logic;
            calc_syn: out std_logic;
            ld_syn_buff: out std_logic;
            clear_syn: out std_logic
        );
	end component;

	signal clk: std_logic;
    signal reset: std_logic;
    signal start_syn: std_logic;
    signal end_syn: std_logic;
    signal ld_syn_buff: std_logic;
    signal clear_syn: std_logic;
    signal finish: std_logic;
    signal calc_syn: std_logic;

	begin
		uc_syndrome_instance: uc_syndrome port map (
            clk => clk,
            reset => reset,
            start_syn => start_syn,
            calc_syn => calc_syn,
            end_syn => end_syn,
            ld_syn_buff => ld_syn_buff,
            clear_syn => clear_syn
		);

		stim_proc: process
		begin
            -- Syndrome decoding
            start_syn <= '0';

            wait for 10 ns;
			reset <= '1';
            wait for 200 ns;
            reset <= '0';
            wait for 100 ns;

            start_syn <= '1';
            wait until rising_edge(clk);
            assert ld_syn_buff = '1';
            assert clear_syn = '1';
            assert end_syn = '0';
            wait for 10 ns;

            start_syn <= '0';
            assert ld_syn_buff = '0';
            assert clear_syn = '0';
            assert end_syn = '0';
            assert calc_syn = '1';

            wait for 3100 ns;
            assert ld_syn_buff = '0';
            assert clear_syn = '0';
            assert end_syn = '1';
            assert calc_syn = '0';

            wait for 100 ns;
            assert ld_syn_buff = '0';
            assert clear_syn = '0';
            assert end_syn = '0';
            wait for 200 ns;

            finish <= '1';
			wait;
		end process;

		process
		begin
			if finish = '1' then
				wait;
			else
				clk <= '1';
				wait for 50 ns;
				clk <= '0';
				wait for 50 ns;
			end if;
		end process;

end architecture;

