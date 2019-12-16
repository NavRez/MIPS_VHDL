library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_signed.all;
use IEEE.numeric_std.all;


entity next_address is
port(rt, rs : in std_logic_vector(31 downto 0);
-- two register inputs
	pc : in std_logic_vector(31 downto 0);
	target_address : in std_logic_vector(25 downto 0);
	branch_type : in std_logic_vector(1 downto 0);
	pc_sel : in std_logic_vector(1 downto 0);
	next_pc : out std_logic_vector(31 downto 0));
end next_address ;

architecture RTL of next_address is

	signal some_pc : std_logic_vector(31 downto 0);
	signal extendor : std_logic_vector(31 downto 0);
	signal adjust : std_logic_vector(31 downto 0);
	signal upone : std_logic_vector(31 downto 0);
	signal downone : std_logic_vector(31 downto 0);
	signal lower : std_logic_vector(15 downto 0);
	signal comp : std_logic_vector(25 downto 0);
	signal newcomp : std_logic_vector(31 downto 0);
	signal extra: std_logic_vector(31 downto 0);
	signal check: std_logic_vector(31 downto 0);
	signal fixup: std_logic_vector(31 downto 0);
	begin


	comp <= NOT target_address;
	lower <= target_address(15 downto 0);	
	upone <= "11111111111111110000000000000000";
	downone <= "00000000000000000000000000000000";

	process(branch_type,pc,target_address,rs,rt,comp,upone,downone,adjust,newcomp,extendor,fixup,lower)
		begin
		upone <= "11111111111111110000000000000000";
		downone <= "00000000000000000000000000000000";
		some_pc <= pc;
		adjust <= "00000000000000000000000000000000";
		if branch_type = "00" then
		--biter <= "00";
			some_pc <= pc + "00000000000000000000000000000001";
		elsif branch_type = "01" then

			--comp <= NOT target_address;
			--newcomp <= comp + "00000000000000000000000001";

			if rs = rt then
				if target_address(15) = '0' then
					fixup <= "0000000000000000" & lower;
					adjust <= downone + fixup;
					newcomp <= adjust;--NOT(adjust) + "00000000000000000000000000000001";
					extendor <= newcomp + pc;
					some_pc <= extendor + "00000000000000000000000000000001";
				else
					fixup <= "0000000000000000" & lower;
					adjust <= upone + fixup;
					newcomp <= adjust;--NOT(adjust) + "00000000000000000000000000000001";
					extendor <= newcomp + pc;
					some_pc <= extendor + "00000000000000000000000000000001";
				end if;
			else
			check <= some_pc;
			some_pc <= pc + "00000000000000000000000000000001";

			end if;

		elsif branch_type = "10" then

			--	comp <= NOT target_address;
			--	newcomp <= comp + "00000000000000000000000001";

			if rs /= rt then
				some_pc <= pc + "00000000000000000000000000000001";
			else
			
				if target_address(15) = '0' then
					fixup <= "0000000000000000" & lower;
					adjust <= downone + fixup;
					newcomp <= adjust;--NOT(adjust) + "00000000000000000000000000000001";
					extendor <= newcomp + pc;
					some_pc <= extendor + "00000000000000000000000000000001";
				else
					fixup <= "0000000000000000" & lower;
					adjust <= upone + fixup;
					newcomp <= adjust;--NOT(adjust) + "00000000000000000000000000000001";
					extendor <= newcomp + pc;
					some_pc <= extendor + "00000000000000000000000000000001";
				end if;
			end if;

		elsif branch_type = "11" then
			
		--	comp <= NOT target_address;
		--	newcomp <= comp + "00000000000000000000000001";

			if rs(31) = '1' then
				if target_address(15) = '0' then
					fixup <= "0000000000000000" & lower;
					adjust <= downone + fixup;
					newcomp <= adjust;--NOT(adjust) + "00000000000000000000000000000001";
					extendor <= newcomp + pc;
					some_pc <= extendor + "00000000000000000000000000000001";
				else
					fixup <= "0000000000000000" & lower;
					adjust <= upone + fixup;
					newcomp <= adjust;--NOT(adjust) + "00000000000000000000000000000001";
					extendor <= newcomp + pc;
					some_pc <= extendor + "00000000000000000000000000000001";
				end if;
			else
			
			some_pc <= pc + "00000000000000000000000000000001";
				
			end if;
		else
			

		end if;
			


	end process;



	process(pc_sel,rs,rt,pc,extra,some_pc,target_address)
		begin
		if pc_sel = "00" then

			extra <= some_pc;
			--extra <= "00000000000000000000000000000000";

		elsif pc_sel = "01" then

			extra <= "000000" & target_address;
--extra <= "00000000000000000000000000000000";

		elsif pc_sel = "10" then

			extra <= rs;
--extra <= "00000000000000000000000000000000";


		else

			extra <= pc;
--extra <= "00000000000000000000000000000000";
					
		end if;		


	end process;


	next_pc <= extra;

end RTL;
