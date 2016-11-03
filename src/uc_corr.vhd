library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity uc_corr is
    port(
        clk, reset, start_corr : in std_logic;
        RAZ, DEC_BUF, LD_BUF, LD_CORR, end_corr: out std_logic;
        CPT : in std_logic_vector(4 downto 0)
    );
end entity uc_corr;

architecture arch_uc_corr of uc_corr is
    type me_states is (Repos, Decalage);
    signal  etat_cr, etat_sv : me_states ;
begin
    process(clk, reset)
        begin
          if reset='1' then etat_cr <= Repos;
          elsif rising_edge(clk) then etat_cr <= etat_sv;
          end if;
    end process;

    process(etat_cr, start_corr, CPT)
    begin
        etat_sv <= etat_cr; RAZ <= '0';
        LD_BUF <= '0'; LD_CORR <= '0';
        DEC_BUF <= '0'; end_corr <= '0';

        case etat_cr is
            when Repos =>
                if start_corr = '1' then
                    etat_sv <= Decalage;
                    RAZ <= '1';
                    LD_BUF <= '1';
                end if;
            when Decalage =>
                if unsigned(CPT) = 21 then
                    etat_sv <= Repos;
                    end_corr <= '1';
                else
                    DEC_BUF <= '1';
                    LD_CORR <= '1';
                end if;
        end case;
    end process;
end architecture arch_uc_corr;

entity uc_corr_test is
end uc_corr_test;

architecture arch_uc_corr_test of uc_corr_test is
begin
end arch_uc_corr_test;
