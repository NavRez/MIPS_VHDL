library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

entity sign_extendor is

port(func : in std_logic_vector(1 downto 0);
	 ext_in : in std_logic_vector(15 downto 0);
	 ext_output: out std_logic_vector (31 downto 0));

end sign_extendor;

architecture SIGN_EXTENSION of sign_extendor is

	signal lsb : std_logic_vector(15 downto 0);
	signal ext_out : std_logic_vector(31 downto 0);
	begin

		lsb <= ext_in(15 downto 0);
		
		process(ext_in,lsb,ext_out,func)
			begin
				if func = "00" then

					ext_out <= "0000000000000000" & lsb;

					elsif func = "11" then

					ext_out <= lsb & "0000000000000000";

				else
					
					if(lsb(15) ='0') then

						ext_out <= "0000000000000000" & lsb;
					else

						ext_out <= "1111111111111111" & lsb;

					end if;
							
				end if;
		end process;


ext_output <= ext_out;


end SIGN_EXTENSION;
