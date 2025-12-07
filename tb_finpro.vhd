library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use std.textio.all;

entity TB_war_encryption is
end entity;

architecture tb of TB_war_encryption is

    component war_encryption
        port (
            CLK        : in  std_logic;
            RST        : in  std_logic;
            enable     : in  std_logic;
            read_flag  : in  std_logic;
            write_flag : in  std_logic;
            Pswd       : in std_logic_vector(6 downto 0);
            MachID     : in std_logic_vector(6 downto 0);
            UserBits   : in std_logic_vector(15 downto 0);

            BBit0  : out std_logic; BBit1  : out std_logic;
            BBit2  : out std_logic; BBit3  : out std_logic;
            BBit4  : out std_logic; BBit5  : out std_logic;
            BBit6  : out std_logic; BBit7  : out std_logic;
            BBit8  : out std_logic; BBit9  : out std_logic;
            BBit10 : out std_logic; BBit11 : out std_logic;
            BBit12 : out std_logic; BBit13 : out std_logic;
            BBit14 : out std_logic; BBit15 : out std_logic
        );
    end component;

    signal CLK, RST, enable, read_flag, write_flag : std_logic := '0';
    signal Pswd   : std_logic_vector(6 downto 0) := (others => '0');
    signal MachID : std_logic_vector(6 downto 0) := (others => '0');
    signal UserBits : std_logic_vector(15 downto 0) := (others => '0');

    signal BBit0,BBit1,BBit2,BBit3,BBit4,BBit5,BBit6,BBit7 : std_logic;
    signal BBit8,BBit9,BBit10,BBit11,BBit12,BBit13,BBit14,BBit15 : std_logic;

  
    type KeyArray is array(0 to 15) of std_logic_vector(15 downto 0);
    signal TB_KeyStore : KeyArray := (others => (others => '0'));
    signal KeyCount : integer := 0;

begin

    DUT: war_encryption
        port map(
            CLK => CLK, RST => RST, enable => enable,
            read_flag => read_flag, write_flag => write_flag,
            Pswd => Pswd, MachID => MachID, UserBits => UserBits,
            BBit0 => BBit0, BBit1 => BBit1, BBit2 => BBit2, BBit3 => BBit3,
            BBit4 => BBit4, BBit5 => BBit5, BBit6 => BBit6, BBit7 => BBit7,
            BBit8 => BBit8, BBit9 => BBit9, BBit10 => BBit10, BBit11 => BBit11,
            BBit12 => BBit12, BBit13 => BBit13, BBit14 => BBit14, BBit15 => BBit15
        );

    CLK_PROCESS : process
    begin
        CLK <= '0'; wait for 10 ns;
        CLK <= '1'; wait for 10 ns;
    end process;
    FILE_READ_PROCESS : process
        file F : text open read_mode is "write_log.txt";
        variable L : line;
        variable raw_line : string(1 to 200);
        variable len : natural := 0;
        variable key_bin : string(1 to 16) := (others => '0');
        variable keyCount_var : integer := 0;
        variable p : integer;
        variable k : integer;
    begin
        keyCount_var := 0;

        while not endfile(F) loop
                readline(F, L);
                
                read(L, raw_line);

            
                len := 0;
                for p in raw_line'range loop
                    if raw_line(p) /= ' ' then
                        len := p;
                    end if;
                end loop;

            if len >= 20 then
                for p in 1 to integer(len) - 4 loop
                    if raw_line(p to p+3) = "KEY=" then
                        if p + 4 + 15 <= integer(len) then
                            for k in 1 to 16 loop
                                key_bin(k) := raw_line(p + 4 + (k-1));
                            end loop;

                            for k in 1 to 16 loop
                                if key_bin(k) = '1' then
                                    TB_KeyStore(keyCount_var)(16-k) <= '1';
                                else
                                    TB_KeyStore(keyCount_var)(16-k) <= '0';
                                end if;
                            end loop;

                            keyCount_var := keyCount_var + 1;
                        end if;
                        exit;
                    end if;
                end loop;
            end if;
        end loop;

        wait;
    end process;

    STIM : process
        variable wait_t : integer := 0;
        variable i : integer := 0;
        variable tmp : std_logic_vector(15 downto 0);
        
        file F2 : text;
        variable L2 : line;
        variable raw_line2 : string(1 to 200);
        variable len2 : natural := 0;
        variable key_bin2 : string(1 to 16) := (others => '0');
        variable keyCount_var2 : integer := 0;
        variable p2 : integer;
        variable k2 : integer;
      
        file Fw : text;
        variable Lw : line;
        variable op_strw : string(1 to 5);
        variable key_strw : string(1 to 16);
        variable widx : integer := 0;
    begin
       
        RST <= '1'; wait for 50 ns;
        RST <= '0'; enable <= '1';

        file_open(Fw, "write_log.txt", WRITE_MODE);
        
        
        op_strw := "10100"; key_strw := "0000000000000001"; write(Lw, string'("WRITE_EVENT ")); write(Lw, 0); write(Lw, string'(" | OPCODE=")); write(Lw, op_strw); write(Lw, string'(" | KEY=")); write(Lw, key_strw); writeline(Fw, Lw);
        op_strw := "10001"; key_strw := "0000000000000010"; write(Lw, string'("WRITE_EVENT ")); write(Lw, 1); write(Lw, string'(" | OPCODE=")); write(Lw, op_strw); write(Lw, string'(" | KEY=")); write(Lw, key_strw); writeline(Fw, Lw);
        op_strw := "01100"; key_strw := "0000000000000100"; write(Lw, string'("WRITE_EVENT ")); write(Lw, 2); write(Lw, string'(" | OPCODE=")); write(Lw, op_strw); write(Lw, string'(" | KEY=")); write(Lw, key_strw); writeline(Fw, Lw);
        op_strw := "01010"; key_strw := "0000000000001000"; write(Lw, string'("WRITE_EVENT ")); write(Lw, 3); write(Lw, string'(" | OPCODE=")); write(Lw, op_strw); write(Lw, string'(" | KEY=")); write(Lw, key_strw); writeline(Fw, Lw);
        op_strw := "01000"; key_strw := "0000000000010000"; write(Lw, string'("WRITE_EVENT ")); write(Lw, 4); write(Lw, string'(" | OPCODE=")); write(Lw, op_strw); write(Lw, string'(" | KEY=")); write(Lw, key_strw); writeline(Fw, Lw);
        op_strw := "01011"; key_strw := "0000000000100000"; write(Lw, string'("WRITE_EVENT ")); write(Lw, 5); write(Lw, string'(" | OPCODE=")); write(Lw, op_strw); write(Lw, string'(" | KEY=")); write(Lw, key_strw); writeline(Fw, Lw);
        op_strw := "11111"; key_strw := "0000000001000000"; write(Lw, string'("WRITE_EVENT ")); write(Lw, 6); write(Lw, string'(" | OPCODE=")); write(Lw, op_strw); write(Lw, string'(" | KEY=")); write(Lw, key_strw); writeline(Fw, Lw);
        file_close(Fw);

        Pswd <= "0001111";   
        MachID <= "0011001"; 
        UserBits <= x"0004"; 
        enable <= '1';
      
        wait for 200 ns;
        read_flag <= '0';

        
        tmp := (others => '0'); tmp(4 downto 0) := "10100"; UserBits <= tmp;
        write_flag <= '1'; wait for 40 ns; write_flag <= '0'; wait for 20 ns;
        
        tmp := (others => '0'); tmp(4 downto 0) := "10001"; UserBits <= tmp;
        write_flag <= '1'; wait for 40 ns; write_flag <= '0'; wait for 20 ns;
        
        tmp := (others => '0'); tmp(4 downto 0) := "01100"; UserBits <= tmp;
        write_flag <= '1'; wait for 40 ns; write_flag <= '0'; wait for 20 ns;
        
        tmp := (others => '0'); tmp(4 downto 0) := "01010"; UserBits <= tmp;
        write_flag <= '1'; wait for 40 ns; write_flag <= '0'; wait for 20 ns;
        
        tmp := (others => '0'); tmp(4 downto 0) := "01000"; UserBits <= tmp;
        write_flag <= '1'; wait for 40 ns; write_flag <= '0'; wait for 20 ns;
      
        tmp := (others => '0'); tmp(4 downto 0) := "01011"; UserBits <= tmp;
        write_flag <= '1'; wait for 40 ns; write_flag <= '0'; wait for 20 ns;
        
        tmp := (others => '0'); tmp(4 downto 0) := "11111"; UserBits <= tmp;
        write_flag <= '1'; wait for 40 ns; write_flag <= '0'; wait for 20 ns;

    
        wait for 300 ns;

        keyCount_var2 := 7;
        TB_KeyStore(0) <= "0000000000000001";
        TB_KeyStore(1) <= "0000000000000010";
        TB_KeyStore(2) <= "0000000000000100";
        TB_KeyStore(3) <= "0000000000001000";
        TB_KeyStore(4) <= "0000000000010000";
        TB_KeyStore(5) <= "0000000000100000";
        TB_KeyStore(6) <= "0000000001000000";
        KeyCount <= keyCount_var2;


        enable <= '1';
        read_flag <= '1'; Pswd <= "0001111";
        wait for 50 ns;

        for i in 0 to KeyCount-1 loop
            UserBits <= TB_KeyStore(i);
            report "Feeding keystream index=" & integer'image(i);
            wait for 500 ns;
        end loop;

        Pswd <= "0000000";
        wait for 100 ns;
        report "Post-write (direct) populated, total keys=" & integer'image(KeyCount);
        report "FINISHED TESTBENCH RUN";

        wait;
    end process;

end architecture;







