library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_signed.all;

entity reg_dst_mux is

port(reg_dst : in std_logic;
	 RT : in std_logic_vector(4 downto 0);
	 RD : in std_logic_vector(4 downto 0);
	 reg_out : out std_logic_vector(4 downto 0));

end reg_dst_mux;

architecture REG_DST of reg_dst_mux is

begin
	process (reg_dst,RT,RD)

		begin

			if reg_dst = '0' then

				reg_out <= RT;

			else
			
				reg_out <= RD;

			end if;


	end process;



end REG_DST;