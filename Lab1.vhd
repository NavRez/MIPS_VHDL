library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_signed.all;


entity ALU is
	port(x, y : in std_logic_vector(31 downto 0);
-- two input operands
	add_sub : in std_logic ;
-- 0 = add , 1 = sub
	logic_func : in std_logic_vector(1 downto 0 ) ;
-- 00 = AND, 01 = OR , 10 = XOR , 11 = NOR
	func : in std_logic_vector(1 downto 0 ) ;
-- 00 = lui, 01 = setless , 10 = arith , 11 = logic
	theoutput : out std_logic_vector(31 downto 0) ;
	overflow : out std_logic ;
	zero : out std_logic);
end ALU ;

architecture rtlfirst of ALU is

	signal add_sub_out : std_logic_vector(31 downto 0);
	signal logic_unit_out,output1 : std_logic_vector(31 downto 0);
	signal lui : std_logic_vector(31 downto 0);
	signal overflow1,zero1 : std_logic;
begin
	process(x,y,add_sub)
		begin

			if add_sub = '0' then
				add_sub_out <= x + y;
			else
				add_sub_out <= x - y;
			end if;
	end process;

--logic unit
	process(x,y,logic_func)
		begin

		case logic_func is
			when "00" => logic_unit_out <= x AND y;
			when "01" => logic_unit_out <= x OR y;
			when "10" => logic_unit_out <= x XOR y;
			when others => logic_unit_out <= x NOR y;
		end case;

		--use switch case
	end process;	

--MUX
	process(add_sub_out,x,y,logic_unit_out)
		begin

		case func is
			when "00" => output1 <= y;
			when "01" => output1 <= "0000000000000000000000000000000" & add_sub_out(31);
			when "10" => output1 <= add_sub_out;
			when others => output1 <= logic_unit_out;
		end case;

		--01 =>  add_sub_out(31) --slt -- if (x <y) make output = 1

		--use switch case


	end process;


--zero clock
	process(add_sub_out)
		begin

		if add_sub_out = "00000000000000000000000000000000" then
			zero1 <= '1';
		else
			zero1 <= '0';
		end if;

		--use switch case
	end process;	

	--overflow
	process(x,y,add_sub,add_sub_out)
		begin

		lui <= (NOT y) + "00000000000000000000000000000001";		
		
		if add_sub = '0' then
			if x(31) = '1' and y(31) = '1' then

				if add_sub_out(31) = '0' then
				overflow1 <= '1';
				else
				overflow1 <= '0';
				end if;

			elsif x(31) = '0' and y(31) = '0' then

				if add_sub_out(31) = '1' then
				overflow1 <= '1';
				else
				overflow1 <= '0';
				end if;

			else
				overflow1 <= '0';

			end if;
		else

			if x(31) = '1' and lui(31) = '1' then

				if add_sub_out(31) = '0' then
				overflow1 <= '1';
				else
				overflow1 <= '0';
				end if;

			elsif x(31) = '0' and lui(31) = '0' then

				if add_sub_out(31) = '1' then
				overflow1 <= '1';
				else
				overflow1 <= '0';
				end if;

			else
				overflow1 <= '0';

			end if;
		end if;


		--use switch case



	end process;	

		overflow <= NOT overflow1;
		zero <= NOT zero1;
		theoutput <= NOT output1;

end rtlfirst;
