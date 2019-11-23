----------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Create Date:    14:12:16 11/21/2019
-- Design Name:
-- Module Name:    bcd_2_bin - Behavioral
-- Project Name:
-- Target Devices:
-- Tool versions:
-- Description:
--
-- Dependencies:
--
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE ieee.numeric_std.all;
--this module is for converting a 4 digit BCD number into binary number.
--the range of the input in decimal is 0 to 9999.
entity bcd_2_bin is
generic(
    BIT_WIDTH    : integer := 16;
    ANGLE_WIDTH : integer := 17;
    STAGE       : integer := 8 --(no. of STAGE = XY_WIDTH)
        );
Port ( clk   : in  std_logic;
Reset: in std_logic;
bcd_in_0 : in unsigned (3 downto 0);
bcd_in_10 : in unsigned (3 downto 0);
bcd_in_100 : in unsigned (3 downto 0);
sign : in STD_LOGIC;
Xout    : out unsigned (BIT_WIDTH-1 downto 0);
    Yout    : out unsigned (BIT_WIDTH-1 downto 0));
--bin_out : out STD_LOGIC_VECTOR (16 downto 0) := (others => '0'));
end bcd_2_bin;
architecture Behavioral of bcd_2_bin is

type xyarray is array (natural range <>) of unsigned (BIT_WIDTH-1 downto 0);

type atan_lut is array ( natural range <>) of unsigned (ANGLE_WIDTH-1 downto 0);

 
    constant TAN_ARRAY : atan_lut (0 to STAGE) := (
                         
                          "00010110100000000",  -- 45 degrees
"00001101010010000",  --  26.526 degrees
"00000111000001001",  -- 14.063 degrees
"00000011100100000",  --  7.125 degrees
"00000001110010011",  -- 3.576 degrees
"00000000111001010",  --1.7876 degrees
"00000000011100101",  -- 0.8938 degrees
"00000000001110010",  --0.4469 degrees
"00000000000111001"   --0.2237 degrees
);

begin
 
process(clk,Reset)
VARIABLE b_in_0 : unsigned (3 downto 0) ;
VARIABLE b_in_10 : unsigned (3 downto 0) ;
VARIABLE b_in_100 : unsigned (3 downto 0) ;
VARIABLE b_out_temp : unsigned (10 downto 0) ;
VARIABLE b_out : unsigned (10 downto 0) ;
variable Xoo : unsigned (BIT_WIDTH-1 downto 0);
    variable Yoo : unsigned (BIT_WIDTH-1 downto 0);
variable Xo : unsigned (BIT_WIDTH-1 downto 0);
    variable Yo : unsigned (BIT_WIDTH-1 downto 0);
    variable angle_new: unsigned (ANGLE_WIDTH-1 downto 0);
    variable angle: unsigned (ANGLE_WIDTH-1 downto 0);
    variable copy: unsigned (ANGLE_WIDTH-1 downto 0 );
    variable j   : integer := 0;
    variable sin_sign : std_logic := '0';
    variable cos_sign  : std_logic  := '0';
    variable msbcheck  : std_logic := '0';
    variable flag : std_logic := '0' ;
 begin

     b_in_0  := bcd_in_0;
 b_in_10 := bcd_in_10;
 b_in_100  := bcd_in_100;
 
if(rising_edge(clk)) then
b_out := (bcd_in_0 * "0001")
+(bcd_in_10 * "1010")
+(bcd_in_100 * "1100100") ;
if( sign = '1') then
b_out_temp := (b_out xor "00111111111") + "00000000001";
else
b_out_temp := b_out;
end if;
-- angle_new := b_out_temp & "00000000";
angle_new(0) := '0';
angle_new(1) := '0';
angle_new(2) := '0';
angle_new(3) := '0';
angle_new(4) := '0';
angle_new(5) := '0';
angle_new(6) := '0';
angle_new(7) := '0';
angle_new(8) := b_out_temp(0);
angle_new(9) := b_out_temp(1);
angle_new(10) := b_out_temp(2);
angle_new(11) := b_out_temp(3);
angle_new(12) := b_out_temp(4);
angle_new(13) := b_out_temp(5);
angle_new(14) := b_out_temp(6);
angle_new(15) := b_out_temp(7);
angle_new(16) := b_out_temp(8);

angle := angle_new;

if(angle_new(ANGLE_WIDTH-1) = '1') then
msbcheck := '1';
        else
msbcheck := '0';
        end if;
 
j:=0;
flag:='0';  
if(msbcheck = '1') then

if( angle < "11010011000000000") then -- 110100110 -90 degree , angle in third quadrant
angle_new := "01011010000000000" + angle;  -- 010110100 180 degree, changing to first quadrant angle;
                                                        --for e.g sin(-135)=-sin(45) and cos(-135)=-cos(45)
sin_sign := '1';
cos_sign := '1';
else
angle_new := ( angle xor "11111111111111111") + 1; --angle in fourth quadrant; changing to first quadrant angle;
--simply taking 2's complement; for e.g sin(-45)=sin(45) and cos(-45)=cos(45)
sin_sign := '1';
cos_sign := '0';
end if;
else
if( angle_new > "00101101000000000") then  -- 001011010 90 degree, angle in second quadrant
angle_new := "01011010000000000" + (angle_new xor "11111111111111111") + 1; -- 010110100 180 degree ,changing to first quadrant angle
-- by taking 2's complement and adding 180
-- for e.g sin(135)=sin(-135+180) and cos(135)=-cos(-135+180);
sin_sign := '0';
cos_sign := '1';
else                                             --angle in first quadrant
cos_sign := '0';
sin_sign := '0';
end if;
end if;

Xoo := "0000000010011011"; --0.607
Yoo := "0000000000000000";

while( j < 8 ) loop
Xo := shift_right(Xoo,j);
Yo := shift_right(Yoo,j);
if ( angle_new(ANGLE_WIDTH-1) = '1') then                --checking if angle is negative or positive
Xoo := Xoo + Yo;
Yoo := Yoo + (Xo xor "1111111111111111") + 1;
angle_new := angle_new + TAN_ARRAY(j);
else
Xoo := Xoo + (Yo xor "1111111111111111") + 1;
Yoo := Yoo + Xo;
angle_new := angle_new + (TAN_ARRAY(j) xor "11111111111111111") + 1;
end if;
j := j + 1;

end loop;

if( cos_sign = '1' ) then
Xoo := ( Xoo xor "1111111111111111") + 1;
end if;

if( sin_sign = '1' ) then
Yoo := ( Yoo xor "1111111111111111") + 1;
end if;

Xout <= Xoo ;
         Yout <= Yoo ;

end if;
end process;
end Behavioral;
