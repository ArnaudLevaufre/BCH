library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity ut_corr is
    port(
	    clk, RAZ, DEC_BUF, LD_BUF, LD_CORR : in std_logic;
        Err : in std_logic_vector(1 downto 0);
        P1, P2 : in std_logic_vector(4 downto 0);
        D_out : in std_logic_vector(31 downto 0);
		D_CORR_OUT : out std_logic_vector(31 downto 0);
        CPT : out std_logic_vector(4 downto 0)
	);
end entity ut_corr;

architecture arch_ut_corr of ut_corr is
    signal cpt_intern: std_logic_vector (4 downto 0) := (others => '0');
    signal comp1Out, comp2Out: std_logic;
    signal mux1Out, mux2Out: std_logic;
    signal muxCorrSel, muxCorrOut: std_logic;
    signal D_mem: std_logic_vector(31 downto 0);
    signal BUFOut: std_logic;
    signal MSG_CORROut: std_logic_vector(20 downto 0);
begin
    process(clk)
      begin
        if rising_edge(clk) then
            if RAZ = '1' then
                cpt_intern <= (others => '0');
                MSG_CORROut <= (others => '0');
            else
                cpt_intern <= std_logic_vector(unsigned(cpt_intern) + 1);
            end if;

            if LD_BUF = '1' then
                D_mem <= D_out;
            elsif DEC_BUF = '1' then
                D_mem <= ('0' & D_mem(31 downto 1));
            end if;

            if LD_CORR = '1' then
                MSG_CORROut <= muxCorrOut & MSG_CORROut(20 downto 1);
            end if;
        end if;
    end process;

    bufOut <= D_mem(0);

    comp1Out <= '1' when (unsigned(P2) - unsigned(cpt_intern)) = 0  else '0';
    comp2Out <= '1' when (unsigned(P1) - unsigned(cpt_intern)) = 0  else '0';

    mux1Out <= comp1Out when Err(1) = '1' and Err(0) = '0' else '0';
    mux2Out <= comp2Out when (Err(1) = '1') or (Err(0) = '1') else '0';

    muxCorrSel <= '1' when (mux1Out='1') or (mux2Out='1') else '0';
    muxCorrOut <= bufOut when muxCorrSel = '0' else (not bufOut);

    D_CORR_OUT <= "000000" & Err(1 downto 0) & "000" & MSG_CORROut;
    CPT <= cpt_intern;
end architecture arch_ut_corr;


entity ut_corr_test is
end ut_corr_test;

architecture arch_ut_corr_test of ut_corr_test is
begin
end arch_ut_corr_test;

