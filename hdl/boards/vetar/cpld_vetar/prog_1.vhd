library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
--
entity prog_1 is
    Port (	
--..................... SPI FLASH signals .................
		ASDO		: inout std_logic;		-- data for SPI in FPGA
		AS_DO		: inout std_logic;		-- data from SPI FLASH
		AS_CLK	: out std_logic;		   -- clock for SPI FLASH
		NCSO		: inout std_logic;		-- chip select from FPGA for SPI FLASH
		AS_DI		: inout std_logic;		-- data for SPI FLASH
		NAS_CS	: inout std_logic;		-- chip select for SPI FLASH
		CONF_D	: inout std_logic_vector(7 downto 0); 	-- conf data for FPGAs
		CCLK	  	: in std_logic;			-- conf. clock  from/to FPGAs
      M        : out std_logic_vector(3 downto 0);
--------------------------------------------------------------
      ADD_I    : in   std_logic_vector(7 downto 0);
      ADD_O    : out  std_logic_vector(7 downto 0);
--------------------------------------------------------------
      AM_I     : in  std_logic_vector(5 downto 0);
      AM_O     : out std_logic_vector(5 downto 0);
-------------------------------------------------------------
end prog_1;
--
	architecture rtl of prog_1 is
--debug
-- ............................. FPGA configuration ............................
	begin
--  AS FLASH, bridge for letting the FPGA access the flash over cpld
      M           <= b'1110';
------------------------------
		AS_DI       <= ASDO;
		CONF_D(0)   <= AS_DO;
		NAS_CS      <= NCSO;
		AS_CLK      <= CCLK;
-----------------------------
      ADD_O       <= ADD_I;
-----------------------------
      AM_O        <= AM_I;
---...................................................................
	end;	
