library IEEE;
library work;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.uc_syndrome;
use work.ut_syndrome;

entity syndrome is
  port(
    clk: in std_logic;
    reset: in std_logic;
    start_syn: in std_logic;
    data_in: in std_logic_vector(31 downto 0);
    end_syn: out std_logic;
    syndrome: out std_logic_vector(0 to 9)
  );
end entity syndrome;

architecture arch_syndrome of syndrome is
    signal clear: std_logic;
    signal ld_syn_buff: std_logic;
    signal calc: std_logic;
begin

    ut: entity ut_syndrome port map (
        clk => clk,
        clear => clear,
        ld_syn_buff => ld_syn_buff,
        calc => calc,
        data => data_in,
        syndrome => syndrome
    );

    uc: entity uc_syndrome port map(
        clk => clk,
        reset => reset,
        start_syn => start_syn,
        end_syn => end_syn,
        calc_syn => calc,
        ld_syn_buff => ld_syn_buff,
        clear_syn => clear
    );
end architecture arch_syndrome;


library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


entity syndrome_test is
end syndrome_test;

architecture behavior of syndrome_test is
	component syndrome is
        port(
            clk: in std_logic;
            reset: in std_logic;
            start_syn: in std_logic;
            end_syn: out std_logic;
            data_in: in std_logic_vector(31 downto 0);
            syndrome: out std_logic_vector(0 to 9)
        );
	end component;

	signal clk: std_logic;
    signal reset: std_logic;
    signal start_syn: std_logic;
    signal end_syn: std_logic;
    signal clear_syn: std_logic;
    signal syndrome_val: std_logic_vector(0 to 9);
    signal data_in: std_logic_vector(31 downto 0);

    signal finish: std_logic;

	begin
		syndrome_instance: syndrome port map (
            clk => clk,
            reset => reset,
            start_syn => start_syn,
            end_syn => end_syn,
            data_in => data_in,
            syndrome => syndrome_val
		);

		stim_proc: process
		begin

            wait for 10 ns;
            reset <= '1';
            wait for 200 ns;
            reset <= '0';
            wait for 100 ns;

            data_in <= "01000011010110100000101111010101";
            start_syn <= '1';
            wait for 100 ns;
            data_in <= "00000000000000000000000000000000";
            start_syn <= '0';
            wait until rising_edge(end_syn);
            assert syndrome_val = "0000000000";
            assert end_syn = '1';
            wait for 110 ns;
            assert end_syn = '0';
            assert syndrome_val = "0000000000";

            wait for 500 ns;

            data_in <= "01000011000110100000101111000101";
            start_syn <= '1';
            wait for 100 ns;
            start_syn <= '0';
            wait until rising_edge(end_syn);
            assert syndrome_val = "1100111001";
            assert end_syn = '1';
            wait for 110 ns;
            assert end_syn = '0';
            assert syndrome_val = "1100111001";

            wait for 500 ns;

            data_in <= "01100011100011100000111001010111";
            start_syn <= '1';
            wait for 100 ns;
            start_syn <= '0';
            wait until rising_edge(end_syn);
            assert syndrome_val = "0011011100";
            assert end_syn = '1';
            wait for 110 ns;
            assert end_syn = '0';
            assert syndrome_val = "0011011100";

            wait for 500 ns;

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

