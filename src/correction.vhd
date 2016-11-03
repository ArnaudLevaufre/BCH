library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity CORRECTOR is 
  generic ( DATA_WIDTH : integer := 32;
            INFO_WIDTH : integer := 21);
	port(clk, RAZ, DEC_BUF, LD_BUF, LD_CORR : in std_logic;
	     Err : in std_logic_vector(1 downto 0);
	     P1,P2 : in std_logic_vector(4 downto 0);
	     D_out : in std_logic_vector(DATA_WIDTH-1 downto 0);
	     D_CORR_OUT : out std_logic_vector(DATA_WIDTH-1 downto 0);
	     CPT : out std_logic_vector(4 downto 0));
end entity CORRECTOR;

architecture arch_CORRECTOR of CORRECTOR is
  
	signal cpt_intern : std_logic_vector (4 downto 0); 
	
	signal comp1Out,comp2Out : std_logic;
	
	signal mux1Out,mux2Out : std_logic;
	
	signal muxCorrSel,muxCorrOut : std_logic;
	
	signal D_mem : std_logic_vector(DATA_WIDTH-1 downto 0);
	
	signal BUFOut : std_logic;
	
	signal MSG_CORROut : std_logic_vector(20 downto 0);
	
	
begin
process(clk)
  begin
    if rising_edge(clk) then
        if RAZ = '1' then 
          cpt_intern <= (others => '0');
          MSG_CORROut <= (others => '0');
        else  cpt_intern <= std_logic_vector(unsigned(cpt_intern) + 1);
          
        end if;
        

        if LD_BUF = '1' then D_mem <= D_out;
        elsif DEC_BUF = '1' then D_mem <= ('0' & D_mem(DATA_WIDTH-1 downto 1));
          
        end if;
          
        if LD_CORR = '1' then MSG_CORROut <= muxCorrOut & MSG_CORROut(INFO_WIDTH-1 downto 1);
        
        end if;
    end if;
    

end process;

  bufOut <= D_mem(0);
  
  comp1Out <= '1' when (unsigned(P1) - unsigned(cpt_intern)) = 0 else '0';
	comp2Out <= '1' when (unsigned(P2) - unsigned(cpt_intern)) = 0 else '0';
	
	mux1Out <= comp1Out when Err(1) = '1' else '0';
	mux2Out <= comp2Out when (Err(1) = '1') or (Err(0) = '1') else '0';
	
	muxCorrSel <= '1' when (mux1Out='1') or (mux2Out='1') else '0';
	muxCorrOut <= bufOut when muxCorrSel = '0' else (not bufOut);
	
  D_CORR_OUT <= "000000" & Err(1 downto 0) & "000" & MSG_CORROut;
	
	CPT <= cpt_intern;
	
end architecture arch_CORRECTOR;


---------------------------------------------------------------------
---------------------------------------------------------------------
---------------------------------------------------------------------


library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity ME_CORRECTOR is 
  generic ( DATA_WIDTH : integer := 32;
            INFO_WIDTH : integer := 21);
            
	port(clk, reset, start_corr : in std_logic;
	     RAZ, DEC_BUF, LD_BUF, LD_CORR, end_corr: out std_logic;
	     CPT : in std_logic_vector(4 downto 0));
	     
end entity ME_CORRECTOR;

architecture arch_ME_CORRECTOR of ME_CORRECTOR is

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
			      

end architecture arch_ME_CORRECTOR;


---------------------------------------------------------------------
---------------------------------------------------------------------
---------------------------------------------------------------------


library IEEE;
use IEEE.std_logic_1164.all;
use work.all;

entity global_corrector is
  generic ( DATA_WIDTH : integer := 32;
            INFO_WIDTH : integer := 21);
            
	port(clk, reset, start_corr : in std_logic;
	     Err : in std_logic_vector(1 downto 0);
	     P1,P2 : in std_logic_vector(4 downto 0);
	     D_out : in std_logic_vector(DATA_WIDTH-1 downto 0);
	     D_CORR_OUT : out std_logic_vector(DATA_WIDTH-1 downto 0));
	     
end global_corrector;


architecture arch_global_corrector of global_corrector is

signal RAZ, DEC_BUF, LD_BUF, LD_CORR, end_corr : std_logic;
signal CPT :  std_logic_vector(4 downto 0);

begin

me_corr:		entity ME_CORRECTOR port map(
			start_corr 		=> start_corr,
			reset  => reset,
			RAZ => RAZ,
			DEC_BUF => DEC_BUF,
			LD_BUF => LD_BUF,
			LD_CORR => LD_CORR,
			clk		=> clk,
			end_corr		=> end_corr,
			CPT => CPT
			);

corr:		entity CORRECTOR port map(
			clk		=> clk,
			RAZ		=> RAZ,
			CPT		=> CPT,
			Err 		=> Err,
			P1 		=> P1,
			P2 		=> P2,
			DEC_BUF => DEC_BUF,
			LD_BUF => LD_BUF,
			LD_CORR => LD_CORR,
			D_out 		=> D_out,
			D_CORR_OUT 		=> D_CORR_OUT
			
			);

end arch_global_corrector;
