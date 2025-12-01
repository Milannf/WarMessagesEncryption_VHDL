library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_textio.all;

entity war_encryption is
    port (
        Portbutton  : in  std_logic;
        CLK         : in  std_logic;
        enable      : in  std_logic;
        RST         : in  std_logic;
        read_flag   : in  std_logic;
        write_flag  : in  std_logic;
        SelfDes     : in  std_logic;

        Pswd        : in  std_logic_vector(6 downto 0);
        MachID      : in  std_logic_vector(6 downto 0);

        BBit0  : in std_logic;
        BBit1  : in std_logic;
        BBit2  : in std_logic;
        BBit3  : in std_logic;
        BBit4  : in std_logic;
        BBit5  : in std_logic;
        BBit6  : in std_logic;
        BBit7  : in std_logic;
        BBit8  : in std_logic;
        BBit9  : in std_logic;
        BBit10 : in std_logic;
        BBit11 : in std_logic;
        BBit12 : in std_logic;
        BBit13 : in std_logic;
        BBit14 : in std_logic;
        BBit15 : in std_logic;

        TempBit0  : out std_logic;
        TempBit1  : out std_logic;
        TempBit2  : out std_logic;
        TempBit3  : out std_logic;
        TempBit4  : out std_logic;
        TempBit5  : out std_logic;
        TempBit6  : out std_logic;
        TempBit7  : out std_logic;
        TempBit8  : out std_logic;
        TempBit9  : out std_logic;
        TempBit10 : out std_logic;
        TempBit11 : out std_logic;
        TempBit12 : out std_logic;
        TempBit13 : out std_logic;
        TempBit14 : out std_logic;
        TempBit15 : out std_logic
    );
end entity war_encryption;
architecture rtl of war_encryption is
-------------------------------------------------------
    --PRE READ 
    --Misal ada 6 machine tersebar di seluruh indonesia , nah ntar setiap machine itu punya kode unik (kek semacam ID gitu) yang bakal jadi tanda pengenal.  Nah sebelumnya output nya itu kan berbentuk huruf 
    --Setiap huruf itu ada procedure nya trus setiap pemanggilannya ada semacam kodenya gitu 
    --Misal seorang pengguna ini pengen membaca pesan yang dia print dari salah satu machine di machine yang lain maka ID machine yang nyetak harus dikenali sama machine yang lain tersebut(kalo nggak , ya gagal masuk ke proses berikutnya)
    --Trus IDnya itu merupakan  unique words gitu misal "tango" , "delta" untuk sebutan setiap machine (tugas pengguna memasukkan bit 1 dan 0 trus di decode pake decoder dalam suatu machine , nah kata kata itu bakal ada di array(sama kek waktu CS TESTBENCH) ,kalo IP nya ga ada di array maka gabisa masuk. Nantinya juga bisa ditambahin suatu unique number juga setiap machine (berbeda tiap machine) jadi kalo memang "tango" yang pengen akses , maka harus dari "tango" itulah yang akses jadi autentikasinya double
    --Nah abis itu , pengguna akan masukin bit password harus match. Nah disini kita bisa implementasiin FSM, jadi ada tiga kali percobaan dan apabila gagal pertama kedua bakal di hold trus ke 3 bakal di lock 
    --Ada fitur self destruction bisa dari permintaan pengguna untuk menghancurkan suatu pesan ataupun bisa imbas dari beberapa kali percobaan gagal kek di mission impossible akwokwkwk
    --Nah , kalo misal berhasil masuk , maka mode lansung menjadi reader only, kalo mau nulis pesan , dia harus masukin password lagi kek password line console di Jarkom, jadi bisa memilih sebagai reader atau writer
    --Nah pesannya apabila ada yang menulis , maka di print ke txt, yang diprint itu kode setiap prosedur secara sekuensial, bukan kolom waveform nya
--------------------------------------------------------
    type t_State is (OFF, HOLD, ACTIVE, UP, PASSIVE, LOCK, SelfDes, RESET);
    signal current_tate : t_State := OFF;
    signal NextState    : t_State;
    signal en           : std_logic;
    signal dummy        : std_logic;
    signal Actbutton    : std_logic;

    signal MatchID   : std_logic_vector(6 downto 0);

    signal MatchPass : std_logic_vector(6 downto 0);

    signal BBit0  : std_logic;
    signal BBit1  : std_logic;
    signal BBit2  : std_logic;
    signal BBit3  : std_logic;
    signal BBit4  : std_logic;
    signal BBit5  : std_logic;
    signal BBit6  : std_logic;
    signal BBit7  : std_logic;
    signal BBit8  : std_logic;
    signal BBit9  : std_logic;
    signal BBit10 : std_logic;
    signal BBit11 : std_logic;
    signal BBit12 : std_logic;
    signal BBit13 : std_logic;
    signal BBit14 : std_logic;
    signal BBit15 : std_logic;

procedure A_sign is
    begin
        wait for rising_edge(CLK);
        BBit0 <= '0'; BBit1 <= '0'; BBit2 <= '0'; BBit3 <= '0';
        BBit4 <= '0'; BBit5 <= '0'; BBit6 <= '0'; BBit7 <= '0';
        BBit8 <= '0'; BBit9 <= '0'; BBit10 <= '0'; BBit11 <= '0';
        BBit12 <= '1'; BBit13 <= '1'; BBit14 <= '1'; BBit15 <= '1';

        wait for rising_edge(CLK);
        BBit0 <= '0'; BBit1 <= '0'; BBit2 <= '0'; BBit3 <= '0';
        BBit4 <= '0'; BBit5 <= '0'; BBit6 <= '0'; BBit7 <= '0';
        BBit8 <= '0'; BBit9 <= '0'; BBit10 <= '0'; BBit11 <= '0';
        BBit12 <= '1'; BBit13 <= '1'; BBit14 <= '1'; BBit15 <= '1';

        wait for rising_edge(CLK);
        BBit0 <= '0'; BBit1 <= '0'; BBit2 <= '0'; BBit3 <= '0';
        BBit4 <= '0'; BBit5 <= '0'; BBit6 <= '0'; BBit7 <= '0';
        BBit14 <= '0'; BBit15 <= '0';
        BBit8 <= '1'; BBit9 <= '1'; BBit10 <= '1'; 
        BBit12 <= '1'; BBit13 <= '1';

        wait for rising_edge(CLK);
        BBit0 <= '0'; BBit1 <= '0'; BBit2 <= '0'; BBit3 <= '0';
        BBit4 <= '0'; BBit5 <= '0'; BBit6 <= '0'; BBit7 <= '0';
        BBit14 <= '0'; BBit15 <= '0';
        BBit8 <= '1'; BBit9 <= '1'; BBit10 <= '1';
        BBit12 <= '1'; BBit13 <= '1';

        wait for rising_edge(CLK);
        BBit0 <= '0'; BBit1 <= '0'; BBit2 <= '0'; BBit3 <= '0';
        BBit4 <= '0'; BBit9 <= '0'; BBit10 <= '0'; BBit11 <= '0';
        BBit14 <= '0'; BBit15 <= '0';
        BBit5 <= '1'; BBit6 <= '1'; BBit7 <= '1'; BBit8 <= '1';
        BBit12 <= '1'; BBit13 <= '1';

        wait for rising_edge(CLK);
        BBit0 <= '0'; BBit1 <= '0'; BBit2 <= '0';
        BBit7 <= '0'; BBit8 <= '0'; BBit9 <= '0'; 
        BBit10 <= '0'; BBit11 <= '0'; BBit14 <= '0'; BBit15 <= '0';
        BBit3 <= '1'; BBit4 <= '1'; BBit5 <= '1'; BBit6 <= '1';
        BBit12 <= '1'; BBit13 <= '1';

        wait for rising_edge(CLK);
        BBit0 <= '0'; BBit1 <= '0'; BBit2 <= '0';
        BBit7 <= '0'; BBit8 <= '0'; BBit9 <= '0';
        BBit10 <= '0'; BBit11 <= '0'; BBit14 <= '0';
        BBit3 <= '1'; BBit4 <= '1'; BBit5 <= '1'; BBit6 <= '1';
        BBit12 <= '1'; BBit13 <= '1';

        wait for rising_edge(CLK);
        BBit0 <= '0'; BBit1 <= '0'; BBit2 <= '0'; BBit3 <= '0';
        BBit4 <= '0'; BBit9 <= '0'; BBit10 <= '0'; BBit11 <= '0';
        BBit14 <= '0'; BBit15 <= '0';
        BBit5 <= '1'; BBit6 <= '1'; BBit7 <= '1'; BBit8 <= '1';
        BBit12 <= '1'; BBit13 <= '1';

        wait for rising_edge(CLK);
        BBit0 <= '0'; BBit1 <= '0'; BBit2 <= '0'; BBit3 <= '0';
        BBit4 <= '0'; BBit5 <= '0'; BBit6 <= '0'; BBit7 <= '0';
        BBit14 <= '0'; BBit15 <= '0';
        BBit8 <= '1'; BBit9 <= '1'; BBit10 <= '1';
        BBit12 <= '1'; BBit13 <= '1';

        wait for rising_edge(CLK);
        BBit0 <= '0'; BBit1 <= '0'; BBit2 <= '0'; BBit3 <= '0';
        BBit4 <= '0'; BBit5 <= '0'; BBit6 <= '0'; BBit7 <= '0';
        BBit14 <= '0'; BBit15 <= '0';
        BBit8 <= '1'; BBit9 <= '1'; BBit10 <= '1';
        BBit12 <= '1'; BBit13 <= '1';

        wait for rising_edge(CLK);
        BBit0 <= '0'; BBit1 <= '0'; BBit2 <= '0'; BBit3 <= '0';
        BBit4 <= '0'; BBit5 <= '0'; BBit6 <= '0'; BBit7 <= '0';
        BBit8 <= '0'; BBit9 <= '0'; BBit10 <= '0'; BBit11 <= '0';
        BBit12 <= '1'; BBit13 <= '1'; BBit14 <= '1'; BBit15 <= '1';

        wait for rising_edge(CLK);
        BBit0 <= '0'; BBit1 <= '0'; BBit2 <= '0'; BBit3 <= '0';
        BBit4 <= '0'; BBit5 <= '0'; BBit6 <= '0'; BBit7 <= '0';
        BBit8 <= '0'; BBit9 <= '0'; BBit10 <= '0'; BBit11 <= '0';
        BBit12 <= '1'; BBit13 <= '1'; BBit14 <= '1'; BBit15 <= '1';
    end procedure;

    procedure B_sign is
begin
    wait for rising_edge(CLK);
    BBit0 <= '1'; BBit1 <= '1'; BBit2 <= '1'; BBit3 <= '1';
    BBit4 <= '1'; BBit5 <= '1'; BBit6 <= '1'; BBit7 <= '1';
    BBit8 <= '1'; BBit9 <= '1'; BBit10 <= '1'; BBit11 <= '1';
    BBit12 <= '1'; BBit13 <= '1'; BBit14 <= '1'; BBit15 <= '1';

    wait for rising_edge(CLK);
    BBit0 <= '1'; BBit1 <= '1'; BBit2 <= '1'; BBit3 <= '1';
    BBit4 <= '1'; BBit5 <= '1'; BBit6 <= '1'; BBit7 <= '1';
    BBit8 <= '1'; BBit9 <= '1'; BBit10 <= '1'; BBit11 <= '1';
    BBit12 <= '1'; BBit13 <= '1'; BBit14 <= '1'; BBit15 <= '1';

    wait for rising_edge(CLK);
    BBit0 <= '1'; BBit1 <= '1'; BBit2 <= '1';
    BBit6 <= '1'; BBit7 <= '1'; BBit8 <= '1'; BBit9 <= '1';
    BBit13 <= '1'; BBit14 <= '1'; BBit15 <= '1';
    BBit3 <= '0'; BBit4 <= '0'; BBit5 <= '0';
    BBit10 <= '0'; BBit11 <= '0'; BBit12 <= '0';

    wait for rising_edge(CLK);
    BBit0 <= '1'; BBit1 <= '1'; BBit2 <= '1';
    BBit6 <= '1'; BBit7 <= '1'; BBit8 <= '1'; BBit9 <= '1';
    BBit13 <= '1'; BBit14 <= '1'; BBit15 <= '1';
    BBit3 <= '0'; BBit4 <= '0'; BBit5 <= '0';
    BBit10 <= '0'; BBit11 <= '0'; BBit12 <= '0';

    wait for rising_edge(CLK);
    BBit0 <= '1'; BBit1 <= '1'; BBit2 <= '1';
    BBit6 <= '1'; BBit7 <= '1'; BBit8 <= '1'; BBit9 <= '1';
    BBit13 <= '1'; BBit14 <= '1'; BBit15 <= '1';
    BBit3 <= '0'; BBit4 <= '0'; BBit5 <= '0';
    BBit10 <= '0'; BBit11 <= '0'; BBit12 <= '0';

    wait for rising_edge(CLK);
    BBit0 <= '1'; BBit1 <= '1'; BBit2 <= '1';
    BBit6 <= '1'; BBit7 <= '1'; BBit8 <= '1'; BBit9 <= '1';
    BBit13 <= '1'; BBit14 <= '1'; BBit15 <= '1';
    BBit3 <= '0'; BBit4 <= '0'; BBit5 <= '0';
    BBit10 <= '0'; BBit11 <= '0'; BBit12 <= '0';

    wait for rising_edge(CLK);
    BBit0 <= '1'; BBit1 <= '1'; BBit2 <= '1';
    BBit6 <= '1'; BBit7 <= '1'; BBit8 <= '1'; BBit9 <= '1';
    BBit13 <= '1'; BBit14 <= '1'; BBit15 <= '1';
    BBit3 <= '0'; BBit4 <= '0'; BBit5 <= '0';
    BBit10 <= '0'; BBit11 <= '0'; BBit12 <= '0';

    wait for rising_edge(CLK);
    BBit0 <= '1'; BBit1 <= '1'; BBit2 <= '1';
    BBit6 <= '1'; BBit7 <= '1'; BBit8 <= '1'; BBit9 <= '1';
    BBit13 <= '1'; BBit14 <= '1'; BBit15 <= '1';
    BBit3 <= '0'; BBit4 <= '0'; BBit5 <= '0';
    BBit10 <= '0'; BBit11 <= '0'; BBit12 <= '0';

    wait for rising_edge(CLK);
    BBit0 <= '1'; BBit1 <= '1'; BBit2 <= '1'; BBit3 <= '1';
    BBit4 <= '1'; BBit5 <= '1'; BBit6 <= '1'; BBit7 <= '1';
    BBit8 <= '1'; BBit9 <= '1'; BBit10 <= '1'; BBit11 <= '1';
    BBit12 <= '1'; BBit13 <= '1'; BBit14 <= '1'; BBit15 <= '1';

    wait for rising_edge(CLK);
    BBit0 <= '1'; BBit1 <= '1'; BBit2 <= '1'; BBit3 <= '1';
    BBit4 <= '1'; BBit5 <= '1'; BBit6 <= '1'; BBit7 <= '1';
    BBit8 <= '1'; BBit9 <= '1'; BBit10 <= '1'; BBit11 <= '1';
    BBit12 <= '1'; BBit13 <= '1'; BBit14 <= '1'; BBit15 <= '1';

    wait for rising_edge(CLK);
    BBit0 <= '1'; BBit1 <= '1'; BBit2 <= '1'; BBit3 <= '1';
    BBit4 <= '1'; BBit5 <= '1'; BBit6 <= '1'; BBit7 <= '1';
    BBit8 <= '1'; BBit9 <= '1'; BBit10 <= '1'; BBit11 <= '1';
    BBit12 <= '1'; BBit13 <= '1'; BBit14 <= '1'; BBit15 <= '1';
end procedure;

procedure C_sign is
begin
    wait for rising_edge(CLK);
    BBit0 <= '1'; BBit1 <= '1'; BBit2 <= '1'; BBit3 <= '1';
    BBit4 <= '1'; BBit5 <= '1'; BBit6 <= '1'; BBit7 <= '1';
    BBit8 <= '1'; BBit9 <= '1'; BBit10 <= '1'; BBit11 <= '1';
    BBit12 <= '1'; BBit13 <= '1'; BBit14 <= '1'; BBit15 <= '1';

    wait for rising_edge(CLK);
    BBit0 <= '1'; BBit1 <= '1'; BBit2 <= '1'; BBit3 <= '1';
    BBit4 <= '1'; BBit5 <= '1'; BBit6 <= '1'; BBit7 <= '1';
    BBit8 <= '1'; BBit9 <= '1'; BBit10 <= '1'; BBit11 <= '1';
    BBit12 <= '1'; BBit13 <= '1'; BBit14 <= '1'; BBit15 <= '1';

    wait for rising_edge(CLK);
    BBit0 <= '1'; BBit1 <= '1'; BBit2 <= '1'; BBit3 <= '1';
    BBit4 <= '1'; BBit5 <= '1'; BBit6 <= '1'; BBit7 <= '1';
    BBit8 <= '1'; BBit9 <= '1'; BBit10 <= '1'; BBit11 <= '1';
    BBit12 <= '1'; BBit13 <= '1'; BBit14 <= '1'; BBit15 <= '1';

    wait for rising_edge(CLK);
    BBit0 <= '1'; BBit1 <= '1'; BBit2 <= '1'; BBit3 <= '1';
    BBit12 <= '1'; BBit13 <= '1'; BBit14 <= '1'; BBit15 <= '1';
    BBit4 <= '0'; BBit5 <= '0'; BBit6 <= '0'; BBit7 <= '0';
    BBit8 <= '0'; BBit9 <= '0'; BBit10 <= '0'; BBit11 <= '0';

    wait for rising_edge(CLK);
    BBit0 <= '1'; BBit1 <= '1'; BBit2 <= '1'; BBit3 <= '1';
    BBit12 <= '1'; BBit13 <= '1'; BBit14 <= '1'; BBit15 <= '1';
    BBit4 <= '0'; BBit5 <= '0'; BBit6 <= '0'; BBit7 <= '0';
    BBit8 <= '0'; BBit9 <= '0'; BBit10 <= '0'; BBit11 <= '0';

    wait for rising_edge(CLK);
    BBit0 <= '1'; BBit1 <= '1'; BBit2 <= '1'; BBit3 <= '1';
    BBit12 <= '1'; BBit13 <= '1'; BBit14 <= '1'; BBit15 <= '1';
    BBit4 <= '0'; BBit5 <= '0'; BBit6 <= '0'; BBit7 <= '0';
    BBit8 <= '0'; BBit9 <= '0'; BBit10 <= '0'; BBit11 <= '0';

    wait for rising_edge(CLK);
    BBit0 <= '1'; BBit1 <= '1'; BBit2 <= '1'; BBit3 <= '1';
    BBit12 <= '1'; BBit13 <= '1'; BBit14 <= '1'; BBit15 <= '1';
    BBit4 <= '0'; BBit5 <= '0'; BBit6 <= '0'; BBit7 <= '0';
    BBit8 <= '0'; BBit9 <= '0'; BBit10 <= '0'; BBit11 <= '0';

    wait for rising_edge(CLK);
    BBit0 <= '1'; BBit1 <= '1'; BBit2 <= '1'; BBit3 <= '1';
    BBit12 <= '1'; BBit13 <= '1'; BBit14 <= '1'; BBit15 <= '1';
    BBit4 <= '0'; BBit5 <= '0'; BBit6 <= '0'; BBit7 <= '0';
    BBit8 <= '0'; BBit9 <= '0'; BBit10 <= '0'; BBit11 <= '0';

    wait for rising_edge(CLK);
    BBit0 <= '1'; BBit1 <= '1'; BBit2 <= '1'; BBit3 <= '1';
    BBit12 <= '1'; BBit13 <= '1'; BBit14 <= '1'; BBit15 <= '1';
    BBit4 <= '0'; BBit5 <= '0'; BBit6 <= '0'; BBit7 <= '0';
    BBit8 <= '0'; BBit9 <= '0'; BBit10 <= '0'; BBit11 <= '0';
end procedure;

procedure D_sign is
begin
    wait for rising_edge(CLK);
    BBit0 <= '1'; BBit1 <= '1'; BBit2 <= '1'; BBit3 <= '1';
    BBit4 <= '1'; BBit5 <= '1'; BBit6 <= '1'; BBit7 <= '1';
    BBit8 <= '1'; BBit9 <= '1'; BBit10 <= '1'; BBit11 <= '1';
    BBit12 <= '1'; BBit13 <= '1'; BBit14 <= '1'; BBit15 <= '1';

    wait for rising_edge(CLK);
    BBit0 <= '1'; BBit1 <= '1'; BBit2 <= '1'; BBit3 <= '1';
    BBit4 <= '1'; BBit5 <= '1'; BBit6 <= '1'; BBit7 <= '1';
    BBit8 <= '1'; BBit9 <= '1'; BBit10 <= '1'; BBit11 <= '1';
    BBit12 <= '1'; BBit13 <= '1'; BBit14 <= '1'; BBit15 <= '1';

    wait for rising_edge(CLK);
    BBit0 <= '1'; BBit1 <= '1'; BBit2 <= '1';
    BBit13 <= '1'; BBit14 <= '1'; BBit15 <= '1';
    BBit3 <= '0'; BBit4 <= '0'; BBit5 <= '0'; BBit6 <= '0';
    BBit7 <= '0'; BBit8 <= '0'; BBit9 <= '0'; BBit10 <= '0';
    BBit11 <= '0'; BBit12 <= '0';

    wait for rising_edge(CLK);
    BBit0 <= '1'; BBit1 <= '1'; BBit2 <= '1';
    BBit13 <= '1'; BBit14 <= '1'; BBit15 <= '1';
    BBit3 <= '0'; BBit4 <= '0'; BBit5 <= '0'; BBit6 <= '0';
    BBit7 <= '0'; BBit8 <= '0'; BBit9 <= '0'; BBit10 <= '0';
    BBit11 <= '0'; BBit12 <= '0';

    wait for rising_edge(CLK);
    BBit0 <= '1'; BBit1 <= '1'; BBit2 <= '1';
    BBit13 <= '1'; BBit14 <= '1'; BBit15 <= '1';
    BBit3 <= '0'; BBit4 <= '0'; BBit5 <= '0'; BBit6 <= '0';
    BBit7 <= '0'; BBit8 <= '0'; BBit9 <= '0'; BBit10 <= '0';
    BBit11 <= '0'; BBit12 <= '0';

    wait for rising_edge(CLK);
    BBit2 <= '1'; BBit3 <= '1'; BBit4 <= '1'; BBit5 <= '1';
    BBit6 <= '1'; BBit7 <= '1'; BBit8 <= '1'; BBit9 <= '1';
    BBit10 <= '1'; BBit11 <= '1'; BBit12 <= '1'; BBit13 <= '1';
    BBit0 <= '0'; BBit1 <= '0'; BBit14 <= '0'; BBit15 <= '0';

    wait for rising_edge(CLK);
    BBit2 <= '1'; BBit3 <= '1'; BBit4 <= '1'; BBit5 <= '1';
    BBit6 <= '1'; BBit7 <= '1'; BBit8 <= '1'; BBit9 <= '1';
    BBit10 <= '1'; BBit11 <= '1'; BBit12 <= '1'; BBit13 <= '1';
    BBit0 <= '0'; BBit1 <= '0'; BBit14 <= '0'; BBit15 <= '0';

    wait for rising_edge(CLK);
    BBit4 <= '1'; BBit5 <= '1'; BBit6 <= '1'; BBit7 <= '1';
    BBit8 <= '1'; BBit9 <= '1'; BBit10 <= '1'; BBit11 <= '1';
    BBit0 <= '0'; BBit1 <= '0'; BBit2 <= '0'; BBit3 <= '0';
    BBit12 <= '0'; BBit13 <= '0'; BBit14 <= '0'; BBit15 <= '0';

    wait for rising_edge(CLK);
    BBit4 <= '1'; BBit5 <= '1'; BBit6 <= '1'; BBit7 <= '1';
    BBit8 <= '1'; BBit9 <= '1'; BBit10 <= '1'; BBit11 <= '1';
    BBit0 <= '0'; BBit1 <= '0'; BBit2 <= '0'; BBit3 <= '0';
    BBit12 <= '0'; BBit13 <= '0'; BBit14 <= '0'; BBit15 <= '0';
end procedure;

procedure E_sign is
begin
    wait for rising_edge(CLK);
    BBit0 <= '1'; BBit1 <= '1'; BBit2 <= '1'; BBit3 <= '1';
    BBit4 <= '1'; BBit5 <= '1'; BBit6 <= '1'; BBit7 <= '1';
    BBit8 <= '1'; BBit9 <= '1'; BBit10 <= '1'; BBit11 <= '1';
    BBit12 <= '1'; BBit13 <= '1'; BBit14 <= '1'; BBit15 <= '1';

    wait for rising_edge(CLK);
    BBit0 <= '1'; BBit1 <= '1'; BBit2 <= '1'; BBit3 <= '1';
    BBit4 <= '1'; BBit5 <= '1'; BBit6 <= '1'; BBit7 <= '1';
    BBit8 <= '1'; BBit9 <= '1'; BBit10 <= '1'; BBit11 <= '1';
    BBit12 <= '1'; BBit13 <= '1'; BBit14 <= '1'; BBit15 <= '1';

    wait for rising_edge(CLK);
    BBit0 <= '1'; BBit1 <= '1'; BBit2 <= '1'; 
    BBit6 <= '1'; BBit7 <= '1'; BBit8 <= '1';
    BBit13 <= '1'; BBit14 <= '1'; BBit15 <= '1';
    BBit3 <= '0'; BBit4 <= '0'; BBit5 <= '0';
    BBit9 <= '0'; BBit10 <= '0'; BBit11 <= '0'; BBit12 <= '0';

    wait for rising_edge(CLK);
    BBit0 <= '1'; BBit1 <= '1'; BBit2 <= '1'; 
    BBit6 <= '1'; BBit7 <= '1'; BBit8 <= '1';
    BBit13 <= '1'; BBit14 <= '1'; BBit15 <= '1';
    BBit3 <= '0'; BBit4 <= '0'; BBit5 <= '0';
    BBit9 <= '0'; BBit10 <= '0'; BBit11 <= '0'; BBit12 <= '0';

    wait for rising_edge(CLK);
    BBit0 <= '1'; BBit1 <= '1'; BBit2 <= '1'; 
    BBit6 <= '1'; BBit7 <= '1'; BBit8 <= '1';
    BBit13 <= '1'; BBit14 <= '1'; BBit15 <= '1';
    BBit3 <= '0'; BBit4 <= '0'; BBit5 <= '0';
    BBit9 <= '0'; BBit10 <= '0'; BBit11 <= '0'; BBit12 <= '0';

    wait for rising_edge(CLK);
    BBit0 <= '1'; BBit1 <= '1'; BBit2 <= '1'; 
    BBit6 <= '1'; BBit7 <= '1'; BBit8 <= '1';
    BBit13 <= '1'; BBit14 <= '1'; BBit15 <= '1';
    BBit3 <= '0'; BBit4 <= '0'; BBit5 <= '0';
    BBit9 <= '0'; BBit10 <= '0'; BBit11 <= '0'; BBit12 <= '0';
end procedure;

procedure F_sign is
begin
    wait for rising_edge(CLK);
    BBit0 <= '1'; BBit1 <= '1'; BBit2 <= '1'; BBit3 <= '1';
    BBit4 <= '1'; BBit5 <= '1'; BBit6 <= '1'; BBit7 <= '1';
    BBit8 <= '1'; BBit9 <= '1'; BBit10 <= '1'; BBit11 <= '1';
    BBit12 <= '1'; BBit13 <= '1'; BBit14 <= '1'; BBit15 <= '1';

    wait for rising_edge(CLK);
    BBit0 <= '1'; BBit1 <= '1'; BBit2 <= '1'; BBit3 <= '1';
    BBit4 <= '1'; BBit5 <= '1'; BBit6 <= '1'; BBit7 <= '1';
    BBit8 <= '1'; BBit9 <= '1'; BBit10 <= '1'; BBit11 <= '1';
    BBit12 <= '1'; BBit13 <= '1'; BBit14 <= '1'; BBit15 <= '1';

    wait for rising_edge(CLK);
    BBit0 <= '1'; BBit1 <= '1'; BBit2 <= '1';
    BBit6 <= '1'; BBit7 <= '1';
    BBit3 <= '0'; BBit4 <= '0'; BBit5 <= '0';
    BBit9 <= '0'; BBit10 <= '0'; BBit11 <= '0'; BBit12 <= '0';

    wait for rising_edge(CLK);
    BBit0 <= '1'; BBit1 <= '1'; BBit2 <= '1';
    BBit6 <= '1'; BBit7 <= '1';
    BBit3 <= '0'; BBit4 <= '0'; BBit5 <= '0';
    BBit9 <= '0'; BBit10 <= '0'; BBit11 <= '0'; BBit12 <= '0';

    wait for rising_edge(CLK);
    BBit0 <= '1'; BBit1 <= '1'; BBit2 <= '1';
    BBit6 <= '1'; BBit7 <= '1';
    BBit3 <= '0'; BBit4 <= '0'; BBit5 <= '0';
    BBit9 <= '0'; BBit10 <= '0'; BBit11 <= '0'; BBit12 <= '0';

    wait for rising_edge(CLK);
    BBit0 <= '1'; BBit1 <= '1'; BBit2 <= '1';
    BBit6 <= '1'; BBit7 <= '1';
    BBit3 <= '0'; BBit4 <= '0'; BBit5 <= '0';
    BBit9 <= '0'; BBit10 <= '0'; BBit11 <= '0'; BBit12 <= '0';
end procedure;

procedure G_sign is
begin
    BBit0 <= '1'; BBit1 <= '1'; BBit2 <= '1'; BBit3 <= '1';
    BBit4 <= '1'; BBit5 <= '1'; BBit6 <= '1'; BBit7 <= '1';
    BBit8 <= '1'; BBit9 <= '1'; BBit10 <= '1'; BBit11 <= '1';
    BBit12 <= '1'; BBit13 <= '1'; BBit14 <= '1'; BBit15 <= '1';
    wait until rising_edge(CLK);

    BBit0 <= '1'; BBit1 <= '1'; BBit2 <= '1'; BBit3 <= '1';
    BBit4 <= '1'; BBit5 <= '1'; BBit6 <= '1'; BBit7 <= '1';
    BBit8 <= '1'; BBit9 <= '1'; BBit10 <= '1'; BBit11 <= '1';
    BBit12 <= '1'; BBit13 <= '1'; BBit14 <= '1'; BBit15 <= '1';
    wait until rising_edge(CCLK);

    BBit0 <= '1'; BBit1 <= '1'; BBit2 <= '1'; BBit3 <= '1';
    BBit4 <= '0'; BBit5 <= '0'; BBit6 <= '0'; BBit7 <= '0';
    BBit8 <= '0'; BBit9 <= '0'; BBit10 <= '0'; BBit11 <= '0';
    BBit12 <= '1'; BBit13 <= '1'; BBit14 <= '1'; BBit15 <= '1';
    wait until rising_edge(CLK);

    BBit0 <= '1'; BBit1 <= '1'; BBit2 <= '1'; BBit3 <= '1';
    BBit4 <= '0'; BBit5 <= '0'; BBit6 <= '0'; BBit7 <= '0';
    BBit8 <= '0'; BBit9 <= '0'; BBit10 <= '0'; BBit11 <= '0';
    BBit12 <= '1'; BBit13 <= '1'; BBit14 <= '1'; BBit15 <= '1';
    wait until rising_edge(CLK);

    BBit0 <= '0'; BBit1 <= '0'; BBit2 <= '0'; BBit3 <= '0';
    BBit4 <= '0'; BBit5 <= '0'; BBit6 <= '0'; BBit7 <= '0';
    BBit8 <= '0'; BBit9 <= '0'; BBit10 <= '0'; BBit11 <= '0';
    BBit12 <= '1'; BBit13 <= '1'; BBit14 <= '1'; BBit15 <= '1';
    wait until rising_edge(CLK);

    BBit0 <= '0'; BBit1 <= '0'; BBit2 <= '0'; BBit3 <= '0';
    BBit4 <= '0';
    BBit5 <= '1'; BBit6 <= '1'; BBit7 <= '1'; BBit8 <= '1';
    BBit9 <= '1'; BBit10 <= '1'; BBit11 <= '1';
    BBit12 <= '1'; BBit13 <= '1'; BBit14 <= '1'; BBit15 <= '1';
    wait until rising_edge(CLK);
end procedure;

procedure H_sign is
begin
    BBit0 <= '1'; BBit1 <= '1'; BBit2 <= '1'; BBit3 <= '1';
    BBit4 <= '1'; BBit5 <= '1'; BBit6 <= '1'; BBit7 <= '1';
    BBit8 <= '1'; BBit9 <= '1'; BBit10 <= '1'; BBit11 <= '1';
    BBit12 <= '1'; BBit13 <= '1'; BBit14 <= '1'; BBit15 <= '1';
    wait until rising_edge(CLK);

    BBit0 <= '1'; BBit1 <= '1'; BBit2 <= '1'; BBit3 <= '1';
    BBit4 <= '1'; BBit5 <= '1'; BBit6 <= '1'; BBit7 <= '1';
    BBit8 <= '1'; BBit9 <= '1'; BBit10 <= '1'; BBit11 <= '1';
    BBit12 <= '1'; BBit13 <= '1'; BBit14 <= '1'; BBit15 <= '1';
    wait until rising_edge(CLK);

    BBit0 <= '0'; BBit1 <= '0'; BBit2 <= '0'; BBit3 <= '0';
    BBit4 <= '0'; BBit5 <= '0';
    BBit6 <= '1'; BBit7 <= '1'; BBit8 <= '1';
    BBit9 <= '0'; BBit10 <= '0'; BBit11 <= '0';
    BBit12 <= '0'; BBit13 <= '0'; BBit14 <= '0'; BBit15 <= '0';
    wait until rising_edge(CLK);

    BBit0 <= '0'; BBit1 <= '0'; BBit2 <= '0'; BBit3 <= '0';
    BBit4 <= '0'; BBit5 <= '0';
    BBit6 <= '1'; BBit7 <= '1'; BBit8 <= '1';
    BBit9 <= '0'; BBit10 <= '0'; BBit11 <= '0';
    BBit12 <= '0'; BBit13 <= '0'; BBit14 <= '0'; BBit15 <= '0';
    wait until rising_edge(CLK);

    BBit0 <= '1'; BBit1 <= '1'; BBit2 <= '1'; BBit3 <= '1';
    BBit4 <= '1'; BBit5 <= '1'; BBit6 <= '1'; BBit7 <= '1';
    BBit8 <= '1'; BBit9 <= '1'; BBit10 <= '1'; BBit11 <= '1';
    BBit12 <= '1'; BBit13 <= '1'; BBit14 <= '1'; BBit15 <= '1';
    wait until rising_edge(CLK);

    BBit0 <= '1'; BBit1 <= '1'; BBit2 <= '1'; BBit3 <= '1';
    BBit4 <= '1'; BBit5 <= '1'; BBit6 <= '1'; BBit7 <= '1';
    BBit8 <= '1'; BBit9 <= '1'; BBit10 <= '1'; BBit11 <= '1';
    BBit12 <= '1'; BBit13 <= '1'; BBit14 <= '1'; BBit15 <= '1';
    wait until rising_edge(CLK);
end procedure;

procedure I_sign is
begin
    BBit0 <= '1'; BBit1 <= '1'; BBit2 <= '1'; BBit3 <= '1';
    BBit4 <= '0'; BBit5 <= '0'; BBit6 <= '0';
    BBit7 <= '1'; BBit8 <= '1'; BBit9 <= '1'; BBit10 <= '1';
    BBit11 <= '1'; BBit12 <= '1'; BBit13 <= '1'; BBit14 <= '1'; BBit15 <= '1';
    wait until rising_edge(CLK);

    BBit0 <= '1'; BBit1 <= '1'; BBit2 <= '1'; BBit3 <= '1';
    BBit4 <= '0'; BBit5 <= '0'; BBit6 <= '0';
    BBit7 <= '1'; BBit8 <= '1'; BBit9 <= '1'; BBit10 <= '1';
    BBit11 <= '1'; BBit12 <= '1'; BBit13 <= '1'; BBit14 <= '1'; BBit15 <= '1';
    wait until rising_edge(CLK);

    BBit0 <= '1'; BBit1 <= '1'; BBit2 <= '1'; BBit3 <= '1';
    BBit4 <= '0'; BBit5 <= '0'; BBit6 <= '0';
    BBit7 <= '1'; BBit8 <= '1'; BBit9 <= '1'; BBit10 <= '1';
    BBit11 <= '1'; BBit12 <= '1'; BBit13 <= '1'; BBit14 <= '1'; BBit15 <= '1';
    wait until rising_edge(CLK);
end procedure;

procedure J_sign is
begin
    BBit13 <= '1'; BBit14 <= '1'; BBit15 <= '1';
    BBit0 <= '0'; BBit1 <= '0'; BBit2 <= '0'; BBit3 <= '0'; BBit4 <= '0';
    BBit5 <= '0'; BBit6 <= '0'; BBit7 <= '0'; BBit8 <= '0'; BBit9 <= '0';
    BBit10 <= '0'; BBit11 <= '0'; BBit12 <= '0';
    wait until rising_edge(CLK);

    BBit13 <= '1'; BBit14 <= '1'; BBit15 <= '1';
    BBit0 <= '0'; BBit1 <= '0'; BBit2 <= '0'; BBit3 <= '0'; BBit4 <= '0';
    BBit5 <= '0'; BBit6 <= '0'; BBit7 <= '0'; BBit8 <= '0'; BBit9 <= '0';
    BBit10 <= '0'; BBit11 <= '0'; BBit12 <= '0';
    wait until rising_edge(CLK);

    BBit13 <= '1'; BBit14 <= '1'; BBit15 <= '1';
    BBit0 <= '0'; BBit1 <= '0'; BBit2 <= '0'; BBit3 <= '0'; BBit4 <= '0';
    BBit5 <= '0'; BBit6 <= '0'; BBit7 <= '0'; BBit8 <= '0'; BBit9 <= '0';
    BBit10 <= '0'; BBit11 <= '0'; BBit12 <= '0';
    wait until rising_edge(CLK);

    BBit0 <= '1'; BBit1 <= '1'; BBit2 <= '1'; 
    BBit13 <= '1'; BBit14 <= '1'; BBit15 <= '1';
    BBit3 <= '0'; BBit4 <= '0'; BBit5 <= '0'; BBit6 <= '0'; BBit7 <= '0';
    BBit8 <= '0'; BBit9 <= '0'; BBit10 <= '0'; BBit11 <= '0'; BBit12 <= '0';
    wait until rising_edge(CLK);

    BBit0 <= '1'; BBit1 <= '1'; BBit2 <= '1'; 
    BBit13 <= '1'; BBit14 <= '1'; BBit15 <= '1';
    BBit3 <= '0'; BBit4 <= '0'; BBit5 <= '0'; BBit6 <= '0'; BBit7 <= '0';
    BBit8 <= '0'; BBit9 <= '0'; BBit10 <= '0'; BBit11 <= '0'; BBit12 <= '0';
    wait until rising_edge(CLK);

    BBit0 <= '1'; BBit1 <= '1'; BBit2 <= '1'; 
    BBit13 <= '1'; BBit14 <= '1'; BBit15 <= '1';
    BBit3 <= '0'; BBit4 <= '0'; BBit5 <= '0'; BBit6 <= '0'; BBit7 <= '0';
    BBit8 <= '0'; BBit9 <= '0'; BBit10 <= '0'; BBit11 <= '0'; BBit12 <= '0';
    wait until rising_edge(CLK);

    BBit0 <= '1'; BBit1 <= '1'; BBit2 <= '1'; BBit3 <= '1'; BBit4 <= '1';
    BBit5 <= '1'; BBit6 <= '1'; BBit7 <= '1'; BBit8 <= '1'; BBit9 <= '1';
    BBit10 <= '1'; BBit11 <= '1'; BBit12 <= '1'; BBit13 <= '1';
    BBit14 <= '1'; BBit15 <= '1';
    wait until rising_edge(CLK);

    BBit0 <= '1'; BBit1 <= '1'; BBit2 <= '1'; BBit3 <= '1'; BBit4 <= '1';
    BBit5 <= '1'; BBit6 <= '1'; BBit7 <= '1'; BBit8 <= '1'; BBit9 <= '1';
    BBit10 <= '1'; BBit11 <= '1'; BBit12 <= '1'; BBit13 <= '1';
    BBit14 <= '1'; BBit15 <= '1';
    wait until rising_edge(CLK);
end procedure;

procedure K_sign is
begin
    BBit0 <= '1'; BBit1 <= '1'; BBit2 <= '1'; BBit3 <= '1'; BBit4 <= '1';
    BBit5 <= '1'; BBit6 <= '1'; BBit7 <= '1'; BBit8 <= '1'; BBit9 <= '1';
    BBit10 <= '1'; BBit11 <= '1'; BBit12 <= '1'; BBit13 <= '1'; 
    BBit14 <= '1'; BBit15 <= '1';
    wait until rising_edge(CLK);

    BBit0 <= '1'; BBit1 <= '1'; BBit2 <= '1'; BBit3 <= '1'; BBit4 <= '1';
    BBit5 <= '1'; BBit6 <= '1'; BBit7 <= '1'; BBit8 <= '1'; BBit9 <= '1';
    BBit10 <= '1'; BBit11 <= '1'; BBit12 <= '1'; BBit13 <= '1'; 
    BBit14 <= '1'; BBit15 <= '1';
    wait until rising_edge(CLK);

    BBit5 <= '1'; BBit6 <= '1'; BBit7 <= '1'; BBit8 <= '1'; BBit9 <= '1'; BBit10 <= '1';
    BBit0 <= '0'; BBit1 <= '0'; BBit2 <= '0'; BBit3 <= '0'; BBit4 <= '0';
    BBit11 <= '0'; BBit12 <= '0'; BBit13 <= '0'; BBit14 <= '0'; BBit15 <= '0';
    wait until rising_edge(CLK);

    BBit5 <= '1'; BBit6 <= '1'; BBit7 <= '1'; BBit8 <= '1'; BBit9 <= '1'; BBit10 <= '1';
    BBit0 <= '0'; BBit1 <= '0'; BBit2 <= '0'; BBit3 <= '0'; BBit4 <= '0';
    BBit11 <= '0'; BBit12 <= '0'; BBit13 <= '0'; BBit14 <= '0'; BBit15 <= '0';
    wait until rising_edge(CLK);

    BBit0 <= '1'; BBit1 <= '1'; BBit2 <= '1'; BBit3 <= '1'; BBit4 <= '1'; BBit5 <= '1';
    BBit10 <= '1'; BBit11 <= '1'; BBit12 <= '1'; BBit13 <= '1'; BBit14 <= '1'; BBit15 <= '1';
    BBit6 <= '0'; BBit7 <= '0'; BBit8 <= '0'; BBit9 <= '0';
    wait until rising_edge(CLK);

    BBit0 <= '1'; BBit1 <= '1'; BBit2 <= '1'; BBit3 <= '1'; BBit4 <= '1'; BBit5 <= '1';
    BBit10 <= '1'; BBit11 <= '1'; BBit12 <= '1'; BBit13 <= '1'; BBit14 <= '1'; BBit15 <= '1';
    BBit6 <= '0'; BBit7 <= '0'; BBit8 <= '0'; BBit9 <= '0';
    wait until rising_edge(CLK);
end procedure;

procedure L_sign is
begin
    BBit0 <= '1'; BBit1 <= '1'; BBit2 <= '1'; BBit3 <= '1'; BBit4 <= '1';
    BBit5 <= '1'; BBit6 <= '1'; BBit7 <= '1'; BBit8 <= '1'; BBit9 <= '1';
    BBit10 <= '1'; BBit11 <= '1'; BBit12 <= '1'; BBit13 <= '1'; BBit14 <= '1'; BBit15 <= '1';
    wait until rising_edge(CLK);

    BBit0 <= '1'; BBit1 <= '1'; BBit2 <= '1'; BBit3 <= '1'; BBit4 <= '1';
    BBit5 <= '1'; BBit6 <= '1'; BBit7 <= '1'; BBit8 <= '1'; BBit9 <= '1';
    BBit10 <= '1'; BBit11 <= '1'; BBit12 <= '1'; BBit13 <= '1'; BBit14 <= '1'; BBit15 <= '1';
    wait until rising_edge(CLK);

    BBit12 <= '1'; BBit13 <= '1'; BBit14 <= '1'; BBit15 <= '1';
    BBit0 <= '0'; BBit1 <= '0'; BBit2 <= '0'; BBit3 <= '0'; BBit4 <= '0';
    BBit5 <= '0'; BBit6 <= '0'; BBit7 <= '0'; BBit8 <= '0'; BBit9 <= '0';
    BBit10 <= '0'; BBit11 <= '0';
    wait until rising_edge(CLK);

    BBit12 <= '1'; BBit13 <= '1'; BBit14 <= '1'; BBit15 <= '1';
    BBit0 <= '0'; BBit1 <= '0'; BBit2 <= '0'; BBit3 <= '0'; BBit4 <= '0';
    BBit5 <= '0'; BBit6 <= '0'; BBit7 <= '0'; BBit8 <= '0'; BBit9 <= '0';
    BBit10 <= '0'; BBit11 <= '0';
    wait until rising_edge(CLK);

    BBit12 <= '1'; BBit13 <= '1'; BBit14 <= '1'; BBit15 <= '1';
    BBit0 <= '0'; BBit1 <= '0'; BBit2 <= '0'; BBit3 <= '0'; BBit4 <= '0';
    BBit5 <= '0'; BBit6 <= '0'; BBit7 <= '0'; BBit8 <= '0'; BBit9 <= '0';
    BBit10 <= '0'; BBit11 <= '0';
    wait until rising_edge(CLK);

    BBit12 <= '1'; BBit13 <= '1'; BBit14 <= '1'; BBit15 <= '1';
    BBit0 <= '0'; BBit1 <= '0'; BBit2 <= '0'; BBit3 <= '0'; BBit4 <= '0';
    BBit5 <= '0'; BBit6 <= '0'; BBit7 <= '0'; BBit8 <= '0'; BBit9 <= '0';
    BBit10 <= '0'; BBit11 <= '0';
    wait until rising_edge(CLK);
end procedure;

procedure M_sign is
begin
    BBit4 <= '1'; BBit5 <= '1'; BBit6 <= '1'; BBit7 <= '1';
    BBit8 <= '1'; BBit9 <= '1'; BBit10 <= '1'; BBit11 <= '1';
    BBit12 <= '1'; BBit13 <= '1'; BBit14 <= '1'; BBit15 <= '1';
    BBit0 <= '0'; BBit1 <= '0'; BBit2 <= '0'; BBit3 <= '0';
    wait until rising_edge(CLK);

    BBit4 <= '1'; BBit5 <= '1'; BBit6 <= '1'; BBit7 <= '1';
    BBit8 <= '1'; BBit9 <= '1'; BBit10 <= '1'; BBit11 <= '1';
    BBit12 <= '1'; BBit13 <= '1'; BBit14 <= '1'; BBit15 <= '1';
    BBit0 <= '0'; BBit1 <= '0'; BBit2 <= '0'; BBit3 <= '0';
    wait until rising_edge(CLK);

    BBit4 <= '1'; BBit5 <= '1'; BBit6 <= '1'; BBit7 <= '1';
    BBit0 <= '0'; BBit1 <= '0'; BBit2 <= '0'; BBit3 <= '0';
    BBit8 <= '0'; BBit9 <= '0'; BBit10 <= '0'; BBit11 <= '0';
    BBit12 <= '0'; BBit13 <= '0'; BBit14 <= '0'; BBit15 <= '0';
    wait until rising_edge(CLK);

    BBit4 <= '1'; BBit5 <= '1'; BBit6 <= '1'; BBit7 <= '1';
    BBit0 <= '0'; BBit1 <= '0'; BBit2 <= '0'; BBit3 <= '0';
    BBit8 <= '0'; BBit9 <= '0'; BBit10 <= '0'; BBit11 <= '0';
    BBit12 <= '0'; BBit13 <= '0'; BBit14 <= '0'; BBit15 <= '0';
    wait until rising_edge(CLK);

    BBit4 <= '1'; BBit5 <= '1'; BBit6 <= '1'; BBit7 <= '1';
    BBit8 <= '1'; BBit9 <= '1'; BBit10 <= '1'; BBit11 <= '1';
    BBit12 <= '1'; BBit13 <= '1'; BBit14 <= '1'; BBit15 <= '1';
    BBit0 <= '0'; BBit1 <= '0'; BBit2 <= '0'; BBit3 <= '0';
    wait until rising_edge(CLK);

    BBit4 <= '1'; BBit5 <= '1'; BBit6 <= '1'; BBit7 <= '1';
    BBit8 <= '1'; BBit9 <= '1'; BBit10 <= '1'; BBit11 <= '1';
    BBit12 <= '1'; BBit13 <= '1'; BBit14 <= '1'; BBit15 <= '1';
    BBit0 <= '0'; BBit1 <= '0'; BBit2 <= '0'; BBit3 <= '0';
    wait until rising_edge(CLK);

    BBit4 <= '1'; BBit5 <= '1'; BBit6 <= '1'; BBit7 <= '1';
    BBit0 <= '0'; BBit1 <= '0'; BBit2 <= '0'; BBit3 <= '0';
    BBit8 <= '0'; BBit9 <= '0'; BBit10 <= '0'; BBit11 <= '0';
    BBit12 <= '0'; BBit13 <= '0'; BBit14 <= '0'; BBit15 <= '0';
    wait until rising_edge(CLK);

    BBit4 <= '1'; BBit5 <= '1'; BBit6 <= '1'; BBit7 <= '1';
    BBit0 <= '0'; BBit1 <= '0'; BBit2 <= '0'; BBit3 <= '0';
    BBit8 <= '0'; BBit9 <= '0'; BBit10 <= '0'; BBit11 <= '0';
    BBit12 <= '0'; BBit13 <= '0'; BBit14 <= '0'; BBit15 <= '0';
    wait until rising_edge(CLK);
end procedure;

procedure N_sign is
begin
    BBit0 <= '1'; BBit1 <= '1'; BBit2 <= '1'; BBit3 <= '1'; BBit4 <= '1';
    BBit5 <= '1'; BBit6 <= '1'; BBit7 <= '1'; BBit8 <= '1'; BBit9 <= '1';
    BBit10 <= '1'; BBit11 <= '1'; BBit12 <= '1'; BBit13 <= '1'; BBit14 <= '1'; BBit15 <= '1';
    wait until rising_edge(CLK);

    BBit0 <= '1'; BBit1 <= '1'; BBit2 <= '1'; BBit3 <= '1'; BBit4 <= '1';
    BBit5 <= '1'; BBit6 <= '1'; BBit7 <= '1'; BBit8 <= '1'; BBit9 <= '1';
    BBit10 <= '1'; BBit11 <= '1'; BBit12 <= '1'; BBit13 <= '1'; BBit14 <= '1'; BBit15 <= '1';
    wait until rising_edge(CLK);

    BBit0 <= '1'; BBit1 <= '1'; BBit2 <= '1'; BBit3 <= '1';
    BBit4 <= '0'; BBit5 <= '0'; BBit6 <= '0'; BBit7 <= '0'; BBit8 <= '0';
    BBit9 <= '0'; BBit10 <= '0'; BBit11 <= '0'; BBit12 <= '0'; BBit13 <= '0'; BBit14 <= '0'; BBit15 <= '0';
    wait until rising_edge(CLK);

    BBit1 <= '1'; BBit2 <= '1'; BBit3 <= '1'; BBit4 <= '1';
    BBit0 <= '0'; BBit5 <= '0'; BBit6 <= '0'; BBit7 <= '0'; BBit8 <= '0';
    BBit9 <= '0'; BBit10 <= '0'; BBit11 <= '0'; BBit12 <= '0'; BBit13 <= '0'; BBit14 <= '0'; BBit15 <= '0';
    wait until rising_edge(CLK);

    BBit2 <= '1'; BBit3 <= '1'; BBit4 <= '1'; BBit5 <= '1';
    BBit0 <= '0'; BBit1 <= '0'; BBit6 <= '0'; BBit7 <= '0'; BBit8 <= '0';
    BBit9 <= '0'; BBit10 <= '0'; BBit11 <= '0'; BBit12 <= '0'; BBit13 <= '0'; BBit14 <= '0'; BBit15 <= '0';
    wait until rising_edge(CLK);

    BBit4 <= '1'; BBit5 <= '1'; BBit6 <= '1'; BBit7 <= '1';
    BBit0 <= '0'; BBit1 <= '0'; BBit2 <= '0'; BBit3 <= '0'; BBit8 <= '0';
    BBit9 <= '0'; BBit10 <= '0'; BBit11 <= '0'; BBit12 <= '0'; BBit13 <= '0'; BBit14 <= '0'; BBit15 <= '0';
    wait until rising_edge(CLK);

    BBit6 <= '1'; BBit7 <= '1'; BBit8 <= '1'; BBit9 <= '1';
    BBit0 <= '0'; BBit1 <= '0'; BBit2 <= '0'; BBit3 <= '0'; BBit4 <= '0';
    BBit5 <= '0'; BBit10 <= '0'; BBit11 <= '0'; BBit12 <= '0'; BBit13 <= '0'; BBit14 <= '0'; BBit15 <= '0';
    wait until rising_edge(CLK);

    BBit8 <= '1'; BBit9 <= '1'; BBit10 <= '1'; BBit11 <= '1';
    BBit0 <= '0'; BBit1 <= '0'; BBit2 <= '0'; BBit3 <= '0'; BBit4 <= '0';
    BBit5 <= '0'; BBit6 <= '0'; BBit7 <= '0'; BBit12 <= '0'; BBit13 <= '0'; BBit14 <= '0'; BBit15 <= '0';
    wait until rising_edge(CLK);

    BBit10 <= '1'; BBit11 <= '1'; BBit12 <= '1'; BBit13 <= '1';
    BBit0 <= '0'; BBit1 <= '0'; BBit2 <= '0'; BBit3 <= '0'; BBit4 <= '0';
    BBit5 <= '0'; BBit6 <= '0'; BBit7 <= '0'; BBit8 <= '0'; BBit9 <= '0'; BBit14 <= '0'; BBit15 <= '0';
    wait until rising_edge(CLK);

    BBit12 <= '1'; BBit13 <= '1'; BBit14 <= '1'; BBit15 <= '1';
    BBit0 <= '0'; BBit1 <= '0'; BBit2 <= '0'; BBit3 <= '0'; BBit4 <= '0';
    BBit5 <= '0'; BBit6 <= '0'; BBit7 <= '0'; BBit8 <= '0'; BBit9 <= '0'; BBit10 <= '0'; BBit11 <= '0';
    wait until rising_edge(CLK);

    BBit0 <= '1'; BBit1 <= '1'; BBit2 <= '1'; BBit3 <= '1'; BBit4 <= '1';
    BBit5 <= '1'; BBit6 <= '1'; BBit7 <= '1'; BBit8 <= '1'; BBit9 <= '1';
    BBit10 <= '1'; BBit11 <= '1'; BBit12 <= '1'; BBit13 <= '1'; BBit14 <= '1'; BBit15 <= '1';
    wait until rising_edge(CLK);

    BBit0 <= '1'; BBit1 <= '1'; BBit2 <= '1'; BBit3 <= '1'; BBit4 <= '1';
    BBit5 <= '1'; BBit6 <= '1'; BBit7 <= '1'; BBit8 <= '1'; BBit9 <= '1';
    BBit10 <= '1'; BBit11 <= '1'; BBit12 <= '1'; BBit13 <= '1'; BBit14 <= '1'; BBit15 <= '1';
    wait until rising_edge(CLK);
end procedure;

procedure O_sign is
begin
    BBit4 <= '1'; BBit5 <= '1'; BBit6 <= '1'; BBit7 <= '1';
    BBit8 <= '1'; BBit9 <= '1'; BBit10 <= '1'; BBit11 <= '1';
    BBit0 <= '0'; BBit1 <= '0'; BBit2 <= '0'; BBit3 <= '0';
    BBit12 <= '0'; BBit13 <= '0'; BBit14 <= '0'; BBit15 <= '0';
    wait until rising_edge(CLK);

    BBit2 <= '1'; BBit3 <= '1'; BBit4 <= '1'; BBit5 <= '1';
    BBit6 <= '1'; BBit7 <= '1'; BBit8 <= '1'; BBit9 <= '1';
    BBit10 <= '1'; BBit11 <= '1'; BBit12 <= '1'; BBit13 <= '1';
    BBit0 <= '0'; BBit1 <= '0'; BBit14 <= '0'; BBit15 <= '0';
    wait until rising_edge(CLK);

    BBit2 <= '1'; BBit3 <= '1'; BBit4 <= '1'; BBit5 <= '1';
    BBit6 <= '1'; BBit7 <= '1'; BBit8 <= '1'; BBit9 <= '1';
    BBit10 <= '1'; BBit11 <= '1'; BBit12 <= '1'; BBit13 <= '1';
    BBit0 <= '0'; BBit1 <= '0'; BBit14 <= '0'; BBit15 <= '0';
    wait until rising_edge(CLK);

    BBit0 <= '1'; BBit1 <= '1'; BBit2 <= '1'; BBit3 <= '1';
    BBit4 <= '1'; BBit5 <= '1'; BBit6 <= '1'; BBit7 <= '1';
    BBit8 <= '1'; BBit9 <= '1'; BBit10 <= '1'; BBit11 <= '1';
    BBit12 <= '1'; BBit13 <= '1'; BBit14 <= '1'; BBit15 <= '1';
    wait until rising_edge(CLK);

    BBit0 <= '1'; BBit1 <= '1'; BBit14 <= '1'; BBit15 <= '1';
    BBit2 <= '0'; BBit3 <= '0'; BBit4 <= '0'; BBit5 <= '0';
    BBit6 <= '0'; BBit7 <= '0'; BBit8 <= '0'; BBit9 <= '0';
    BBit10 <= '0'; BBit11 <= '0'; BBit12 <= '0'; BBit13 <= '0';
    wait until rising_edge(CLK);

    BBit0 <= '1'; BBit1 <= '1'; BBit14 <= '1'; BBit15 <= '1';
    BBit2 <= '0'; BBit3 <= '0'; BBit4 <= '0'; BBit5 <= '0';
    BBit6 <= '0'; BBit7 <= '0'; BBit8 <= '0'; BBit9 <= '0';
    BBit10 <= '0'; BBit11 <= '0'; BBit12 <= '0'; BBit13 <= '0';
    wait until rising_edge(CLK);

    BBit0 <= '1'; BBit1 <= '1'; BBit14 <= '1'; BBit15 <= '1';
    BBit2 <= '0'; BBit3 <= '0'; BBit4 <= '0'; BBit5 <= '0';
    BBit6 <= '0'; BBit7 <= '0'; BBit8 <= '0'; BBit9 <= '0';
    BBit10 <= '0'; BBit11 <= '0'; BBit12 <= '0'; BBit13 <= '0';
    wait until rising_edge(CLK);

    BBit0 <= '1'; BBit1 <= '1'; BBit2 <= '1'; BBit3 <= '1';
    BBit4 <= '1'; BBit5 <= '1'; BBit6 <= '1'; BBit7 <= '1';
    BBit8 <= '1'; BBit9 <= '1'; BBit10 <= '1'; BBit11 <= '1';
    BBit12 <= '1'; BBit13 <= '1'; BBit14 <= '1'; BBit15 <= '1';
    wait until rising_edge(CLK);

    BBit2 <= '1'; BBit3 <= '1'; BBit4 <= '1'; BBit5 <= '1';
    BBit6 <= '1'; BBit7 <= '1'; BBit8 <= '1'; BBit9 <= '1';
    BBit10 <= '1'; BBit11 <= '1'; BBit12 <= '1'; BBit13 <= '1';
    BBit0 <= '0'; BBit1 <= '0'; BBit14 <= '0'; BBit15 <= '0';
    wait until rising_edge(CLK);

    BBit2 <= '1'; BBit3 <= '1'; BBit4 <= '1'; BBit5 <= '1';
    BBit6 <= '1'; BBit7 <= '1'; BBit8 <= '1'; BBit9 <= '1';
    BBit10 <= '1'; BBit11 <= '1'; BBit12 <= '1'; BBit13 <= '1';
    BBit0 <= '0'; BBit1 <= '0'; BBit14 <= '0'; BBit15 <= '0';
    wait until rising_edge(CLK);

    BBit4 <= '1'; BBit5 <= '1'; BBit6 <= '1'; BBit7 <= '1';
    BBit8 <= '1'; BBit9 <= '1'; BBit10 <= '1'; BBit11 <= '1';
    BBit0 <= '0'; BBit1 <= '0'; BBit2 <= '0'; BBit3 <= '0';
    BBit12 <= '0'; BBit13 <= '0'; BBit14 <= '0'; BBit15 <= '0';
    wait until rising_edge(CLK);
end procedure;

procedure P_sign is
begin
    BBit0 <= '1'; BBit1 <= '1'; BBit2 <= '1'; BBit3 <= '1'; BBit4 <= '1';
    BBit5 <= '1'; BBit6 <= '1'; BBit7 <= '1'; BBit8 <= '1'; BBit9 <= '1';
    BBit10 <= '1'; BBit11 <= '1'; BBit12 <= '1'; BBit13 <= '1'; BBit14 <= '1'; BBit15 <= '1';
    wait until rising_edge(CLK);

    BBit0 <= '1'; BBit1 <= '1'; BBit2 <= '1'; BBit3 <= '1'; BBit4 <= '1';
    BBit5 <= '1'; BBit6 <= '1'; BBit7 <= '1'; BBit8 <= '1'; BBit9 <= '1';
    BBit10 <= '1'; BBit11 <= '1'; BBit12 <= '1'; BBit13 <= '1'; BBit14 <= '1'; BBit15 <= '1';
    wait until rising_edge(CLK);

    BBit0 <= '1'; BBit1 <= '1'; BBit5 <= '1'; BBit6 <= '1';
    BBit2 <= '0'; BBit3 <= '0'; BBit4 <= '0'; BBit7 <= '0'; BBit8 <= '0';
    BBit9 <= '0'; BBit10 <= '0'; BBit11 <= '0'; BBit12 <= '0'; BBit13 <= '0'; BBit14 <= '0'; BBit15 <= '0';
    wait until rising_edge(CLK);

    BBit0 <= '1'; BBit1 <= '1'; BBit5 <= '1'; BBit6 <= '1';
    BBit2 <= '0'; BBit3 <= '0'; BBit4 <= '0'; BBit7 <= '0'; BBit8 <= '0';
    BBit9 <= '0'; BBit10 <= '0'; BBit11 <= '0'; BBit12 <= '0'; BBit13 <= '0'; BBit14 <= '0'; BBit15 <= '0';
    wait until rising_edge(CLK);

    BBit0 <= '1'; BBit1 <= '1'; BBit5 <= '1'; BBit6 <= '1';
    BBit2 <= '0'; BBit3 <= '0'; BBit4 <= '0'; BBit7 <= '0'; BBit8 <= '0';
    BBit9 <= '0'; BBit10 <= '0'; BBit11 <= '0'; BBit12 <= '0'; BBit13 <= '0'; BBit14 <= '0'; BBit15 <= '0';
    wait until rising_edge(CLK);

    BBit0 <= '1'; BBit1 <= '1'; BBit2 <= '1'; BBit3 <= '1'; BBit4 <= '1';
    BBit5 <= '1'; BBit6 <= '1';
    BBit7 <= '0'; BBit8 <= '0'; BBit9 <= '0'; BBit10 <= '0'; BBit11 <= '0';
    BBit12 <= '0'; BBit13 <= '0'; BBit14 <= '0'; BBit15 <= '0';
    wait until rising_edge(CLK);
end procedure;

procedure Q_sign is
begin
    BBit0 <= '1'; BBit1 <= '1'; BBit2 <= '1'; BBit3 <= '1';
    BBit4 <= '1'; BBit5 <= '1'; BBit6 <= '1'; BBit7 <= '1';
    BBit8 <= '1'; BBit9 <= '1'; BBit10 <= '1'; BBit11 <= '1';
    BBit12 <= '1'; BBit13 <= '1'; BBit14 <= '1'; BBit15 <= '1';
    wait until rising_edge(CLK);

    BBit0 <= '1'; BBit1 <= '1'; BBit2 <= '1'; BBit3 <= '1';
    BBit4 <= '1'; BBit5 <= '1'; BBit6 <= '1'; BBit7 <= '1';
    BBit8 <= '1'; BBit9 <= '1'; BBit10 <= '1'; BBit11 <= '1';
    BBit12 <= '1'; BBit13 <= '1'; BBit14 <= '1'; BBit15 <= '1';
    wait until rising_edge(CLK);

    BBit0 <= '1'; BBit1 <= '1'; BBit11 <= '1'; BBit12 <= '1'; BBit13 <= '1'; BBit14 <= '1'; BBit15 <= '1';
    BBit2 <= '0'; BBit3 <= '0'; BBit4 <= '0'; BBit5 <= '0'; BBit6 <= '0'; BBit7 <= '0'; BBit8 <= '0';
    BBit9 <= '0'; BBit10 <= '0';
    wait until rising_edge(CLK);

    BBit0 <= '1'; BBit1 <= '1'; BBit11 <= '1'; BBit12 <= '1'; BBit15 <= '1';
    BBit2 <= '0'; BBit3 <= '0'; BBit4 <= '0'; BBit5 <= '0'; BBit6 <= '0'; BBit7 <= '0'; BBit8 <= '0';
    BBit9 <= '0'; BBit10 <= '0'; BBit13 <= '0'; BBit14 <= '0';
    wait until rising_edge(CLK);

    BBit0 <= '1'; BBit1 <= '1'; BBit11 <= '1'; BBit12 <= '1'; BBit15 <= '1';
    BBit2 <= '0'; BBit3 <= '0'; BBit4 <= '0'; BBit5 <= '0'; BBit6 <= '0'; BBit7 <= '0'; BBit8 <= '0';
    BBit9 <= '0'; BBit10 <= '0'; BBit13 <= '0'; BBit14 <= '0';
    wait until rising_edge(CLK);

    BBit0 <= '1'; BBit1 <= '1'; BBit2 <= '1'; BBit3 <= '1';
    BBit4 <= '1'; BBit5 <= '1'; BBit6 <= '1'; BBit7 <= '1';
    BBit8 <= '1'; BBit9 <= '1'; BBit10 <= '1'; BBit11 <= '1';
    BBit12 <= '1'; BBit15 <= '1';
    BBit13 <= '0'; BBit14 <= '0';
    wait until rising_edge(CLK);

    BBit0 <= '1'; BBit1 <= '1'; BBit2 <= '1'; BBit3 <= '1';
    BBit4 <= '1'; BBit5 <= '1'; BBit6 <= '1'; BBit7 <= '1';
    BBit8 <= '1'; BBit9 <= '1'; BBit10 <= '1'; BBit11 <= '1';
    BBit12 <= '1'; BBit15 <= '1';
    BBit13 <= '0'; BBit14 <= '0';
    wait until rising_edge(CLK);
end procedure;

procedure R_sign is
begin
    BBit0 <= '1'; BBit1 <= '1'; BBit2 <= '1'; BBit3 <= '1'; BBit4 <= '1';
    BBit5 <= '1'; BBit6 <= '1'; BBit7 <= '1'; BBit8 <= '1'; BBit9 <= '1';
    BBit10 <= '1'; BBit11 <= '1'; BBit12 <= '1'; BBit13 <= '1'; BBit14 <= '1'; BBit15 <= '1';
    wait until rising_edge(CLK);

    BBit0 <= '1'; BBit1 <= '1'; BBit2 <= '1'; BBit3 <= '1'; BBit4 <= '1';
    BBit5 <= '1'; BBit6 <= '1'; BBit7 <= '1'; BBit8 <= '1'; BBit9 <= '1';
    BBit10 <= '1'; BBit11 <= '1'; BBit12 <= '1'; BBit13 <= '1'; BBit14 <= '1'; BBit15 <= '1';
    wait until rising_edge(CLK);

    BBit0 <= '1'; BBit1 <= '1'; BBit5 <= '1'; BBit6 <= '1'; BBit7 <= '1'; BBit8 <= '1'; BBit9 <= '1';
    BBit2 <= '0'; BBit3 <= '0'; BBit4 <= '0'; BBit10 <= '0'; BBit11 <= '0'; BBit12 <= '0'; BBit13 <= '0'; BBit14 <= '0'; BBit15 <= '0';
    wait until rising_edge(CLK);

    BBit0 <= '1'; BBit1 <= '1'; BBit5 <= '1'; BBit6 <= '1'; BBit7 <= '1'; BBit8 <= '1'; BBit9 <= '1';
    BBit2 <= '0'; BBit3 <= '0'; BBit4 <= '0'; BBit10 <= '0'; BBit11 <= '0'; BBit12 <= '0'; BBit13 <= '0'; BBit14 <= '0'; BBit15 <= '0';
    wait until rising_edge(CLK);

    BBit0 <= '1'; BBit1 <= '1'; BBit5 <= '1';
    BBit6 <= '1'; BBit10 <= '1'; BBit11 <= '1'; BBit12 <= '1'; BBit13 <= '1'; BBit14 <= '1'; BBit15 <= '1';
    BBit2 <= '0'; BBit3 <= '0'; BBit4 <= '0'; BBit7 <= '0'; BBit8 <= '0'; BBit9 <= '0';
    wait until rising_edge(CLK);

    BBit0 <= '1'; BBit1 <= '1'; BBit2 <= '1'; BBit3 <= '1'; BBit4 <= '1'; BBit5 <= '1'; BBit6 <= '1';
    BBit10 <= '1'; BBit11 <= '1'; BBit12 <= '1'; BBit13 <= '1'; BBit14 <= '1'; BBit15 <= '1';
    BBit7 <= '0'; BBit8 <= '0'; BBit9 <= '0';
    wait until rising_edge(CLK);
end procedure;

procedure S_sign is
begin
    BBit0 <= '1'; BBit1 <= '1'; BBit2 <= '1'; BBit3 <= '1';
    BBit4 <= '1'; BBit5 <= '1'; BBit6 <= '1'; BBit7 <= '1';
    BBit8 <= '1'; BBit9 <= '1'; BBit13 <= '1'; BBit14 <= '1'; BBit15 <= '1';
    BBit10 <= '0'; BBit11 <= '0'; BBit12 <= '0';
    wait until rising_edge(CLK);

    BBit0 <= '1'; BBit1 <= '1'; BBit2 <= '1'; BBit3 <= '1';
    BBit4 <= '1'; BBit5 <= '1'; BBit6 <= '1'; BBit7 <= '1';
    BBit8 <= '1'; BBit9 <= '1'; BBit13 <= '1'; BBit14 <= '1'; BBit15 <= '1';
    BBit10 <= '0'; BBit11 <= '0'; BBit12 <= '0';
    wait until rising_edge(CLK);

    BBit0 <= '1'; BBit1 <= '1'; BBit2 <= '1'; BBit3 <= '1';
    BBit7 <= '1'; BBit8 <= '1'; BBit9 <= '1'; BBit13 <= '1'; BBit14 <= '1'; BBit15 <= '1';
    BBit4 <= '0'; BBit5 <= '0'; BBit6 <= '0'; BBit10 <= '0'; BBit11 <= '0'; BBit12 <= '0';
    wait until rising_edge(CLK);

    BBit0 <= '1'; BBit1 <= '1'; BBit2 <= '1'; BBit3 <= '1';
    BBit7 <= '1'; BBit8 <= '1'; BBit9 <= '1'; BBit13 <= '1'; BBit14 <= '1'; BBit15 <= '1';
    BBit4 <= '0'; BBit5 <= '0'; BBit6 <= '0'; BBit10 <= '0'; BBit11 <= '0'; BBit12 <= '0';
    wait until rising_edge(CLK);

    BBit0 <= '1'; BBit1 <= '1'; BBit2 <= '1'; BBit3 <= '1';
    BBit7 <= '1'; BBit8 <= '1'; BBit9 <= '1'; BBit10 <= '1'; BBit11 <= '1';
    BBit12 <= '1'; BBit13 <= '1'; BBit14 <= '1'; BBit15 <= '1';
    wait until rising_edge(CLK);

    BBit0 <= '1'; BBit1 <= '1'; BBit2 <= '1'; BBit3 <= '1';
    BBit7 <= '1'; BBit8 <= '1'; BBit9 <= '1'; BBit10 <= '1'; BBit11 <= '1';
    BBit12 <= '1'; BBit13 <= '1'; BBit14 <= '1'; BBit15 <= '1';
    wait until rising_edge(CLK);
end procedure;

procedure T_sign is
begin
    BBit0 <= '1'; BBit1 <= '1'; BBit2 <= '1';
    BBit3 <= '0'; BBit4 <= '0'; BBit5 <= '0'; BBit6 <= '0'; BBit7 <= '0';
    BBit8 <= '0'; BBit9 <= '0'; BBit10 <= '0'; BBit11 <= '0'; BBit12 <= '0';
    BBit13 <= '0'; BBit14 <= '0'; BBit15 <= '0';
    wait until rising_edge(CLK);

    BBit0 <= '1'; BBit1 <= '1'; BBit2 <= '1';
    BBit3 <= '0'; BBit4 <= '0'; BBit5 <= '0'; BBit6 <= '0'; BBit7 <= '0';
    BBit8 <= '0'; BBit9 <= '0'; BBit10 <= '0'; BBit11 <= '0'; BBit12 <= '0';
    BBit13 <= '0'; BBit14 <= '0'; BBit15 <= '0';
    wait until rising_edge(CLK);

    BBit0 <= '1'; BBit1 <= '1'; BBit2 <= '1';
    BBit3 <= '0'; BBit4 <= '0'; BBit5 <= '0'; BBit6 <= '0'; BBit7 <= '0';
    BBit8 <= '0'; BBit9 <= '0'; BBit10 <= '0'; BBit11 <= '0'; BBit12 <= '0';
    BBit13 <= '0'; BBit14 <= '0'; BBit15 <= '0';
    wait until rising_edge(CLK);

    BBit0 <= '1'; BBit1 <= '1'; BBit2 <= '1';
    BBit3 <= '0'; BBit4 <= '0'; BBit5 <= '0'; BBit6 <= '0'; BBit7 <= '0';
    BBit8 <= '0'; BBit9 <= '0'; BBit10 <= '0'; BBit11 <= '0'; BBit12 <= '0';
    BBit13 <= '0'; BBit14 <= '0'; BBit15 <= '0';
    wait until rising_edge(CLK);

    BBit0 <= '1'; BBit1 <= '1'; BBit2 <= '1'; BBit3 <= '1'; BBit4 <= '1';
    BBit5 <= '1'; BBit6 <= '1'; BBit7 <= '1'; BBit8 <= '1'; BBit9 <= '1';
    BBit10 <= '1'; BBit11 <= '1'; BBit12 <= '1'; BBit13 <= '1'; BBit14 <= '1'; BBit15 <= '1';
    wait until rising_edge(CLK);

    BBit0 <= '1'; BBit1 <= '1'; BBit2 <= '1'; BBit3 <= '1'; BBit4 <= '1';
    BBit5 <= '1'; BBit6 <= '1'; BBit7 <= '1'; BBit8 <= '1'; BBit9 <= '1';
    BBit10 <= '1'; BBit11 <= '1'; BBit12 <= '1'; BBit13 <= '1'; BBit14 <= '1'; BBit15 <= '1';
    wait until rising_edge(CLK);

    BBit0 <= '1'; BBit1 <= '1'; BBit2 <= '1';
    BBit3 <= '0'; BBit4 <= '0'; BBit5 <= '0'; BBit6 <= '0'; BBit7 <= '0';
    BBit8 <= '0'; BBit9 <= '0'; BBit10 <= '0'; BBit11 <= '0'; BBit12 <= '0';
    BBit13 <= '0'; BBit14 <= '0'; BBit15 <= '0';
    wait until rising_edge(CLK);

    BBit0 <= '1'; BBit1 <= '1'; BBit2 <= '1';
    BBit3 <= '0'; BBit4 <= '0'; BBit5 <= '0'; BBit6 <= '0'; BBit7 <= '0';
    BBit8 <= '0'; BBit9 <= '0'; BBit10 <= '0'; BBit11 <= '0'; BBit12 <= '0';
    BBit13 <= '0'; BBit14 <= '0'; BBit15 <= '0';
    wait until rising_edge(CLK);

    BBit0 <= '1'; BBit1 <= '1'; BBit2 <= '1';
    BBit3 <= '0'; BBit4 <= '0'; BBit5 <= '0'; BBit6 <= '0'; BBit7 <= '0';
    BBit8 <= '0'; BBit9 <= '0'; BBit10 <= '0'; BBit11 <= '0'; BBit12 <= '0';
    BBit13 <= '0'; BBit14 <= '0'; BBit15 <= '0';
    wait until rising_edge(CLK);

    BBit0 <= '1'; BBit1 <= '1'; BBit2 <= '1';
    BBit3 <= '0'; BBit4 <= '0'; BBit5 <= '0'; BBit6 <= '0'; BBit7 <= '0';
    BBit8 <= '0'; BBit9 <= '0'; BBit10 <= '0'; BBit11 <= '0'; BBit12 <= '0';
    BBit13 <= '0'; BBit14 <= '0'; BBit15 <= '0';
    wait until rising_edge(CLK);
end procedure;

procedure U_sign is
begin
    BBit0 <= '1'; BBit1 <= '1'; BBit2 <= '1'; BBit3 <= '1'; BBit4 <= '1';
    BBit5 <= '1'; BBit6 <= '1'; BBit7 <= '1'; BBit8 <= '1'; BBit9 <= '1';
    BBit10 <= '1'; BBit11 <= '1'; BBit12 <= '1'; BBit13 <= '1'; BBit14 <= '1'; BBit15 <= '1';
    wait until rising_edge(CLK);

    BBit0 <= '1'; BBit1 <= '1'; BBit2 <= '1'; BBit3 <= '1'; BBit4 <= '1';
    BBit5 <= '1'; BBit6 <= '1'; BBit7 <= '1'; BBit8 <= '1'; BBit9 <= '1';
    BBit10 <= '1'; BBit11 <= '1'; BBit12 <= '1'; BBit13 <= '1'; BBit14 <= '1'; BBit15 <= '1';
    wait until rising_edge(CLK);

    BBit13 <= '1'; BBit14 <= '1'; BBit15 <= '1';
    BBit0 <= '0'; BBit1 <= '0'; BBit2 <= '0'; BBit3 <= '0'; BBit4 <= '0';
    BBit5 <= '0'; BBit6 <= '0'; BBit7 <= '0'; BBit8 <= '0'; BBit9 <= '0';
    BBit10 <= '0'; BBit11 <= '0'; BBit12 <= '0';
    wait until rising_edge(CLK);

    BBit13 <= '1'; BBit14 <= '1'; BBit15 <= '1';
    BBit0 <= '0'; BBit1 <= '0'; BBit2 <= '0'; BBit3 <= '0'; BBit4 <= '0';
    BBit5 <= '0'; BBit6 <= '0'; BBit7 <= '0'; BBit8 <= '0'; BBit9 <= '0';
    BBit10 <= '0'; BBit11 <= '0'; BBit12 <= '0';
    wait until rising_edge(CLK);

    BBit13 <= '1'; BBit14 <= '1'; BBit15 <= '1';
    BBit0 <= '0'; BBit1 <= '0'; BBit2 <= '0'; BBit3 <= '0'; BBit4 <= '0';
    BBit5 <= '0'; BBit6 <= '0'; BBit7 <= '0'; BBit8 <= '0'; BBit9 <= '0';
    BBit10 <= '0'; BBit11 <= '0'; BBit12 <= '0';
    wait until rising_edge(CLK);

    BBit13 <= '1'; BBit14 <= '1'; BBit15 <= '1';
    BBit0 <= '0'; BBit1 <= '0'; BBit2 <= '0'; BBit3 <= '0'; BBit4 <= '0';
    BBit5 <= '0'; BBit6 <= '0'; BBit7 <= '0'; BBit8 <= '0'; BBit9 <= '0';
    BBit10 <= '0'; BBit11 <= '0'; BBit12 <= '0';
    wait until rising_edge(CLK);

    BBit0 <= '1'; BBit1 <= '1'; BBit2 <= '1'; BBit3 <= '1'; BBit4 <= '1';
    BBit5 <= '1'; BBit6 <= '1'; BBit7 <= '1'; BBit8 <= '1'; BBit9 <= '1';
    BBit10 <= '1'; BBit11 <= '1'; BBit12 <= '1'; BBit13 <= '1'; BBit14 <= '1'; BBit15 <= '1';
    wait until rising_edge(CLK);

    BBit0 <= '1'; BBit1 <= '1'; BBit2 <= '1'; BBit3 <= '1'; BBit4 <= '1';
    BBit5 <= '1'; BBit6 <= '1'; BBit7 <= '1'; BBit8 <= '1'; BBit9 <= '1';
    BBit10 <= '1'; BBit11 <= '1'; BBit12 <= '1'; BBit13 <= '1'; BBit14 <= '1'; BBit15 <= '1';
    wait until rising_edge(CLK);
end procedure;

procedure V_sign is
begin
    BBit0 <= '1'; BBit1 <= '1'; BBit2 <= '1'; BBit3 <= '1';
    BBit4 <= '0'; BBit5 <= '0'; BBit6 <= '0'; BBit7 <= '0'; BBit8 <= '0';
    BBit9 <= '0'; BBit10 <= '0'; BBit11 <= '0'; BBit12 <= '0'; BBit13 <= '0'; BBit14 <= '0'; BBit15 <= '0';
    wait until rising_edge(CLK);

    BBit0 <= '1'; BBit1 <= '1'; BBit2 <= '1'; BBit3 <= '1';
    BBit4 <= '0'; BBit5 <= '0'; BBit6 <= '0'; BBit7 <= '0'; BBit8 <= '0';
    BBit9 <= '0'; BBit10 <= '0'; BBit11 <= '0'; BBit12 <= '0'; BBit13 <= '0'; BBit14 <= '0'; BBit15 <= '0';
    wait until rising_edge(CLK);

    BBit4 <= '1'; BBit5 <= '1'; BBit6 <= '1'; BBit7 <= '1'; BBit8 <= '1';
    BBit0 <= '0'; BBit1 <= '0'; BBit2 <= '0'; BBit3 <= '0';
    BBit9 <= '0'; BBit10 <= '0'; BBit11 <= '0'; BBit12 <= '0'; BBit13 <= '0'; BBit14 <= '0'; BBit15 <= '0';
    wait until rising_edge(CLK);

    BBit4 <= '1'; BBit5 <= '1'; BBit6 <= '1'; BBit7 <= '1'; BBit8 <= '1';
    BBit0 <= '0'; BBit1 <= '0'; BBit2 <= '0'; BBit3 <= '0';
    BBit9 <= '0'; BBit10 <= '0'; BBit11 <= '0'; BBit12 <= '0'; BBit13 <= '0'; BBit14 <= '0'; BBit15 <= '0';
    wait until rising_edge(CLK);

    BBit9 <= '1'; BBit10 <= '1'; BBit11 <= '1'; BBit12 <= '1'; BBit13 <= '1';
    BBit0 <= '0'; BBit1 <= '0'; BBit2 <= '0'; BBit3 <= '0'; BBit4 <= '0'; BBit5 <= '0';
    BBit6 <= '0'; BBit7 <= '0'; BBit8 <= '0'; BBit14 <= '0'; BBit15 <= '0';
    wait until rising_edge(CLK);

    BBit9 <= '1'; BBit10 <= '1'; BBit11 <= '1'; BBit12 <= '1'; BBit13 <= '1';
    BBit0 <= '0'; BBit1 <= '0'; BBit2 <= '0'; BBit3 <= '0'; BBit4 <= '0'; BBit5 <= '0';
    BBit6 <= '0'; BBit7 <= '0'; BBit8 <= '0'; BBit14 <= '0'; BBit15 <= '0';
    wait until rising_edge(CLK);

    BBit14 <= '1'; BBit15 <= '1';
    BBit0 <= '0'; BBit1 <= '0'; BBit2 <= '0'; BBit3 <= '0'; BBit4 <= '0';
    BBit5 <= '0'; BBit6 <= '0'; BBit7 <= '0'; BBit8 <= '0'; BBit9 <= '0';
    BBit10 <= '0'; BBit11 <= '0'; BBit12 <= '0'; BBit13 <= '0';
    wait until rising_edge(CLK);

    BBit14 <= '1'; BBit15 <= '1';
    BBit0 <= '0'; BBit1 <= '0'; BBit2 <= '0'; BBit3 <= '0'; BBit4 <= '0';
    BBit5 <= '0'; BBit6 <= '0'; BBit7 <= '0'; BBit8 <= '0'; BBit9 <= '0';
    BBit10 <= '0'; BBit11 <= '0'; BBit12 <= '0'; BBit13 <= '0';
    wait until rising_edge(CLK);

    BBit9 <= '1'; BBit10 <= '1'; BBit11 <= '1'; BBit12 <= '1'; BBit13 <= '1';
    BBit0 <= '0'; BBit1 <= '0'; BBit2 <= '0'; BBit3 <= '0'; BBit4 <= '0'; BBit5 <= '0';
    BBit6 <= '0'; BBit7 <= '0'; BBit8 <= '0'; BBit14 <= '0'; BBit15 <= '0';
    wait until rising_edge(CLK);

    BBit9 <= '1'; BBit10 <= '1'; BBit11 <= '1'; BBit12 <= '1'; BBit13 <= '1';
    BBit0 <= '0'; BBit1 <= '0'; BBit2 <= '0'; BBit3 <= '0'; BBit4 <= '0'; BBit5 <= '0';
    BBit6 <= '0'; BBit7 <= '0'; BBit8 <= '0'; BBit14 <= '0'; BBit15 <= '0';
    wait until rising_edge(CLK);

    BBit4 <= '1'; BBit5 <= '1'; BBit6 <= '1'; BBit7 <= '1'; BBit8 <= '1';
    BBit0 <= '0'; BBit1 <= '0'; BBit2 <= '0'; BBit3 <= '0';
    BBit9 <= '0'; BBit10 <= '0'; BBit11 <= '0'; BBit12 <= '0'; BBit13 <= '0'; BBit14 <= '0'; BBit15 <= '0';
    wait until rising_edge(CLK);

    BBit4 <= '1'; BBit5 <= '1'; BBit6 <= '1'; BBit7 <= '1'; BBit8 <= '1';
    BBit0 <= '0'; BBit1 <= '0'; BBit2 <= '0'; BBit3 <= '0';
    BBit9 <= '0'; BBit10 <= '0'; BBit11 <= '0'; BBit12 <= '0'; BBit13 <= '0'; BBit14 <= '0'; BBit15 <= '0';
    wait until rising_edge(CLK);

    BBit0 <= '1'; BBit1 <= '1'; BBit2 <= '1'; BBit3 <= '1';
    BBit4 <= '0'; BBit5 <= '0'; BBit6 <= '0'; BBit7 <= '0'; BBit8 <= '0'; 
    BBit9 <= '0'; BBit10 <= '0'; BBit11 <= '0'; BBit12 <= '0'; BBit13 <= '0';
    BBit14 <= '0'; BBit15 <= '0';
    wait until rising_edge(CLK);
end procedure;

procedure W_sign is
begin
    BBit2 <= '1'; BBit3 <= '1'; BBit4 <= '1'; BBit5 <= '1'; BBit6 <= '1';
    BBit7 <= '1'; BBit8 <= '1'; BBit9 <= '1'; BBit10 <= '1'; BBit11 <= '1';
    BBit12 <= '1'; BBit13 <= '1'; BBit14 <= '1'; BBit15 <= '1';
    BBit0 <= '0'; BBit1 <= '0';
    wait until rising_edge(CLK);

    BBit0 <= '0'; BBit1 <= '0'; 
    BBit2 <= '1'; BBit3 <= '1'; BBit4 <= '1'; BBit5 <= '1'; BBit6 <= '1';
    BBit7 <= '1'; BBit8 <= '1'; BBit9 <= '1'; BBit10 <= '1'; BBit11 <= '1';
    BBit12 <= '1'; BBit13 <= '1'; BBit14 <= '1'; BBit15 <= '1';
    wait until rising_edge(CLK);

    BBit13 <= '1'; BBit14 <= '1'; BBit15 <= '1';
    BBit0 <= '0'; BBit1 <= '0'; BBit2 <= '0'; BBit3 <= '0'; BBit4 <= '0';
    BBit5 <= '0'; BBit6 <= '0'; BBit7 <= '0'; BBit8 <= '0'; BBit9 <= '0';
    BBit10 <= '0'; BBit11 <= '0'; BBit12 <= '0';
    wait until rising_edge(CLK);

    BBit13 <= '1'; BBit14 <= '1'; BBit15 <= '1';
    BBit0 <= '0'; BBit1 <= '0'; BBit2 <= '0'; BBit3 <= '0'; BBit4 <= '0';
    BBit5 <= '0'; BBit6 <= '0'; BBit7 <= '0'; BBit8 <= '0'; BBit9 <= '0';
    BBit10 <= '0'; BBit11 <= '0'; BBit12 <= '0';
    wait until rising_edge(CLK);

    BBit2 <= '1'; BBit3 <= '1'; BBit4 <= '1'; BBit5 <= '1'; BBit6 <= '1';
    BBit7 <= '1'; BBit8 <= '1'; BBit9 <= '1'; BBit10 <= '1'; BBit11 <= '1';
    BBit12 <= '1'; BBit13 <= '1'; BBit14 <= '1'; BBit15 <= '1';
    BBit0 <= '0'; BBit1 <= '0';
    wait until rising_edge(CLK);

    BBit0 <= '0'; BBit1 <= '0';
    BBit2 <= '1'; BBit3 <= '1'; BBit4 <= '1'; BBit5 <= '1'; BBit6 <= '1';
    BBit7 <= '1'; BBit8 <= '1'; BBit9 <= '1'; BBit10 <= '1'; BBit11 <= '1';
    BBit12 <= '1'; BBit13 <= '1'; BBit14 <= '1'; BBit15 <= '1';
    wait until rising_edge(CLK);

    BBit13 <= '1'; BBit14 <= '1'; BBit15 <= '1';
    BBit0 <= '0'; BBit1 <= '0'; BBit2 <= '0'; BBit3 <= '0'; BBit4 <= '0';
    BBit5 <= '0'; BBit6 <= '0'; BBit7 <= '0'; BBit8 <= '0'; BBit9 <= '0';
    BBit10 <= '0'; BBit11 <= '0'; BBit12 <= '0';
    wait until rising_edge(CLK);

    BBit13 <= '1'; BBit14 <= '1'; BBit15 <= '1';
    BBit0 <= '0'; BBit1 <= '0'; BBit2 <= '0'; BBit3 <= '0'; BBit4 <= '0';
    BBit5 <= '0'; BBit6 <= '0'; BBit7 <= '0'; BBit8 <= '0'; BBit9 <= '0';
    BBit10 <= '0'; BBit11 <= '0'; BBit12 <= '0';
    wait until rising_edge(CLK);

    BBit2 <= '1'; BBit3 <= '1'; BBit4 <= '1'; BBit5 <= '1'; BBit6 <= '1';
    BBit7 <= '1'; BBit8 <= '1'; BBit9 <= '1'; BBit10 <= '1'; BBit11 <= '1';
    BBit12 <= '1'; BBit13 <= '1'; BBit14 <= '1'; BBit15 <= '1';
    BBit0 <= '0'; BBit1 <= '0';
    wait until rising_edge(CLK);

    BBit0 <= '0'; BBit1 <= '0';
    BBit2 <= '1'; BBit3 <= '1'; BBit4 <= '1'; BBit5 <= '1'; BBit6 <= '1';
    BBit7 <= '1'; BBit8 <= '1'; BBit9 <= '1'; BBit10 <= '1'; BBit11 <= '1';
    BBit12 <= '1'; BBit13 <= '1'; BBit14 <= '1'; BBit15 <= '1';
    wait until rising_edge(CLK);
end procedure;

procedure X_sign is
begin
    BBit0 <= '1'; BBit1 <= '1'; BBit2 <= '1'; BBit3 <= '1'; BBit4 <= '1';
    BBit12 <= '1'; BBit13 <= '1'; BBit14 <= '1'; BBit15 <= '1';
    BBit5 <= '0'; BBit6 <= '0'; BBit7 <= '0'; BBit8 <= '0'; BBit9 <= '0';
    BBit10 <= '0'; BBit11 <= '0';
    wait until rising_edge(CLK);

    BBit0 <= '1'; BBit1 <= '1'; BBit2 <= '1'; BBit3 <= '1'; BBit4 <= '1';
    BBit12 <= '1'; BBit13 <= '1'; BBit14 <= '1'; BBit15 <= '1';
    BBit5 <= '0'; BBit6 <= '0'; BBit7 <= '0'; BBit8 <= '0'; BBit9 <= '0';
    BBit10 <= '0'; BBit11 <= '0';
    wait until rising_edge(CLK);

    BBit5 <= '1'; BBit6 <= '1'; BBit7 <= '1'; BBit10 <= '1'; BBit11 <= '1';
    BBit0 <= '0'; BBit1 <= '0'; BBit2 <= '0'; BBit3 <= '0'; BBit4 <= '0';
    BBit8 <= '0'; BBit9 <= '0'; BBit12 <= '0'; BBit13 <= '0'; BBit14 <= '0'; BBit15 <= '0';
    wait until rising_edge(CLK);

    BBit5 <= '1'; BBit6 <= '1'; BBit7 <= '1'; BBit10 <= '1'; BBit11 <= '1';
    BBit0 <= '0'; BBit1 <= '0'; BBit2 <= '0'; BBit3 <= '0'; BBit4 <= '0';
    BBit8 <= '0'; BBit9 <= '0'; BBit12 <= '0'; BBit13 <= '0'; BBit14 <= '0'; BBit15 <= '0';
    wait until rising_edge(CLK);

    BBit8 <= '1'; BBit9 <= '1';
    BBit0 <= '0'; BBit1 <= '0'; BBit2 <= '0'; BBit3 <= '0'; BBit4 <= '0';
    BBit5 <= '0'; BBit6 <= '0'; BBit7 <= '0'; BBit10 <= '0'; BBit11 <= '0';
    BBit12 <= '0'; BBit13 <= '0'; BBit14 <= '0'; BBit15 <= '0';
    wait until rising_edge(CLK);

    BBit8 <= '1'; BBit9 <= '1';
    BBit0 <= '0'; BBit1 <= '0'; BBit2 <= '0'; BBit3 <= '0'; BBit4 <= '0';
    BBit5 <= '0'; BBit6 <= '0'; BBit7 <= '0'; BBit10 <= '0'; BBit11 <= '0';
    BBit12 <= '0'; BBit13 <= '0'; BBit14 <= '0'; BBit15 <= '0';
    wait until rising_edge(CLK);

    BBit5 <= '1'; BBit6 <= '1'; BBit7 <= '1'; BBit10 <= '1'; BBit11 <= '1';
    BBit0 <= '0'; BBit1 <= '0'; BBit2 <= '0'; BBit3 <= '0'; BBit4 <= '0';
    BBit8 <= '0'; BBit9 <= '0'; BBit12 <= '0'; BBit13 <= '0'; BBit14 <= '0'; BBit15 <= '0';
    wait until rising_edge(CLK);

    BBit5 <= '1'; BBit6 <= '1'; BBit7 <= '1'; BBit10 <= '1'; BBit11 <= '1';
    BBit0 <= '0'; BBit1 <= '0'; BBit2 <= '0'; BBit3 <= '0'; BBit4 <= '0';
    BBit8 <= '0'; BBit9 <= '0'; BBit12 <= '0'; BBit13 <= '0'; BBit14 <= '0'; BBit15 <= '0';
    wait until rising_edge(CLK);

    BBit0 <= '1'; BBit1 <= '1'; BBit2 <= '1'; BBit3 <= '1'; BBit4 <= '1';
    BBit12 <= '1'; BBit13 <= '1'; BBit14 <= '1'; BBit15 <= '1';
    BBit5 <= '0'; BBit6 <= '0'; BBit7 <= '0'; BBit8 <= '0'; BBit9 <= '0';
    BBit10 <= '0'; BBit11 <= '0';
    wait until rising_edge(CLK);

    BBit0 <= '1'; BBit1 <= '1'; BBit2 <= '1'; BBit3 <= '1'; BBit4 <= '1';
    BBit12 <= '1'; BBit13 <= '1'; BBit14 <= '1'; BBit15 <= '1';
    BBit5 <= '0'; BBit6 <= '0'; BBit7 <= '0'; BBit8 <= '0'; BBit9 <= '0';
    BBit10 <= '0'; BBit11 <= '0';
    wait until rising_edge(CLK);
end procedure;

procedure Y_sign is
begin
    BBit0 <= '1'; BBit1 <= '1'; BBit2 <= '1'; BBit3 <= '1'; BBit4 <= '1'; BBit5 <= '1';
    BBit6 <= '0'; BBit7 <= '0'; BBit10 <= '0'; BBit11 <= '0'; BBit12 <= '0'; BBit13 <= '0'; BBit14 <= '0'; BBit15 <= '0';
    BBit8 <= '0'; BBit9 <= '0';
    wait until rising_edge(CLK);

    BBit0 <= '1'; BBit1 <= '1'; BBit2 <= '1'; BBit3 <= '1'; BBit4 <= '1'; BBit5 <= '1';
    BBit6 <= '0'; BBit7 <= '0'; BBit10 <= '0'; BBit11 <= '0'; BBit12 <= '0'; BBit13 <= '0'; BBit14 <= '0'; BBit15 <= '0';
    BBit8 <= '0'; BBit9 <= '0';
    wait until rising_edge(CLK);

    BBit6 <= '1'; BBit7 <= '1'; BBit8 <= '1'; BBit9 <= '1';
    BBit10 <= '1'; BBit11 <= '1'; BBit12 <= '1'; BBit13 <= '1'; BBit14 <= '1'; BBit15 <= '1';
    BBit0 <= '0'; BBit1 <= '0'; BBit2 <= '0'; BBit3 <= '0'; BBit4 <= '0'; BBit5 <= '0';
    wait until rising_edge(CLK);

    BBit6 <= '1'; BBit7 <= '1'; BBit8 <= '1'; BBit9 <= '1';
    BBit10 <= '1'; BBit11 <= '1'; BBit12 <= '1'; BBit13 <= '1'; BBit14 <= '1'; BBit15 <= '1';
    BBit0 <= '0'; BBit1 <= '0'; BBit2 <= '0'; BBit3 <= '0'; BBit4 <= '0'; BBit5 <= '0';
    wait until rising_edge(CLK);

    BBit0 <= '1'; BBit1 <= '1'; BBit2 <= '1'; BBit3 <= '1'; BBit4 <= '1'; BBit5 <= '1';
    BBit6 <= '0'; BBit7 <= '0'; BBit10 <= '0'; BBit11 <= '0'; BBit12 <= '0'; BBit13 <= '0'; BBit14 <= '0'; BBit15 <= '0';
    BBit8 <= '0'; BBit9 <= '0';
    wait until rising_edge(CLK);

    BBit0 <= '1'; BBit1 <= '1'; BBit2 <= '1'; BBit3 <= '1'; BBit4 <= '1'; BBit5 <= '1';
    BBit6 <= '0'; BBit7 <= '0'; BBit10 <= '0'; BBit11 <= '0'; BBit12 <= '0'; BBit13 <= '0'; BBit14 <= '0'; BBit15 <= '0';
    BBit8 <= '0'; BBit9 <= '0';
    wait until rising_edge(CLK);
end procedure;

procedure Z_sign is
begin 
    wait until rising_edge(CLK);
    BBit0 <= '1'; BBit1 <= '1'; BBit2 <= '1';
    BBit7 <= '1'; BBit8 <= '1'; BBit9 <= '1';
    BBit13 <= '1'; BBit14 <= '1'; BBit15 <= '1';

    wait until rising_edge(CLK);
    BBit0 <= '1'; BBit1 <= '1'; BBit2 <= '1';
    BBit7 <= '1'; BBit8 <= '1'; BBit9 <= '1';
    BBit13 <= '1'; BBit14 <= '1'; BBit15 <= '1';

    wait until rising_edge(CLK);
    BBit0 <= '1'; BBit1 <= '1'; BBit2 <= '1';
    BBit10 <= '1'; BBit11 <= '1'; BBit12 <= '1';
    BBit13 <= '1'; BBit14 <= '1'; BBit15 <= '1';

    wait until rising_edge(CLK);
    BBit0 <= '1'; BBit1 <= '1'; BBit2 <= '1';
    BBit10 <= '1'; BBit11 <= '1'; BBit12 <= '1';
    BBit13 <= '1'; BBit14 <= '1'; BBit15 <= '1';

    wait until rising_edge(CLK);
    BBit0 <= '1'; BBit1 <= '1'; BBit2 <= '1';
    BBit3 <= '1'; BBit4 <= '1';
    BBit13 <= '1'; BBit14 <= '1'; BBit15 <= '1';

    wait until rising_edge(CLK);
    BBit0 <= '1'; BBit1 <= '1'; BBit2 <= '1';
    BBit3 <= '1'; BBit4 <= '1';
    BBit13 <= '1'; BBit14 <= '1'; BBit15 <= '1';

    wait until rising_edge(CLK);
    BBit0 <= '1'; BBit1 <= '1'; BBit2 <= '1';
    BBit5 <= '1'; BBit6 <= '1';
    BBit13 <= '1'; BBit14 <= '1'; BBit15 <= '1';

    wait until rising_edge(CLK);
    BBit0 <= '1'; BBit1 <= '1'; BBit2 <= '1';
    BBit5 <= '1'; BBit6 <= '1';
    BBit13 <= '1'; BBit14 <= '1'; BBit15 <= '1';
end procedure;
--(INFO)
--kita deklar deklar disini 
constant MaxedMessage : integer := 128; --Ini untuk batasan nyimpen messagenya ges (INFO)
subtype 16BitToWord is std_logic_vector(15 downto 0);
type ArrayTemp is array (0 to MaxedMessage - 1) of 16BitToWord; 
signal StoreTemp : ArrayTemp := (others =>(others => '0'));
signal TempPtr : integer := 0;

-----(INFO) Disini, kita defnisikan Password untuk Exit, UP, dkk 
constant UP_Pwd    : std_logic_vector (6 downto 0) := "1111111";
constant Exit_Pwd  : std_logic_vector (6 downto 0) := "0000000";
constant Write_Pwd : std_logic_vector (6 downto 0) := "0001111";
constant ID_Pwd    : std_logic_vector (6 downto 0) := "0001101";

--(INFO)
--kasih subtype array disini untuk permitted words sandi dari tiap machine 
--bisa juga pake RECORD untuk menyesuaikan kata apa yang disesuaikan untuk machine mana
constant W_A : string := "tango"; 
constant W_B : string := "alpha"; 
constant W_C : string := "delta"; 
constant W_D : string := "omega"; 
constant W_E : string := "gorga"; 
constant W_F : string := "fahmi"; 


--(INFO)
--kasih subtype array disini untuk permitted ID dari tiap machine  
--bisa juga pake RECORD untuk menyesuaikan id - kata  apa yang disesuaikan untuk machine mana
constant ID_A : std_logic_vector(6 downto 0) := "0011001";
constant ID_B : std_logic_vector(6 downto 0) := "0011010";
constant ID_C : std_logic_vector(6 downto 0) := "0011011";
constant ID_D : std_logic_vector(6 downto 0) := "1111000";
constant ID_E : std_logic_vector(6 downto 0) := "0101010";
constant ID_F : std_logic_vector(6 downto 0) := "1010100";

--(INFO)
--Ngasi definisi opcode untuk masing - masing procedure sama kayak waktu kita CS terakhir yang bikin CPU
constant O_A : std_logic_vector(4 downto 0) := "11001";
constant O_B : std_logic_vector(4 downto 0) := "11000";
constant O_C : std_logic_vector(4 downto 0) := "10111";
constant O_D : std_logic_vector(4 downto 0) := "10110";
constant O_E : std_logic_vector(4 downto 0) := "10101";
constant O_F : std_logic_vector(4 downto 0) := "10100";
constant O_G : std_logic_vector(4 downto 0) := "10011";
constant O_H : std_logic_vector(4 downto 0) := "10010";
constant O_I : std_logic_vector(4 downto 0) := "10001";
constant O_J : std_logic_vector(4 downto 0) := "10000";
constant O_K : std_logic_vector(4 downto 0) := "01111";
constant O_L : std_logic_vector(4 downto 0) := "01110";
constant O_M : std_logic_vector(4 downto 0) := "01101";
constant O_N : std_logic_vector(4 downto 0) := "01100";
constant O_O : std_logic_vector(4 downto 0) := "01011";
constant O_P : std_logic_vector(4 downto 0) := "01010";
constant O_Q : std_logic_vector(4 downto 0) := "01001";
constant O_R : std_logic_vector(4 downto 0) := "01000";
constant O_S : std_logic_vector(4 downto 0) := "00111";
constant O_T : std_logic_vector(4 downto 0) := "00110";
constant O_U : std_logic_vector(4 downto 0) := "00101";
constant O_V : std_logic_vector(4 downto 0) := "00100";
constant O_W : std_logic_vector(4 downto 0) := "00011";
constant O_X : std_logic_vector(4 downto 0) := "00010";
constant O_Y : std_logic_vector(4 downto 0) := "00001";
constant O_Z : std_logic_vector(4 downto 0) := "00000";

--(INFO)
--definisiin juga opcode buat space 
constant O_SPC : std_logic_vector(4 downto 0) := "11111";

--(INFO)
--definisiin LFSR SEED buat keystream gatau sih gini aja dulu wkwkwkwk
signal lfsr_seed : std_logic_vector(15 downto 0) := "1100001100001100";

---(INFO) 
---Bagian ini sesuaikan bentuk function / procedure /ataupun itu
---PEMANGGILAN PROCEDURE OLEH Messenger Write, jadi harus masukin opcode 1 persatu
procedure Messenger_Write( 
    opcode : in_std_logic_vector(4 downto 0); 
    signal arr_temp : inout ArrayTemp
) is 
    variable key     : std_logic_vector(15 downto 0); 
    variable encrypt : std_logic_vector(4 downto 0); 
begin 
 
    key : rand_keystream_tocrypt;
    encrypt := opcode xor key(4 downto 0);
    arr_temp(TempPtr)(4 downto 0) <= encrypt; 
    arr_temp(TempPtr)(15 downto 5) <= (others => '0'); 

    if TempPtr < MaxedMessage - 1 then 
        TempPtr <= TempPtr + 1; 
    end if;
    end procedure Messenger_Write;
        
--(INFO)
---PEMANGGILAN PROCEDURE OLEH Messenger Read, jadi harus masukin opcode 1 persatu
procedure Messenger_Read(
    cipher : std_logic_vector(4 downto 0);
    key    : std_logic_vector(15 downto 0)
) return std_logic_vector is 
    variable opcode : std_logic_vector(4 downto 0);
begin
    opcode := to_decyrpt(cipher, key);

    case opcode is 
        when O_A => A_sign;
        when O_B => B_sign;
        when O_C => C_sign;
        when O_D => D_sign;
        when O_E => E_sign;
        when O_G => G_sign;
        when O_H => H_sign;
        when O_I => I_sign;
        when O_J => J_sign;
        when O_K => K_sign;
        when O_L => L_sign;
        when O_M => M_sign;
        when O_N => N_sign;
        when O_O => O_sign;
        when O_P => P_sign;
        when O_Q => Q_sign;
        when O_R => R_sign;
        when O_S => S_sign;
        when O_T => T_sign;
        when O_U => U_sign;
        when O_V => V_sign;
        when O_W => W_sign;
        when O_X => X_sign;
        when O_Y => Y_sign;
        when O_Z => Z_sign; 
        when O_SPC => null;
        when others => null; 
        end case; 
        return opcode;
    end procedure Messenger_Read;

--(INFO)
--jadi kalimat yang sudah jadi opcodenya bakal di concatenate lalu dibuat menjadi suatu file txt yang berisikan opcode satu persatu -
-- secara vertikal dan paling bawah ada keystream 

procedure PrintThis_to_TXT(
    signal arr_temp : in ArrayTemp; 
    last_key        : in std_logic_vector(15 downto 0)
) is 
    file msg_file : text open write_mode is "Pesan_Rahasia.txt";
    variable buffer : line;
begin 
    for i in 0 to TempPtr loop 
        write(buffer,arr_temp(i)(4 downto 0)); 
        writeline(msg_file,buffer);
    end loop;
    write(buffer,string'("--------------------")); 
    writeline(msg_file,buffer); 
    write(buffer,string'("Keystream-nya: ")); 
    writeline(msg_file,buffer);    
end procedure PrintThis_to_TXT;

--(INFO)
--disini kita bakal membuat fungsi untuk  mengenerate random keystream yang nantinya akan dimasukan ke 
--opcode setiap procedure  
-- nantinya keystream ini akan di print dalam file txt apabila pesan yang DITULIS sudah terfinalisasi dan akan di PRINT menjadi 
-- file 
impure function rand_keystream_tocrypt return real is
    variable seed     : std_logic_vector(15 downto 0) := : LFSR_SEED; 
    variable feedback : std_logic; 
begin 
    feedback := seed(15) xor seed(13) xor seed(12) xor seed(10);
    seed := seed(14 downto 0) & feedback;
    lfsr_seed <= seed;
    return seed;
end function rand_keystream_tocrypt;

--(INFO)
--disini kita bakal membuat fungsi untuk mendecrypt dengan memasukkan keystream dari file txt 
impure function to_decrypt( 
    cipher : std_logic_vector(4 downto 0);
    key    : std_logic_vector(15 downto 0)
) return std_logic_vector is 
begin 
    return cipher xor key (4 downto 0);         
end function to_decrypt;

--(INFO)
--- setiap opcode yang udh dimasukin sama messenger dalam keadaan write distore ke sebuah TEMP
procedure StoreBBit_to_Temp(
signal arr_temp : inout ArrayTemp
) is 
variable wrote : std_logic_vector(15 downto 0);
begin 
    wrote := BBit0 & BBit1 & BBit2 & BBit3 & BBit4 & BBit5 & BBit6 & BBit7 & BBit8 & BBit9 & BBit10 & BBit11 & BBit12 & BBit13 & BBit14 & BBit15;
    arr_temp(TempPtr) <= wrote; 

    if TempPtr < MaxedMessage - 1 then 
    TempPtr <= TempPtr + 1; 
    end if;
end procedure StoreBBit_to_Temp;

-- (INFO)
--- Samakan password yang dimasukkan dengan variabel PassUp yang diset => true apabila sama langsung ke UP , apabila tidak maka ke DOWN lgi
function Match_UP_Pass(Pwd : std_logic_vector(6 downto 0)) return boolean is 
begin 
    return Pwd = Write_Pwd; 
end function;
        
-- (INFO)
--- pastikan input user adalah EXIT yang diterjemahkan dalam radix format (opsional) untuk ke state down , 
---- panggil print to txt
function Match_Exit_Pass(Pwd : std_logic_vector(6 downto 0)) return boolean is 
begin 
    return Pwd = Exit_Pwd; 
end function;

--(INFO)
--- kek fungsi delete ketika menulis, reset TEMP jadi 000000.....
procedure Reset_Temp(
    signal arr_temp : inout ArrayTemp
) is 
begin 
    for i in to 0 to MaxedMessage-1 loop 
    arr_temp(i) <= (others => '0'); 
    end loop; 
    TempPtr <= 0; 
end procedure Reset_Temp;

--(INFO)
--disini kita bakal membuat fungsi untuk mendecode input radix dari user agar disusun DI CONCAT  input menjadi sebuah kata
function words_input_decode(
B0,B1,B2,B3,B4,B5,B6,B7 : std_logic;
B8,B9,B10,B11,B12,B13,B14,B15 : std_logic
) return string is 
    variable concat : std_logic_vector(15 downto 0); 
    begin 
    concat = B0&B1&B2&B3&B4&B5&B6&B7&B8&B9&B10&B11&B12&B13&B14&B15;
    case concat is 
                when "0000000000000100" => return "tango";
                when "0000000000000110" => return "delta";
                when "0000000000000111" => return "alpha";
                when "0000000000000101" => return "omega";
                when "0000000000001111" => return "gorga";
                when "0000000000001101" => return "fahmi";
                when others => return "tidaktau"; 
    end case; 
end function;

--(INFO)
--disini kita bakal menyamakan input ID dan sandi tiap machine sehingga menjadi step pertama 
function RecordMatching(
    ID : std_logic_vector(6 downto 0); 
    Wordz : string; 
) return boolean is 
        begin 
            if (ID = ID_A and Wordz = W_A) then 
            return true; 
            elsif (ID = ID_B and Wordz = W_B) then 
            return true;
            elsif (ID = ID_C and Wordz = W_C) then 
            return true;
            elsif (ID = ID_D and Wordz = W_D) then 
            return true;
            elsif (ID = ID_E and Wordz = W_E) then 
            return true;
            elsif (ID = ID_F and Wordz = W_F) then 
            return true; 
            else return false; 
        end if; 
end function;     

--(INFO) buat timer
constant CLK_FREQ : integer := -- ini w ga paham kerjanya gimana jadi yauds lah ntaran aja
constant TIME_1S  : integer := CLK_FREQ; 
constant TIME_30S : integer := TIME_1S * 30;
constant TIME_60S : integer := TIME_1S * 30;
signal timer_cnt  : natural := 0;
begin 

---(INFO)
---set kondisi default ke OFF , lalu jalankan logika pada setiao
---KONDISI PADA SETIAP STATE 
process(CLK,RST)
    if RST = '1' then 
        current_state <= OFF; 
        timer_cnt <= 0;
    
    elsif rising_edge(CLK) then
        if current_state = OFF or current_state = HOLD or current_state = LOCK then 
        timer_cnt <= timer_cnt + 1; 
        else
        timer_cnt <= 0; 
        end if;
        
        current_state <= NextState; 
    end if; 
    end process;

process(current_state,en,Pswd,MachID,Option)
begin 
        NextState <= current_state; 
        case current_state is 
---(INFO)
---SAAT OFF
--- en 0 
--- meminta password + ID
--- kalo salah lanjut ke HOLD , kalo bener lanjut ke ACTIVE 
--- bisa ditambahin waktu maksimal pengisian yaitu 60s (KALO MEMUNGKINKAN)
        when OFF 
            if en = '1' then 
                if Match_Machine_ID(MachID) and Match_UP_Pass(Pswd) then 
                NextState <= ACTIVE; 
            else
                NextState <= HOLD; 
            end if; 

            if timer_cnt >= TIME_60s then 
            NextState <= HOLD;
            end if; 
            if timer_cnt >= TIME_60S then 
            NextState <= HOLD; 
            end if; 
----(INFO)
---- set ke READER MODE , hanya bisa baca 
---- terdapat OPTION (0 maka menerima INPUT SERANGKAIAN OPCODE 5 BIT DARI CHIPER TEXT dan akan menperfom fungsi encrypt)
---- Apabila OPTION = 1 maka harus memasukkan user privilege EXEC (analogi aja) password sehingga bisa me-write message , kalo salah maka balik lagi ke READ MODE 
---- Write berarti naik ke UP 
        when ACTIVE => 
        if Option = '0' then 
            null; 
        end if;

        if Option = '1' then 
            if Match_UP_Pass(Pswd) then 
            NextState <= UP; 
            else 
            NextState <= ACTIVE; 
            end if; 
        end if;
----(INFO)
---- Bisa manulis dan nulis nya akan disimpan ke prosedure StoreBBit_to_Temp 
---- Masukkan EXIT pada Signal / Variable EXIT untuk ke DOWN 
        when UP => 
        if Match_Exit_Pass(Pswd) then 
        NextState <= PASSIVE; 
        else 
        NextState <= UP; 
        end if;
---(INFO)
--- meminta password + ID 
--- bisa ditambahin waktu maksimal pengisian yaitu 60s - 30s - 30s (KALO MEMUNGKINKAN)
--- count diincrement sampe 3 kali 
--- kalo masi gagal ke set LOCK 
        when HOLD => 
        if en = '1' then 
            if Match_Machine_ID(MachID) and Match_UP_Pass(Pswd) then
                NextState <= ACTIVE; 
                else 
                NextState <= HOLD; 
            end if; 
        end if;
        if timer_cnt >= TIME_30S then 
        NextState <= LOCK; 
        end if;
----(INFO)
---- wait dulu 60s baru coba lagi sekali , kalo masih gagal maka SELF DESTRUCT (BREAK/FINISH SIMULATION)
---- bisa tambahkan FLAG untuk menambahkan fitur tambahan pada message apabila di read , SELF DESTRUCT apabila pembacaan lebih dari 5 menit, 
---- DestinationFlag untuk menentukan sebenarnya kemana tujuan paket ini untuk dibaca, diconcatenate aja 
        when LOCK => 
        if timer_cnt >= TIME_60S then 
            if Match_Machine_ID(MachID) and Match_UP_Pass({Pswd) then 
            NextState <= ACTIVE; 
            else 
            NextState <= SelfDes; 
            end if; 
        end if;
---(INFO)
---basically cara paling sederhana yaitu set simulasi nya ke infinite loop awokaooaowoakw
        when SelfDes => 
        NextState <= SelfDes; 

        when RESET => 
        NextState <= OFF;
    end case; 
end process; 
end architecture rtl;
