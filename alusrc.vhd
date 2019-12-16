library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_signed.all;

entity alu_src_mux is

port(alu_src : in std_logic;
	 R_reg : in std_logic_vector(4 downto 0);
	 S_reg : in std_logic_vector(4 downto 0);
	 reg_out : out std_logic_vector(4 downto 0));

end alu_src_mux;

architecture ALU_SRC of alu_src_mux is

begin
	process (alu_src,S_reg,R_reg)

		begin

			if alu_src = '0' then

				reg_out <= R_reg;

			else
			
				reg_out <= S_reg;

			end if;


	end process;



end ALU_SRC;