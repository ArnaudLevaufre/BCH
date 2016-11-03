library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity ut_syndrome is
  port(
    clk: in std_logic;
    clear: in std_logic;
    ld_syn_buff: in std_logic;
    calc: in std_logic;
    data: in std_logic_vector(31 downto 0);
    syndrome: out std_logic_vector (0 to 9) -- change to 9 downto 0 for MSB first
  );
end entity ut_syndrome;

architecture arch_ut_syndrome of ut_syndrome is
  signal internal_syndrome: std_logic_vector (0 to 9); -- change to 9 downto 0 for MSB first
  signal syn_buff: std_logic_vector (31 downto 0);
begin
  process(clk)
    variable tmp: std_logic := '0';
  begin
    if rising_edge(clk) then
        if clear = '1' then
            internal_syndrome <= "0000000000";
        end if;
        if ld_syn_buff = '1' then
            syn_buff <= data;
        end if;
        if calc = '1' then
            tmp := syn_buff(0) xor internal_syndrome(9);
            internal_syndrome(9) <= tmp xor internal_syndrome(8);
            internal_syndrome(8) <= tmp xor internal_syndrome(7);
            internal_syndrome(7) <= internal_syndrome(6);
            internal_syndrome(6) <= tmp xor internal_syndrome(5);
            internal_syndrome(5) <= tmp xor internal_syndrome(4);
            internal_syndrome(4) <= internal_syndrome(3);
            internal_syndrome(3) <= tmp xor internal_syndrome(2);
            internal_syndrome(2) <= internal_syndrome(1);
            internal_syndrome(1) <= internal_syndrome(0);
            internal_syndrome(0) <= tmp;

            syn_buff <= '0' & syn_buff(31 downto 1);
        end if;
    end if;

  end process;

  syndrome <= internal_syndrome;
end architecture arch_ut_syndrome;

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


entity ut_syndrome_test is
end ut_syndrome_test;

architecture behavior of ut_syndrome_test is
	component ut_syndrome is
        port(
            clk: in std_logic;
            clear: in std_logic;
            ld_syn_buff: in std_logic;
            calc: in std_logic;
            data: in std_logic_vector(31 downto 0);
            syndrome: out std_logic_vector (9 downto 0)
        );
	end component;

	signal clk: std_logic;
    signal clear: std_logic;
    signal ld_syn_buff: std_logic;
    signal calc: std_logic;
    signal syndrome: std_logic_vector(9 downto 0);
    signal data: std_logic_vector(31 downto 0);
    signal finish: std_logic;

	begin
		ut_syndrome_instance: ut_syndrome port map (
			clk => clk,
            clear => clear,
            ld_syn_buff => ld_syn_buff,
            calc => calc,
            data => data,
            syndrome => syndrome
		);

		stim_proc: process
		begin
            -- Syndrome decoding
            wait for 10 ns;
            data <= "01000011010110100000101111010101";
            ld_syn_buff <= '1';
			clear <= '1';
            wait for 100 ns;
            clear <= '0';
            ld_syn_buff <= '0';
            calc <= '1';
            wait for 3100 ns;
            calc <= '0';
            assert syndrome = "0000000000";

            wait for 200 ns;

            clear <= '1';
            data <= "01000011000110100000101111000101";
            ld_syn_buff <= '1';
            wait for 100 ns;
            clear <= '0';
            ld_syn_buff <= '0';
            calc <= '1';

            wait for 3100 ns;
            calc <= '0';
            assert syndrome = "1100111001";
            wait for 200 ns;

            data <= "01100011100011100000111001010111";
            ld_syn_buff <= '1';
            clear <= '1';
            wait for 100 ns;
            clear <= '0';
            ld_syn_buff <= '0';
            calc <= '1';
            wait for 3100 ns;
            calc <= '0';
            assert syndrome = "0011011100";
            wait for 200 ns;

            -- Syndrome coding

            data <= "00000000000110100000101111010101";
            ld_syn_buff <= '1';
            clear <= '1';
            wait for 100 ns;
            clear <= '0';
            ld_syn_buff <= '0';
            calc <= '1';
            wait for 2100 ns;
            calc <= '0';

            assert syndrome = "1000011010";

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

