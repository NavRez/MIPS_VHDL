library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

entity cpu is 

port(reset : in std_logic;
	 clk   : in std_logic;
	 rs_out, rt_out, pc_out : out std_logic_vector (3 downto 0);
	 overflow, zero : out std_logic);

end cpu;


architecture masterCPU of cpu is




signal aluo : std_logic_vector(4 downto 0);
signal pc_sel : std_logic_vector(1 downto 0);
signal branch_type : std_logic_vector(1 downto 0);
signal reg_dst : std_logic;
signal reg_write: std_logic;
signal alu_src : std_logic;
signal add_sub : std_logic;
signal logic_func : std_logic_vector(1 downto 0);
signal func :  std_logic_vector(1 downto 0);
signal s1 : std_logic_vector(3 downto 0);
signal s2 : std_logic_vector(3 downto 0);
signal s3 : std_logic_vector(3 downto 0);
signal flowover : std_logic;


--control singals related to datacvache
signal data_write : std_logic;
signal reg_in_src : std_logic;

--signals in datapath used to hook up stuff
--register file signals
signal rs_field,rt_field : std_logic_vector(4 downto 0); -- two source operands
--rs = read_a
--rt = read_b
signal rd_field : std_logic_vector(4 downto 0); --destination register operand
--field from instruction

signal write_address : std_logic_vector(4 downto 0); --output of regfile mux
signal rs,rt,rd : std_logic_vector(31 downto 0); -- two outputs of regfile

--next address signalsd
signal target_address : std_logic_vector(25 downto 0);
signal pc,next_pc : std_logic_vector(31 downto 0);


--alu signals 
signal immediate_field : std_logic_vector(15 downto 0);
signal sign_extended_immediate : std_logic_vector(31 downto 0);
signal alu_mux_out : std_logic_vector(31 downto 0);
signal alu_output : std_logic_vector(31 downto 0);


--data cache output mux signa;ls

signal data_cache_mux_out : std_logic_vector(31 downto 0);
signal data_cache_out : std_logic_vector(31 downto 0);
signal data_in : std_logic_vector(31 downto 0);


--instruction cache output dignal
signal instruction : std_logic_vector(31 downto 0);
signal detruction : std_logic_vector(31 downto 0);

--component declaration



-----------component initializations ------------------

	component ALU is
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
	end component ;


	component regfile is
	port( din : in std_logic_vector(31 downto 0);
		reset : in std_logic;
		clk: in std_logic;
		write : in std_logic;
		read_a : in std_logic_vector(4 downto 0);
		read_b : in std_logic_vector(4 downto 0);
		write_address : in std_logic_vector(4 downto 0);
		out_a : out std_logic_vector(31 downto 0);
		out_b : out std_logic_vector(31 downto 0));

	end component ;

	component next_address is
	port(rt, rs : in std_logic_vector(31 downto 0);
	-- two register inputs
		pc : in std_logic_vector(31 downto 0);
		target_address : in std_logic_vector(25 downto 0);
		branch_type : in std_logic_vector(1 downto 0);
		pc_sel : in std_logic_vector(1 downto 0);
		next_pc : out std_logic_vector(31 downto 0));
	end component;

	component datacache is


		port( din: in std_logic_vector(31 downto 0);
		reset: in std_logic;
		clk: in std_logic;
		data_write : in std_logic;
		address : in std_logic_vector(4 downto 0);
		data_out: out std_logic_vector(31 downto 0));


	end component; 

--	component icache is

	--	port(--pc : in std_logic_vector(31 downto 0);
	--		pc : in std_logic_vector(31 downto 0);
	--	instruction : out std_logic_vector(31 downto 0));

	--end component;

	component sign_extendor is

	port(func : in std_logic_vector(1 downto 0);
		 ext_in : in std_logic_vector(15 downto 0);
		 ext_output: out std_logic_vector (31 downto 0));

	end component;

	component control_unit is
	port (op : in std_logic_vector(5 downto 0);
	  	  fun : in std_logic_vector(5 downto 0);
		 reg_write : out std_logic; 
		 reg_dst : out std_logic; 
		 reg_in_src : out std_logic; 
		 alu_src : out std_logic; 
		 addsub : out std_logic; 
		 data_write : out std_logic;  
		 logic_func : out std_logic_vector(1 downto 0);
		 func : out std_logic_vector(1 downto 0);
		 branch_type : out std_logic_vector(1 downto 0);  
		 pc_sel : out std_logic_vector(1 downto 0));
	end component;


-----------entitty setups --------------------
--for instruction_comp : icache use entity work.icache(I_CACHE);
for data_comp : datacache use entity work.datacache(D_CACHE);
for sign_comp : sign_extendor use entity work.sign_extendor(SIGN_EXTENSION);
for nxt_add_comp : next_address use entity work.next_address(RTL);
for reg_comp : regfile use entity work.regfile(rtlsec);
for alu_comp : ALU use entity work.ALU(rtlfirst);
for control_comp : control_unit use entity work.control_unit(CU);
--for alu_src_comp : alu_src_mux use entity work.alu_src_mux(ALU_SRC);
--for reg_dst_comp : reg_dst_mux use entity work.reg_dst_mux(REG_DST);

begin



	--flowover <= overflow;

	rs_out <= rs(3 downto 0); rt_out <= rt(3 downto 0); pc_out <= pc(3 downto 0);
	--assign regsiter address fields from the bits of the instruction

		  rs_field <= instruction(25 downto 21); rt_field <= instruction(20 downto 16);rd_field <= instruction(15 downto 11);
		  immediate_field <= instruction(15 downto 0);
		  target_address <= instruction(25 downto 0);

	--pc register
	pc_reg: block
		begin 
		process(clk,reset)
			begin
			if reset ='1' then
				pc <= (others => '0');
				data_in <= pc +2;
			elsif clk'event AND clk ='1' then
				pc <= next_pc;
				data_in <= next_pc +2;
			end if;
		end process;
	end block;

	inst_cache:block
		begin
			process(pc)
			variable mem_address : std_logic_vector(4 downto 0);
				begin
					mem_address := pc(4 downto 0); --use only 5 bits for implementation

					case mem_address is
						when "00000" => instruction <= "00100000000000110000000000000000"; --addi r3, r0, 0
						when "00001" => instruction <= "00100000000000010000000000000000"; --addi r1, r0, 0
						when "00010" => instruction <= "00100000000000100000000000000101"; -- addi r2,r0,5
						when "00011" => instruction <= "00000000001000100000100000100000"; --add r1, r1, r2
						when "00100" => instruction <= "00100000010000101111111111111111"; --addi r2, r2, -2
						when "00101" => instruction <= "00010000010000110000000000000001"; --beq r2, r3, 1
						when "00110" => instruction <= "00001000000000000000000000000011"; --jump 3
						when "00111" => instruction <= "10101100000000010000000000000000"; -- sw r1, 0(r0)
						when "01000" => instruction <= "10001100000001000000000000000000"; -- lw r4, 0(r0) 
						when "01001" => instruction <= "00110000100001000000000000001010"; -- andi r4,r4, 0x000A
						when "01010" => instruction <= "00110100100001000000000000000001"; -- ori r4,r4, 0x0001
						when "01011" => instruction <= "00111000100001000000000000001011"; -- xori r4,r4, 0xB
						when "01100" => instruction <= "00111000100001000000000000000000"; -- xori r4,r4, 0x0000; 
						when others => instruction <= "00000000000000000000000000000000";
					end case;
			end process;
	end block;

	reg_mux: block
		begin
		process(reg_dst,rt_field,rd_field)
			begin

				if reg_dst ='0' then
					write_address <= rt_field;
				else
					write_address <= rd_field;
				end if;
		end process;
	end block;

--	sign_extend: block
	--	begin
	--	process(immediate_field,func)
	--		begin

				sign_comp : sign_extendor port map(func=>func,ext_in=>immediate_field,ext_output=>sign_extended_immediate);

	--	end process;

	--end block;
		reg_comp : regfile port map(din=>sign_extended_immediate,reset=>reset,clk=>clk,write=>reg_write,read_a=>rs_field,read_b=>rt_field,write_address=>write_address,out_a=>rs,out_b=>rt);
		nxt_add_comp : next_address port map(rt,rs,pc,target_address,branch_type,pc_sel,next_pc);


	alu_mux_block : block
		begin
		process(alu_src,rt,sign_extended_immediate)
			begin
			if alu_src = '0' then
				alu_mux_out <= rt;
			else
				alu_mux_out <= sign_extended_immediate;
			end if;

		end process;

	end block;


	reg_mux_block : block
		begin
		process(reg_in_src,alu_output,data_cache_out)
			begin
			if reg_in_src = '0' then
				data_cache_mux_out <= data_cache_out;
			else
				data_cache_mux_out <= alu_output;
			end if;

		end process;

	end block;

  process(pc)
		variable  mem_address : std_logic_vector(4 downto 0);
		begin
			mem_address := pc(4 downto 0);

			case mem_address is
						when "00000" => instruction <= "00100000000000110000000000000000"; --addi r3, r0, 0
						when "00001" => instruction <= "00100000000000010000000000000000"; --addi r1, r0, 0
						when "00010" => instruction <= "00100000000000100000000000000101"; --addi r1, r0, 5
						when "00011" => instruction <= "00000000001000100000100000100000"; --add r1, r1, r2
						when "00100" => instruction <= "00100000010000101111111111111111"; --addi r2, r2, -1
						when "00101" => instruction <= "00010000010000110000000000000001"; --beq r2, r3, 1
						when "00110" => instruction <= "00001000000000000000000000000011"; --jump 3
						when "00111" => instruction <= "10101100000000010000000000000000"; -- sw r1, 0(r0)
						when "01000" => instruction <= "10001100000001000000000000000000"; -- lw r4, 0(r0) 
						when "01001" => instruction <= "00110000100001000000000000001010"; -- andi r4,r4, 0x000A
						when "01010" => instruction <= "00110100100001000000000000000001"; -- ori r4,r4, 0x0001
						when "01011" => instruction <= "00111000100001000000000000001011"; -- xori r4,r4, 0xB
						when "01100" => instruction <= "00111000100001000000000000000000"; -- xori r4,r4, 0x0000; 
						when others => instruction <= "00000000000000000000000000000000";
			end case;
	end process;

	--reg_dst_comp : reg_dst_mux port map(reg_dst,rt,rd,data_in);
	--alu_src_comp : alu_src_mux port map(alu_src,rt,sign_extended_immediate,alu_mux_out);

	alu_comp : ALU port map(x=>rt,y=>alu_mux_out,add_sub=>add_sub,logic_func=>logic_func,func=>func,theoutput=>alu_output,overflow=>overflow,zero=>zero);


	aluo <= alu_output(4 downto 0);
	data_comp : datacache port map(din=>sign_extended_immediate,reset=>reset,clk=>clk,data_write=>data_write,address=>aluo,data_out=>data_cache_out);
	

--	instruction_comp : icache port map(pc=>pc,instruction=>instruction);


	control_comp : control_unit port map(op => instruction(31 downto 26),fun => instruction(5 downto 0),reg_write => reg_write,reg_dst => reg_dst,reg_in_src=>reg_in_src,alu_src=>alu_src,addsub=>add_sub,data_write=>data_write,logic_func=>logic_func,func=>func,branch_type=>branch_type,pc_sel=>pc_sel);

end masterCPU;