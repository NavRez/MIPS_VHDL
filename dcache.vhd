library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

entity datacache is


	port( din: in std_logic_vector(31 downto 0);
	reset: in std_logic;
	clk: in std_logic;
	data_write : in std_logic;
	address : in std_logic_vector(4 downto 0);
	data_out: out std_logic_vector(31 downto 0));


end datacache; 




architecture D_CACHE of datacache is

type data_array is array(0 to 31) of std_logic_vector(31 downto 0);
signal data : data_array;
begin
--write data
process(clk,reset,data_write,data)
 	begin

	if reset = '1' then

		for i in 0 to 31 loop

			data(i) <= "00000000000000000000000000000000";
		end loop;
		


 	elsif clk'event and clk = '1' then
		if data_write = '1' then

			data(conv_integer(address)) <= din;

		end if;
	end if;
	--reset reg_file
	--On_the_clk -> write to REGfile
	--on the clock rising edge
end process;


--read data
	process(address,data)
		begin
			data_out <= data(conv_integer(address));

	end process;



end D_CACHE; -- 