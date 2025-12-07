
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_textio.all;
use std.textio.all;

use work.pattern_pkg.all;

entity war_encryption is
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
end entity;

architecture rtl of war_encryption is
type t_State is (OFF, HOLD, ACTIVE, UP, PASSIVE, LOCK, SelfDes);
signal current_state : t_State := OFF;
signal NextState     : t_State;

signal timer_cnt : integer := 0;
constant CLK_FREQ : integer := 50_000_000;
constant TIME_30S : integer := CLK_FREQ * 30;
constant TIME_60S : integer := CLK_FREQ * 60;
constant MAX_MSG : integer := 16;

type MsgArray is array(0 to MAX_MSG-1) of std_logic_vector(4 downto 0);
type KeyArray is array(0 to MAX_MSG-1) of std_logic_vector(15 downto 0);

signal MsgStore : MsgArray := (others => (others=>'0'));
signal KeyStore : KeyArray := (others => (others=>'0'));

signal MsgPtr : integer := 0;
signal ReadingIndex : integer := 0;
signal read_auth_ok : std_logic := '0';
signal pattern_step : integer := 0;
signal read_wait_cycles : integer := 0;
signal Wordz : string(1 to 10);
signal lfsr_seed : std_logic_vector(15 downto 0) := "1100001100001100";

function lfsr_next(seed : std_logic_vector(15 downto 0)) return std_logic_vector is
    variable s : std_logic_vector(15 downto 0) := seed;
    variable fb : std_logic;
begin
    fb := s(15) xor s(13) xor s(12) xor s(10);
    s := s(14 downto 0) & fb;
    return s;
end function;
function words_input_decode(
    b0,b1,b2,b3,b4,b5,b6,b7 : std_logic;
    b8,b9,b10,b11,b12,b13,b14,b15 : std_logic
) return string is
    variable concat : std_logic_vector(15 downto 0);
begin
    concat := b0&b1&b2&b3&b4&b5&b6&b7&b8&b9&b10&b11&b12&b13&b14&b15;

    case concat is
        when "0000000000000100" => return "tango     ";
        when "0000000000000110" => return "delta     ";
        when "0000000000000111" => return "alpha     ";
        when "0000000000000101" => return "omega     ";
        when "0000000000001111" => return "gorga     ";
        when "0000000000001101" => return "fahmi     ";
        when others             => return "tidaktau  ";
    end case;
end function;
function RecordMatching(ID : std_logic_vector(6 downto 0); W : string) return boolean is
begin
    if    (ID="0011001" and W="tango     ") then return true;
    elsif (ID="0011010" and W="alpha     ") then return true;
    elsif (ID="0011011" and W="delta     ") then return true;
    elsif (ID="1111000" and W="omega     ") then return true;
    elsif (ID="0101010" and W="gorga     ") then return true;
    elsif (ID="1010100" and W="fahmi     ") then return true;
    else return false;
    end if;
end function;
constant Write_Pwd : std_logic_vector(6 downto 0) := "0001111";
constant Exit_Pwd  : std_logic_vector(6 downto 0) := "0000000";

function Match_UP_Pass(P : std_logic_vector(6 downto 0)) return boolean is
begin return P = Write_Pwd; end;
function Match_Exit_Pass(P : std_logic_vector(6 downto 0)) return boolean is
begin return P = Exit_Pwd; end;
signal BBits_internal : std_logic_vector(15 downto 0);
constant O_A   : std_logic_vector(4 downto 0) := "11001";
constant O_B   : std_logic_vector(4 downto 0) := "11000";
constant O_C   : std_logic_vector(4 downto 0) := "10111";
constant O_D   : std_logic_vector(4 downto 0) := "10110";
constant O_E   : std_logic_vector(4 downto 0) := "10101";
constant O_F   : std_logic_vector(4 downto 0) := "10100";
constant O_G   : std_logic_vector(4 downto 0) := "10011";
constant O_H   : std_logic_vector(4 downto 0) := "10010";
constant O_I   : std_logic_vector(4 downto 0) := "10001";
constant O_J   : std_logic_vector(4 downto 0) := "10000";
constant O_K   : std_logic_vector(4 downto 0) := "01111";
constant O_L   : std_logic_vector(4 downto 0) := "01110";
constant O_M   : std_logic_vector(4 downto 0) := "01101";
constant O_N   : std_logic_vector(4 downto 0) := "01100";
constant O_O   : std_logic_vector(4 downto 0) := "01011";
constant O_P   : std_logic_vector(4 downto 0) := "01010";
constant O_Q   : std_logic_vector(4 downto 0) := "01001";
constant O_R   : std_logic_vector(4 downto 0) := "01000";
constant O_S   : std_logic_vector(4 downto 0) := "00111";
constant O_T   : std_logic_vector(4 downto 0) := "00110";
constant O_U   : std_logic_vector(4 downto 0) := "00101";
constant O_V   : std_logic_vector(4 downto 0) := "00100";
constant O_W   : std_logic_vector(4 downto 0) := "00011";
constant O_X   : std_logic_vector(4 downto 0) := "00010";
constant O_Y   : std_logic_vector(4 downto 0) := "00001";
constant O_Z   : std_logic_vector(4 downto 0) := "00000";
constant O_SPC : std_logic_vector(4 downto 0) := "11111";
function PatternOf(op : std_logic_vector(4 downto 0)) return PatternArray is
begin
    case op is
        when O_A => return A_PATTERN;
        when O_B => return B_PATTERN;
        when O_C => return C_PATTERN;
        when O_D => return D_PATTERN;
        when O_E => return E_PATTERN;
        when O_F => return F_PATTERN;
        when O_G => return G_PATTERN;
        when O_H => return H_PATTERN;
        when O_I => return I_PATTERN;
        when O_J => return J_PATTERN;
        when O_K => return K_PATTERN;
        when O_L => return L_PATTERN;
        when O_M => return M_PATTERN;
        when O_N => return N_PATTERN;
        when O_O => return O_PATTERN;
        when O_P => return P_PATTERN;
        when O_Q => return Q_PATTERN;
        when O_R => return R_PATTERN;
        when O_S => return S_PATTERN;
        when O_T => return T_PATTERN;
        when O_U => return U_PATTERN;
        when O_V => return V_PATTERN;
        when O_W => return W_PATTERN;
        when O_X => return X_PATTERN;
        when O_Y => return Y_PATTERN;
        when O_Z => return Z_PATTERN;
        when others => return ZERO_PATTERN;
    end case;
end function;
function PatternLength(op : std_logic_vector(4 downto 0)) return integer is
begin
    case op is
        when O_A   => return A_PATTERN'length;
        when O_B   => return B_PATTERN'length;
        when O_C   => return C_PATTERN'length;
        when O_D   => return D_PATTERN'length;
        when O_E   => return E_PATTERN'length;
        when O_F   => return F_PATTERN'length;
        when O_G   => return G_PATTERN'length;
        when O_H   => return H_PATTERN'length;
        when O_I   => return I_PATTERN'length;
        when O_J   => return J_PATTERN'length;
        when O_K   => return K_PATTERN'length;
        when O_L   => return L_PATTERN'length;
        when O_M   => return M_PATTERN'length;
        when O_N   => return N_PATTERN'length;
        when O_O   => return O_PATTERN'length;
        when O_P   => return P_PATTERN'length;
        when O_Q   => return Q_PATTERN'length;
        when O_R   => return R_PATTERN'length;
        when O_S   => return S_PATTERN'length;
        when O_T   => return T_PATTERN'length;
        when O_U   => return U_PATTERN'length;
        when O_V   => return V_PATTERN'length;
        when O_W   => return W_PATTERN'length;
        when O_X   => return X_PATTERN'length;
        when O_Y   => return Y_PATTERN'length;
        when O_Z   => return Z_PATTERN'length;
        when O_SPC => return ZERO_PATTERN'length;
        when others => return ZERO_PATTERN'length;
    end case;
end function;

function PatternRow(op : std_logic_vector(4 downto 0); idx : integer)
    return PatternStep is
begin
    case op is
        when O_A =>
            if idx >= A_PATTERN'left and idx <= A_PATTERN'right then
                return A_PATTERN(idx);
            else
                return (others => '0');
            end if;

        when O_B =>
            if idx >= B_PATTERN'left and idx <= B_PATTERN'right then
                return B_PATTERN(idx);
            else
                return (others => '0');
            end if;

        when O_C =>
            if idx >= C_PATTERN'left and idx <= C_PATTERN'right then
                return C_PATTERN(idx);
            else
                return (others => '0');
            end if;

        when O_D =>
            if idx >= D_PATTERN'left and idx <= D_PATTERN'right then
                return D_PATTERN(idx);
            else
                return (others => '0');
            end if;

        when O_E =>
            if idx >= E_PATTERN'left and idx <= E_PATTERN'right then
                return E_PATTERN(idx);
            else
                return (others => '0');
            end if;

        when O_F =>
            if idx >= F_PATTERN'left and idx <= F_PATTERN'right then
                return F_PATTERN(idx);
            else
                return (others => '0');
            end if;

        when O_G =>
            if idx >= G_PATTERN'left and idx <= G_PATTERN'right then
                return G_PATTERN(idx);
            else
                return (others => '0');
            end if;

        when O_H =>
            if idx >= H_PATTERN'left and idx <= H_PATTERN'right then
                return H_PATTERN(idx);
            else
                return (others => '0');
            end if;

        when O_I =>
            if idx >= I_PATTERN'left and idx <= I_PATTERN'right then
                return I_PATTERN(idx);
            else
                return (others => '0');
            end if;

        when O_J =>
            if idx >= J_PATTERN'left and idx <= J_PATTERN'right then
                return J_PATTERN(idx);
            else
                return (others => '0');
            end if;

        when O_K =>
            if idx >= K_PATTERN'left and idx <= K_PATTERN'right then
                return K_PATTERN(idx);
            else
                return (others => '0');
            end if;

        when O_L =>
            if idx >= L_PATTERN'left and idx <= L_PATTERN'right then
                return L_PATTERN(idx);
            else
                return (others => '0');
            end if;

        when O_M =>
            if idx >= M_PATTERN'left and idx <= M_PATTERN'right then
                return M_PATTERN(idx);
            else
                return (others => '0');
            end if;

        when O_N =>
            if idx >= N_PATTERN'left and idx <= N_PATTERN'right then
                return N_PATTERN(idx);
            else
                return (others => '0');
            end if;

        when O_O =>
            if idx >= O_PATTERN'left and idx <= O_PATTERN'right then
                return O_PATTERN(idx);
            else
                return (others => '0');
            end if;

        when O_P =>
            if idx >= P_PATTERN'left and idx <= P_PATTERN'right then
                return P_PATTERN(idx);
            else
                return (others => '0');
            end if;

        when O_Q =>
            if idx >= Q_PATTERN'left and idx <= Q_PATTERN'right then
                return Q_PATTERN(idx);
            else
                return (others => '0');
            end if;

        when O_R =>
            if idx >= R_PATTERN'left and idx <= R_PATTERN'right then
                return R_PATTERN(idx);
            else
                return (others => '0');
            end if;

        when O_S =>
            if idx >= S_PATTERN'left and idx <= S_PATTERN'right then
                return S_PATTERN(idx);
            else
                return (others => '0');
            end if;

        when O_T =>
            if idx >= T_PATTERN'left and idx <= T_PATTERN'right then
                return T_PATTERN(idx);
            else
                return (others => '0');
            end if;

        when O_U =>
            if idx >= U_PATTERN'left and idx <= U_PATTERN'right then
                return U_PATTERN(idx);
            else
                return (others => '0');
            end if;

        when O_V =>
            if idx >= V_PATTERN'left and idx <= V_PATTERN'right then
                return V_PATTERN(idx);
            else
                return (others => '0');
            end if;

        when O_W =>
            if idx >= W_PATTERN'left and idx <= W_PATTERN'right then
                return W_PATTERN(idx);
            else
                return (others => '0');
            end if;

        when O_X =>
            if idx >= X_PATTERN'left and idx <= X_PATTERN'right then
                return X_PATTERN(idx);
            else
                return (others => '0');
            end if;

        when O_Y =>
            if idx >= Y_PATTERN'left and idx <= Y_PATTERN'right then
                return Y_PATTERN(idx);
            else
                return (others => '0');
            end if;

        when O_Z =>
            if idx >= Z_PATTERN'left and idx <= Z_PATTERN'right then
                return Z_PATTERN(idx);
            else
                return (others => '0');
            end if;

        when O_SPC =>
            if idx >= ZERO_PATTERN'left and idx <= ZERO_PATTERN'right then
                return ZERO_PATTERN(idx);
            else
                return (others => '0');
            end if;

        when others =>
            return (others => '0');
    end case;
end function;

function sl_to_char(s : std_logic) return character is
begin
    if s='0' then
        return '0';
    else
        return '1';
    end if;
end function;


file LogFile : text open write_mode is "write_log.txt";

begin
process(CLK)
    variable L : line;
    variable op_str  : string(1 to 5);
    variable key_str : string(1 to 16);
    variable seed : std_logic_vector(15 downto 0);
begin
    if rising_edge(CLK) then

        if RST='1' then
            MsgPtr <= 0;

        elsif write_flag='1' and current_state=UP then
            if MsgPtr < MAX_MSG then

                seed := lfsr_next(lfsr_seed);
                lfsr_seed <= seed;

                MsgStore(MsgPtr) <= UserBits(4 downto 0);
                KeyStore(MsgPtr) <= seed;

                for i in 1 to 5 loop
                    op_str(i) := sl_to_char(UserBits(5-i));
                end loop;

                for i in 1 to 16 loop
                    key_str(i) := sl_to_char(seed(16-i));
                end loop;

                write(L, string'("WRITE_EVENT "));
                write(L, MsgPtr);
                write(L, string'(" | OPCODE="));
                write(L, op_str);
                write(L, string'(" | KEY="));
                write(L, key_str);
                writeline(LogFile, L);

                MsgPtr <= MsgPtr + 1;

            end if;
        end if;
    end if;
end process;

process(CLK)
    variable opdec : std_logic_vector(4 downto 0);
begin
    if rising_edge(CLK) then

        if current_state /= PASSIVE then
            read_auth_ok <= '0';
            ReadingIndex <= 0;
            pattern_step <= 0;
            read_wait_cycles <= 0;

        else
            if read_auth_ok='0' then
                if UserBits = KeyStore(ReadingIndex) then
                    read_auth_ok <= '1';
                    pattern_step <= 0;
                    read_wait_cycles <= 0;
                end if;

            elsif read_auth_ok='1' then

                opdec := MsgStore(ReadingIndex);

                if pattern_step < PatternLength(opdec) then

                    if read_wait_cycles = 0 then
                        BBits_internal <= PatternRow(opdec, pattern_step);
                        pattern_step <= pattern_step + 1;
                        read_wait_cycles <= 3;
                    else
                        read_wait_cycles <= read_wait_cycles - 1;
                    end if;

                else
                    ReadingIndex <= ReadingIndex + 1;
                    read_auth_ok <= '0';
                    pattern_step <= 0;
                end if;

            end if;

        end if;

    end if;
end process;
BBit0  <= BBits_internal(0);
BBit1  <= BBits_internal(1);
BBit2  <= BBits_internal(2);
BBit3  <= BBits_internal(3);
BBit4  <= BBits_internal(4);
BBit5  <= BBits_internal(5);
BBit6  <= BBits_internal(6);
BBit7  <= BBits_internal(7);
BBit8  <= BBits_internal(8);
BBit9  <= BBits_internal(9);
BBit10 <= BBits_internal(10);
BBit11 <= BBits_internal(11);
BBit12 <= BBits_internal(12);
BBit13 <= BBits_internal(13);
BBit14 <= BBits_internal(14);
BBit15 <= BBits_internal(15);


process(CLK)
begin
    if rising_edge(CLK) then
        Wordz <= words_input_decode(
            UserBits(0),UserBits(1),UserBits(2),UserBits(3),
            UserBits(4),UserBits(5),UserBits(6),UserBits(7),
            UserBits(8),UserBits(9),UserBits(10),UserBits(11),
            UserBits(12),UserBits(13),UserBits(14),UserBits(15)
        );
    end if;
end process;
process(CLK,RST)
begin
    if RST='1' then
        current_state <= OFF;
        timer_cnt <= 0;
    elsif rising_edge(CLK) then
        if current_state=OFF or current_state=HOLD or current_state=LOCK then
            timer_cnt <= timer_cnt + 1;
        else
            timer_cnt <= 0;
        end if;

        current_state <= NextState;
    end if;
end process;
process(current_state, enable, MachID, Wordz, Pswd, timer_cnt, write_flag, read_flag)
begin
    NextState <= current_state;

    case current_state is

        when OFF =>
            if enable='1' then
                if RecordMatching(MachID,Wordz) and Match_UP_Pass(Pswd) then
                    NextState <= ACTIVE;
                else
                    NextState <= HOLD;
                end if;
            end if;
            if timer_cnt>=TIME_60S then
                NextState <= HOLD;
            end if;

        when HOLD =>
            if enable='1' then
                if RecordMatching(MachID,Wordz) and Match_UP_Pass(Pswd) then
                    NextState <= ACTIVE;
                else
                    NextState <= HOLD;
                end if;
            end if;
            if timer_cnt>=TIME_30S then
                NextState <= LOCK;
            end if;

        when ACTIVE =>
            if write_flag='1' then
                if Match_UP_Pass(Pswd) then
                    NextState <= UP;
                end if;
            elsif read_flag='1' then
                NextState <= PASSIVE;
            end if;

        when UP =>
            if Match_Exit_Pass(Pswd) then
                NextState <= ACTIVE;
            end if;

        when PASSIVE =>
            if Match_Exit_Pass(Pswd) then
                NextState <= ACTIVE;
            end if;
            if read_flag='0' then
                NextState <= ACTIVE;
            end if;

        when LOCK =>
            if timer_cnt>=TIME_60S then
                if RecordMatching(MachID,Wordz) and Match_UP_Pass(Pswd) then
                    NextState <= ACTIVE;
                else
                    NextState <= SelfDes;
                end if;
            end if;

        when SelfDes =>
            NextState <= SelfDes;

    end case;
end process;

end architecture;





