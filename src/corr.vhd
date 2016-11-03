library IEEE;
use IEEE.std_logic_1164.all;
use work.all;

entity corr is
    port(
        clk, reset, start_corr : in std_logic;
        Err : in std_logic_vector(1 downto 0);
        P1,P2 : in std_logic_vector(4 downto 0);
        D_out : in std_logic_vector(31 downto 0);
        D_CORR_OUT : out std_logic_vector(31 downto 0)
    );
end corr;

architecture arch_corr of corr is
    signal RAZ, DEC_BUF, LD_BUF, LD_CORR, end_corr : std_logic;
    signal CPT :  std_logic_vector(4 downto 0);
begin
    me_corr: entity uc_corr port map(
        start_corr => start_corr,
        reset => reset,
        RAZ => RAZ,
        DEC_BUF => DEC_BUF,
        LD_BUF => LD_BUF,
        LD_CORR => LD_CORR,
        clk => clk,
        end_corr => end_corr,
        CPT => CPT
    );
    corr: entity ut_corr port map(
        clk => clk,
        RAZ => RAZ,
        CPT => CPT,
        Err => Err,
        P1 => P1,
        P2 => P2,
        DEC_BUF => DEC_BUF,
        LD_BUF => LD_BUF,
        LD_CORR => LD_CORR,
        D_out => D_out,
        D_CORR_OUT => D_CORR_OUT
    );
end arch_corr;


entity corr_test is
end corr_test;

architecture arch_corr_test of corr_test is
begin
end arch_corr_test;

