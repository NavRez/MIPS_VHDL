library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

entity regfile is
port( din : in std_logic_vector(31 downto 0);
	reset : in std_logic;
	clk: in std_logic;
	write : in std_logic;
	read_a : in std_logic_vector(4 downto 0);
	read_b : in std_logic_vector(4 downto 0);
	write_address : in std_logic_vector(4 downto 0);
	out_a : out std_logic_vector(31 downto 0);
	out_b : out std_logic_vector(31 downto 0));

end regfile ;

architecture rtlsec of regfile is

type reg_array is array(0 to 31) of std_logic_vector(31 downto 0);

signal REGfile : reg_array;
signal zero : std_logic_vector(31 downto 0);

begin

zero <= "00000000000000000000000000000000";



--writting

process(clk,reset)
 	begin

	if reset = '1' then

		for i in 0 to 31 loop

			REGfile(i) <= "00000000000000000000000000000000";
		end loop;
		


 	elsif clk'event and clk = '1' then
		if write = '1' then


			REGfile(conv_integer(write_address)) <= din;


		end if;
	end if;
	--reset reg_file
	--On_the_clk -> write to REGfile
	--on the clock rising edge
end process;

--outputting
process(read_a,read_b,REGfile)
	begin
		out_a <= REGfile(conv_integer(read_a));
		out_b <= REGfile(conv_integer(read_b));

	--put data to output ports
end process;


end rtlsec;

