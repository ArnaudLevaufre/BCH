library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


entity FIFO is
    generic(
        DATA_WIDTH : integer := 8;
        FIFO_SIZE : integer := 3
    );

	port(
        clk, initFifo, WrFifo, RdFifo : in std_logic;
	    DataIn : in std_logic_vector(DATA_WIDTH-1 downto 0);
	    DataOut : out std_logic_vector(DATA_WIDTH-1 downto 0);
	    FifoLevel : out std_logic_vector(FIFO_SIZE downto 0);
	    FifoEmpty, FifoFull : out std_logic
    );
end entity FIFO;


architecture rtl of FIFO is
	signal adrFifo : integer range 0 to 2**FIFO_SIZE;
	type memory is array(0 to 2**FIFO_SIZE-1) of std_logic_vector(DATA_WIDTH-1 downto 0);
	signal Fifo : memory;
begin
    process(clk)
        variable FifoAccess : std_logic_vector(1 downto 0);
    begin
	    if (rising_edge(clk)) then
	        if initFifo = '1' then
	            adrFifo <= 0;
	        else
	            FifoAccess := WrFifo&RdFifo;
	            case FifoAccess is
	                when "10" =>
                        if adrFifo < 2**FIFO_SIZE then
                            Fifo(adrFifo) <= DataIn;
                            adrFifo <= adrFifo+1;
                        end if;
	                when "01" =>
	                    if adrFifo > 0 then
	                        for i in 1 to 2**FIFO_SIZE-1 loop
	                            Fifo(i-1) <= Fifo(i);
	                        end loop;
	                        adrFifo <= adrFifo-1;
	                    end if  ;
	                when "11" =>
	                    for i in 1 to 2**FIFO_SIZE-1 loop
	                        Fifo(i-1) <= Fifo(i);
	                    end loop;
	                    Fifo(adrFifo-1) <= DataIn;
	                when others => NULL;
	            end case;
	        end if;
	    end if;
    end process;

    FifoEmpty <=  '1' when adrFifo = 0 else '0';
    FifoFull <= '1' when adrFifo = 2**FIFO_SIZE else '0';
    DataOut <= Fifo(0);
    FifoLevel <= std_logic_vector(TO_UNSIGNED(adrFifo, FIFO_SIZE+1));
end architecture rtl;

-- Dummy fifo test for the makefile to be happy
entity fifo_test is
end fifo_test;

architecture arch_fifo_test of fifo_test is
begin
end arch_fifo_test;
