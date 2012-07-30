--______________________________________________________________________
--                             VME TO WB INTERFACE
--
--                                CERN,BE/CO-HT 
--______________________________________________________________________
-- File:                       vme64x_pack.vhd                              
--______________________________________________________________________
-- Authors:                                     
--               Pablo Alvarez Sanchez (Pablo.Alvarez.Sanchez@cern.ch)                             
--               Davide Pedretti       (Davide.Pedretti@cern.ch)  
-- Date         06/2012                                                                           
-- Version      v0.01  
--_______________________________________________________________________
--                               GNU LESSER GENERAL PUBLIC LICENSE                                
--                              ------------------------------------    
-- Copyright (c) 2009 - 2011 CERN                           
-- This source file is free software; you can redistribute it and/or modify it under the terms of 
-- the GNU Lesser General Public License as published by the Free Software Foundation; either     
-- version 2.1 of the License, or (at your option) any later version.                             
-- This source is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;       
-- without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.     
-- See the GNU Lesser General Public License for more details.                                    
-- You should have received a copy of the GNU Lesser General Public License along with this       
-- source; if not, download it from http://www.gnu.org/licenses/lgpl-2.1.html                     
---------------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;
package vme64x_pack is
--__________________________________________________________________________________
-- Records:
   type t_rom_cell is
      record
         add : integer;
         len : integer;
      end record;
   type t_cr_add_table is array (natural range <>) of t_rom_cell;

   type t_FSM is
      record
         s_memReq         :  std_logic;
         s_decode         :  std_logic;
         s_dtackOE        :  std_logic;
         s_mainDTACK      :  std_logic;
         s_dataDir        :  std_logic;
         s_dataOE         :  std_logic;
         s_addrDir        :  std_logic;
         s_addrOE         :  std_logic;
         s_DSlatch        :  std_logic;
         s_incrementAddr  :  std_logic;
         s_dataPhase      :  std_logic;
         s_dataToOutput   :  std_logic;
         s_dataToAddrBus  :  std_logic;
         s_transferActive :  std_logic;
         s_2eLatchAddr    :  std_logic_vector(1 downto 0);
         s_retry          :  std_logic;
         s_berr           :  std_logic;
         s_BERR_out       :  std_logic;
      end record;

  --_______________________________________________________________________________
  -- Constants:
   constant DFS              : integer := 2;    -- for accessing at the ADEM's bit 2
   constant XAM_MODE         : integer := 0;  -- for accessing at the ADER's bit 0
   constant clk_period       : std_logic_vector(19 downto 0) := "00000000000000001101";
  --AM table:
   constant c_A24_S_sup      : std_logic_vector(5 downto 0) := "111101";
   constant c_A24_S          : std_logic_vector(5 downto 0) := "111001";
   constant c_A24_BLT        : std_logic_vector(5 downto 0) := "111011";
   constant c_A24_BLT_sup    : std_logic_vector(5 downto 0) := "111111";
   constant c_A24_MBLT       : std_logic_vector(5 downto 0) := "111000";
   constant c_A24_MBLT_sup   : std_logic_vector(5 downto 0) := "111100";
   constant c_A24_LCK        : std_logic_vector(5 downto 0) := "110010";
   constant c_CR_CSR         : std_logic_vector(5 downto 0) := "101111";
   constant c_A16            : std_logic_vector(5 downto 0) := "101001";
   constant c_A16_sup        : std_logic_vector(5 downto 0) := "101101";
   constant c_A16_LCK        : std_logic_vector(5 downto 0) := "101100";
   constant c_A32            : std_logic_vector(5 downto 0) := "001001";
   constant c_A32_sup        : std_logic_vector(5 downto 0) := "001101";
   constant c_A32_BLT        : std_logic_vector(5 downto 0) := "001011";
   constant c_A32_BLT_sup    : std_logic_vector(5 downto 0) := "001111";
   constant c_A32_MBLT       : std_logic_vector(5 downto 0) := "001000";
   constant c_A32_MBLT_sup   : std_logic_vector(5 downto 0) := "001100";
   constant c_A32_LCK        : std_logic_vector(5 downto 0) := "000101";
   constant c_A64            : std_logic_vector(5 downto 0) := "000001";
   constant c_A64_BLT        : std_logic_vector(5 downto 0) := "000011";
   constant c_A64_MBLT       : std_logic_vector(5 downto 0) := "000000";
   constant c_A64_LCK        : std_logic_vector(5 downto 0) := "000100";
   constant c_TWOedge        : std_logic_vector(5 downto 0) := "100000";
   constant c_A32_2eVME      : std_logic_vector(7 downto 0) := "00000001";
   constant c_A64_2eVME      : std_logic_vector(7 downto 0) := "00000010";
   constant c_A32_2eSST      : std_logic_vector(7 downto 0) := "00010001";
   constant c_A64_2eSST      : std_logic_vector(7 downto 0) := "00010010";
 --CSR array's index:
   constant BAR                 : integer := 255;
   constant BIT_SET_CLR_REG     : integer := 254;
   constant USR_BIT_SET_CLR_REG : integer := 253;
   constant CRAM_OWNER          : integer := 252;
   constant FUNC7_ADER_0        : integer := 251;
   constant FUNC7_ADER_1        : integer := FUNC7_ADER_0 - 1;
   constant FUNC7_ADER_2        : integer := FUNC7_ADER_0 - 2;
   constant FUNC7_ADER_3        : integer := FUNC7_ADER_0 - 3;
   constant FUNC6_ADER_0        : integer := FUNC7_ADER_0 - 4;
   constant FUNC6_ADER_1        : integer := FUNC7_ADER_0 - 5;
   constant FUNC6_ADER_2        : integer := FUNC7_ADER_0 - 6;
   constant FUNC6_ADER_3        : integer := FUNC7_ADER_0 - 7;
   constant FUNC5_ADER_0        : integer := FUNC7_ADER_0 - 8;
   constant FUNC5_ADER_1        : integer := FUNC7_ADER_0 - 9;
   constant FUNC5_ADER_2        : integer := FUNC7_ADER_0 - 10;
   constant FUNC5_ADER_3        : integer := FUNC7_ADER_0 - 11;
   constant FUNC4_ADER_0        : integer := FUNC7_ADER_0 - 12;
   constant FUNC4_ADER_1        : integer := FUNC7_ADER_0 - 13;
   constant FUNC4_ADER_2        : integer := FUNC7_ADER_0 - 14;
   constant FUNC4_ADER_3        : integer := FUNC7_ADER_0 - 15;
   constant FUNC3_ADER_0        : integer := FUNC7_ADER_0 - 16;
   constant FUNC3_ADER_1        : integer := FUNC7_ADER_0 - 17;
   constant FUNC3_ADER_2        : integer := FUNC7_ADER_0 - 18;
   constant FUNC3_ADER_3        : integer := FUNC7_ADER_0 - 19;
   constant FUNC2_ADER_0        : integer := FUNC7_ADER_0 - 20;
   constant FUNC2_ADER_1        : integer := FUNC7_ADER_0 - 21;
   constant FUNC2_ADER_2        : integer := FUNC7_ADER_0 - 22;
   constant FUNC2_ADER_3        : integer := FUNC7_ADER_0 - 23;
   constant FUNC1_ADER_0        : integer := FUNC7_ADER_0 - 24;
   constant FUNC1_ADER_1        : integer := FUNC7_ADER_0 - 25;
   constant FUNC1_ADER_2        : integer := FUNC7_ADER_0 - 26;
   constant FUNC1_ADER_3        : integer := FUNC7_ADER_0 - 27;
   constant FUNC0_ADER_0        : integer := FUNC7_ADER_0 - 28;
   constant FUNC0_ADER_1        : integer := FUNC7_ADER_0 - 29;
   constant FUNC0_ADER_2        : integer := FUNC7_ADER_0 - 30;
   constant FUNC0_ADER_3        : integer := FUNC7_ADER_0 - 31;
   constant IRQ_Vector          : integer := FUNC0_ADER_3 -1;
   constant IRQ_level           : integer := FUNC0_ADER_3 -2;
   constant TIME0_ns            : integer := FUNC0_ADER_3 -5;
   constant TIME1_ns            : integer := FUNC0_ADER_3 -6;
   constant TIME2_ns            : integer := FUNC0_ADER_3 -7;
   constant TIME3_ns            : integer := FUNC0_ADER_3 -8;
   constant TIME4_ns            : integer := FUNC0_ADER_3 -9;
   constant BYTES0              : integer := FUNC0_ADER_3 -10;
   constant BYTES1              : integer := FUNC0_ADER_3 -11;
	constant WB32or64            : integer := FUNC0_ADER_3 -12;
   constant MBLT_Endian         : integer := FUNC0_ADER_3 -4;
  
   -- Initialization CR:
   constant BEG_USER_CR  : integer := 1;  
   constant END_USER_CR  : integer := 2;
   constant BEG_CRAM     : integer := 3;
   constant END_CRAM     : integer := 4;
   constant BEG_USER_CSR : integer := 5;
   constant END_USER_CSR : integer := 6;
   constant FUNC_AMCAP   : integer := 7;
   constant FUNC_XAMCAP  : integer := 8;
   constant FUNC_ADEM    : integer := 9;

   constant c_CRinitAddr : t_cr_add_table(BEG_USER_CR to FUNC_ADEM) := (
   BEG_USER_CR => (add => 16#020#, len => 3),
   END_USER_CR => (add => 16#023#, len => 3),

   BEG_CRAM => (add => 16#26#, len => 3),
   END_CRAM => (add => 16#29#, len => 3),

   BEG_USER_CSR => (add => 16#02C#, len => 3),
   END_USER_CSR => (add => 16#02F#, len => 3),

   FUNC_AMCAP  => (add => 16#048#, len => 64),
   FUNC_XAMCAP => (add => 16#088#, len => 256),
   FUNC_ADEM   => (add => 16#188#, len => 32));
  
   -- Main Finite State machine signals default:
	-- When the S_FPGA detects the magic sequency, it erases the A_FPGA so 
	-- I don't need to drive the s_dtackOE, s_dataOE, s_addrOE, s_addrDir, s_dataDir 
	-- to 'Z' in the default configuration.
	-- If the S_FPGA will be provided to a core who drive these lines without erase the
	-- A_FPGA the above mentioned lines should be changed to 'Z' !!!
   constant c_FSM_default : t_FSM :=(
   s_memReq         => '0',
   s_decode         => '0',
   s_dtackOE        => '0',  
   s_mainDTACK      => '1',
   s_dataDir        => '0',
   s_dataOE         => '0',
   s_addrDir        => '0',  -- during IACK cycle the ADDR lines are input
   s_addrOE         => '0',
   s_DSlatch        => '0',
   s_incrementAddr  => '0',
   s_dataPhase      => '0',
   s_dataToOutput   => '0',
   s_dataToAddrBus  => '0',
   s_transferActive => '0',
   s_2eLatchAddr    => "00",
   s_retry          => '0',
   s_berr           => '0',
   s_BERR_out       => '0'
);

  -- CSR address:
  constant c_BAR_addr             : unsigned(19 downto 0) := x"7FFFF";   -- VME64x defined CSR
  constant c_BIT_SET_REG_addr     : unsigned(19 downto 0) := x"7FFFB";
  constant c_BIT_CLR_REG_addr     : unsigned(19 downto 0) := x"7FFF7";
  constant c_CRAM_OWNER_addr      : unsigned(19 downto 0) := x"7FFF3";
  constant c_USR_BIT_SET_REG_addr : unsigned(19 downto 0) := x"7FFEF";
  constant c_USR_BIT_CLR_REG_addr : unsigned(19 downto 0) := x"7FFEB";
  constant c_FUNC7_ADER_0_addr    : unsigned(19 downto 0) := x"7FFDF";
  constant c_FUNC7_ADER_1_addr    : unsigned(19 downto 0) := x"7FFDB";
  constant c_FUNC7_ADER_2_addr    : unsigned(19 downto 0) := x"7FFD7";
  constant c_FUNC7_ADER_3_addr    : unsigned(19 downto 0) := x"7FFD3";
  constant c_FUNC6_ADER_0_addr    : unsigned(19 downto 0) := x"7FFCF";
  constant c_FUNC6_ADER_1_addr    : unsigned(19 downto 0) := x"7FFCB";
  constant c_FUNC6_ADER_2_addr    : unsigned(19 downto 0) := x"7FFC7";
  constant c_FUNC6_ADER_3_addr    : unsigned(19 downto 0) := x"7FFC3";
  constant c_FUNC5_ADER_0_addr    : unsigned(19 downto 0) := x"7FFBF";
  constant c_FUNC5_ADER_1_addr    : unsigned(19 downto 0) := x"7FFBB";
  constant c_FUNC5_ADER_2_addr    : unsigned(19 downto 0) := x"7FFB7";
  constant c_FUNC5_ADER_3_addr    : unsigned(19 downto 0) := x"7FFB3";
  constant c_FUNC4_ADER_0_addr    : unsigned(19 downto 0) := x"7FFAF";
  constant c_FUNC4_ADER_1_addr    : unsigned(19 downto 0) := x"7FFAB";
  constant c_FUNC4_ADER_2_addr    : unsigned(19 downto 0) := x"7FFA7";
  constant c_FUNC4_ADER_3_addr    : unsigned(19 downto 0) := x"7FFA3";
  constant c_FUNC3_ADER_0_addr    : unsigned(19 downto 0) := x"7FF9F";
  constant c_FUNC3_ADER_1_addr    : unsigned(19 downto 0) := x"7FF9B";
  constant c_FUNC3_ADER_2_addr    : unsigned(19 downto 0) := x"7FF97";
  constant c_FUNC3_ADER_3_addr    : unsigned(19 downto 0) := x"7FF93";
  constant c_FUNC2_ADER_0_addr    : unsigned(19 downto 0) := x"7FF8F";
  constant c_FUNC2_ADER_1_addr    : unsigned(19 downto 0) := x"7FF8B";
  constant c_FUNC2_ADER_2_addr    : unsigned(19 downto 0) := x"7FF87";
  constant c_FUNC2_ADER_3_addr    : unsigned(19 downto 0) := x"7FF83";
  constant c_FUNC1_ADER_0_addr    : unsigned(19 downto 0) := x"7FF7F";
  constant c_FUNC1_ADER_1_addr    : unsigned(19 downto 0) := x"7FF7B";
  constant c_FUNC1_ADER_2_addr    : unsigned(19 downto 0) := x"7FF77";
  constant c_FUNC1_ADER_3_addr    : unsigned(19 downto 0) := x"7FF73";
  constant c_FUNC0_ADER_0_addr    : unsigned(19 downto 0) := x"7FF6F";
  constant c_FUNC0_ADER_1_addr    : unsigned(19 downto 0) := x"7FF6B";
  constant c_FUNC0_ADER_2_addr    : unsigned(19 downto 0) := x"7FF67";
  constant c_FUNC0_ADER_3_addr    : unsigned(19 downto 0) := x"7FF63";  -- VME64x defined CSR
  constant c_IRQ_Vector_addr      : unsigned(19 downto 0) := x"7FF5F";  -- VME64x reserved CSR
  constant c_IRQ_level_addr       : unsigned(19 downto 0) := x"7FF5B";  -- VME64x reserved CSR
  constant c_TIME0_ns_addr        : unsigned(19 downto 0) := x"7FF4f";  -- VME64x reserved CSR
  constant c_TIME1_ns_addr        : unsigned(19 downto 0) := x"7FF4b";
  constant c_TIME2_ns_addr        : unsigned(19 downto 0) := x"7FF47";
  constant c_TIME3_ns_addr        : unsigned(19 downto 0) := x"7FF43";
  constant c_TIME4_ns_addr        : unsigned(19 downto 0) := x"7FF3f";
  constant c_BYTES0_addr          : unsigned(19 downto 0) := x"7FF3b";
  constant c_BYTES1_addr          : unsigned(19 downto 0) := x"7FF37";
  constant c_WB32or64_addr        : unsigned(19 downto 0) := x"7FF33";
  constant c_MBLT_Endian_addr     : unsigned(19 downto 0) := x"7FF53";  -- VME64x reserved CSR

--___________________________________________________________________________________________
-- TYPE:
  type t_typeOfDataTransfer is (  D08_0,   
                                  D08_1,   
                                  D08_2,   
                                  D08_3,   
                                  D16_01,  
                                  D16_23,  
                                  D32,
                                  D64,
                                  TypeError
                                );

   type t_addressingType is (     A24,
                                  A24_BLT,
                                  A24_MBLT,
                                  CR_CSR,
                                  A16,
                                  A32,
                                  A32_BLT,
                                  A32_MBLT,
                                  A64,
                                  A64_BLT,
                                  A64_MBLT,
                                  TWOedge,
                                  AM_Error
                             );

   type t_transferType is (       SINGLE,
                                  BLT,
                                  MBLT,
                                  TWOe,
                                  error
                             );

   type t_XAMtype is (            A32_2eVME,
                                  A64_2eVME,
                                  A32_2eSST,
                                  A64_2eSST,
                                  A32_2eSSTb,
                                  A64_2eSSTb,
                                  XAM_error
                             );	

   type t_2eType is (             TWOe_VME,
                                  TWOe_SST
                    );							

   type t_mainFSMstates is (      IDLE,
                                  DECODE_ACCESS,
                                  WAIT_FOR_DS,
                                  LATCH_DS,
                                  CHECK_TRANSFER_TYPE,
                                  MEMORY_REQ,
                                  DATA_TO_BUS,
                                  DTACK_LOW,
                                  DECIDE_NEXT_CYCLE,
                                  INCREMENT_ADDR,
                                  SET_DATA_PHASE
											 -- uncomment for using 2e modes:
--                                  WAIT_FOR_DS_2e,
--                                  ADDR_PHASE_1,
--                                  ADDR_PHASE_2,
--                                  ADDR_PHASE_3,
--                                  DECODE_ACCESS_2e,
--                                  DTACK_PHASE_1,
--                                  DTACK_PHASE_2,
--                                  DTACK_PHASE_3,
--                                  TWOeVME_WRITE,
--                                  TWOeVME_READ,
--                                  TWOeVME_MREQ_RD,
--                                  WAIT_WR_1,
--                                  WAIT_WR_2,
--                                  WAIT_WB_ACK_WR,
--                                  WAIT_WB_ACK_RD,
--                                  TWOeVME_TOGGLE_WR,
--                                  TWOeVME_TOGGLE_RD,
--                                  TWOe_FIFO_WRITE,
--                                  TWOe_TOGGLE_DTACK,
--                                  TWOeVME_INCR_ADDR,
--                                  TWOe_WAIT_FOR_DS1,
--                                  TWOe_FIFO_WAIT_READ,
--                                  TWOe_FIFO_READ,
--                                  TWOe_CHECK_BEAT,
--                                  TWOe_RELEASE_DTACK,
--                                  TWOe_END_1,
--                                  TWOe_END_2
                             );

   type t_initState is (          IDLE,            
                                  SET_ADDR,
                                  GET_DATA,
                                  END_INIT
                             );

   type t_FUNC_32b_array is array (0 to 7) of unsigned(31 downto 0);  -- ADER register array
   type t_FUNC_64b_array is array (0 to 7) of unsigned(63 downto 0);  -- AMCAP register array
   type t_FUNC_256b_array is array (0 to 7) of unsigned(255 downto 0);  -- XAMCAP register array
   type t_FUNC_32b_array_std is array (0 to 7) of std_logic_vector(31 downto 0);  -- ADER register array
   type t_FUNC_64b_array_std is array (0 to 7) of std_logic_vector(63 downto 0);  -- AMCAP register array
   type t_FUNC_256b_array_std is array (0 to 7) of std_logic_vector(255 downto 0);  -- XAMCAP register array
   type t_CSRarray is array(BAR downto WB32or64) of unsigned(7 downto 0);
   type t_cr_array is array (natural range <>) of std_logic_vector(7 downto 0);

--_____________________________________________________________________________________________________
--COMPONENTS:
              COMPONENT VME_bus
                 PORT(
                        clk_i                : in std_logic;
                        VME_RST_n_i          : in std_logic;
                        VME_AS_n_i           : in std_logic;
                        VME_LWORD_n_b_i      : in std_logic;
                        VME_WRITE_n_i        : in std_logic;
                        VME_DS_n_i           : in std_logic_vector(1 downto 0);
                        VME_GA_i             : in std_logic_vector(5 downto 0);
                        VME_ADDR_b_i         : in std_logic_vector(31 downto 1);
                        VME_DATA_b_i         : in std_logic_vector(31 downto 0);
                        VME_AM_i             : in std_logic_vector(5 downto 0);
                        VME_IACK_n_i         : in std_logic;
                        memAckWB_i           : in std_logic;
                        wbData_i             : in std_logic_vector(63 downto 0);
                        err_i                : in std_logic;
                        rty_i                : in std_logic;
                        stall_i              : in std_logic;
                        CRAMdata_i           : in std_logic_vector(7 downto 0);
                        CRdata_i             : in std_logic_vector(7 downto 0);
                        CSRData_i            : in std_logic_vector(7 downto 0);
                        reset_flag_i         : in std_logic;
                        Ader0                : in std_logic_vector(31 downto 0);
                        Ader1                : in std_logic_vector(31 downto 0);
                        Ader2                : in std_logic_vector(31 downto 0);
                        Ader3                : in std_logic_vector(31 downto 0);
                        Ader4                : in std_logic_vector(31 downto 0);
                        Ader5                : in std_logic_vector(31 downto 0);
                        Ader6                : in std_logic_vector(31 downto 0);
                        Ader7                : in std_logic_vector(31 downto 0);
                        ModuleEnable         : in std_logic;
                        MBLT_Endian_i        : in std_logic_vector(2 downto 0);
                        Sw_Reset             : in std_logic;
								W32                  : in  std_logic;
                        BAR_i                : in std_logic_vector(4 downto 0);
                        transfer_done_i      : in std_logic;          
                        reset_o              : out std_logic;
                        VME_LWORD_n_b_o      : out std_logic;
                        VME_RETRY_n_o        : out std_logic;
                        VME_RETRY_OE_o       : out std_logic;
                        VME_DTACK_n_o        : out std_logic;
                        VME_DTACK_OE_o       : out std_logic;
                        VME_BERR_o           : out std_logic;
                        VME_ADDR_b_o         : out std_logic_vector(31 downto 1);
                        VME_ADDR_DIR_o       : out std_logic;
                        VME_ADDR_OE_N_o      : out std_logic;
                        VME_DATA_b_o         : out std_logic_vector(31 downto 0);
                        VME_DATA_DIR_o       : out std_logic;
                        VME_DATA_OE_N_o      : out std_logic;
                        memReq_o             : out std_logic;
                        wbData_o             : out std_logic_vector(63 downto 0);
                        locAddr_o            : out std_logic_vector(63 downto 0);
                        wbSel_o              : out std_logic_vector(7 downto 0);
                        RW_o                 : out std_logic;
                        cyc_o                : out std_logic;
                        psize_o              : out std_logic_vector(8 downto 0);
                        VMEtoWB              : out std_logic;
                        WBtoVME              : out std_logic;
                        FifoMux              : out std_logic;
                        CRAMaddr_o           : out std_logic_vector(18 downto 0);
                        CRAMdata_o           : out std_logic_vector(7 downto 0);
                        CRAMwea_o            : out std_logic;
                        CRaddr_o             : out std_logic_vector(11 downto 0);
                        en_wr_CSR            : out std_logic;
                        CrCsrOffsetAddr      : out std_logic_vector(18 downto 0);
                        CSRData_o            : out std_logic_vector(7 downto 0);
                        err_flag_o           : out std_logic;
                        numBytes             : out std_logic_vector(12 downto 0);
                        transfTime           : out std_logic_vector(39 downto 0);
                        leds                 : out std_logic_vector(7 downto 0);
                        transfer_done_o      : out std_logic	
                     );
              END COMPONENT;


              COMPONENT VME_Access_Decode
                 PORT (
                        clk_i          : in  std_logic;
                        s_reset        : in  std_logic;
                        s_mainFSMreset : in  std_logic;
                        s_decode       : in  std_logic;
                        ModuleEnable   : in  std_logic;
                        InitInProgress : in  std_logic;
                        Addr           : in  std_logic_vector(63 downto 0);
                        Ader0          : in  std_logic_vector(31 downto 0);
                        Ader1          : in  std_logic_vector(31 downto 0);
                        Ader2          : in  std_logic_vector(31 downto 0);
                        Ader3          : in  std_logic_vector(31 downto 0);
                        Ader4          : in  std_logic_vector(31 downto 0);
                        Ader5          : in  std_logic_vector(31 downto 0);
                        Ader6          : in  std_logic_vector(31 downto 0);
                        Ader7          : in  std_logic_vector(31 downto 0);
                        Adem0          : in  std_logic_vector(31 downto 0);
                        Adem1          : in  std_logic_vector(31 downto 0);
                        Adem2          : in  std_logic_vector(31 downto 0);
                        Adem3          : in  std_logic_vector(31 downto 0);
                        Adem4          : in  std_logic_vector(31 downto 0);
                        Adem5          : in  std_logic_vector(31 downto 0);
                        Adem6          : in  std_logic_vector(31 downto 0);
                        Adem7          : in  std_logic_vector(31 downto 0);
                        AmCap0         : in  std_logic_vector(63 downto 0);
                        AmCap1         : in  std_logic_vector(63 downto 0);
                        AmCap2         : in  std_logic_vector(63 downto 0);
                        AmCap3         : in  std_logic_vector(63 downto 0);
                        AmCap4         : in  std_logic_vector(63 downto 0);
                        AmCap5         : in  std_logic_vector(63 downto 0);
                        AmCap6         : in  std_logic_vector(63 downto 0);
                        AmCap7         : in  std_logic_vector(63 downto 0);
                        XAmCap0        : in  std_logic_vector(255 downto 0);
                        XAmCap1        : in  std_logic_vector(255 downto 0);
                        XAmCap2        : in  std_logic_vector(255 downto 0);
                        XAmCap3        : in  std_logic_vector(255 downto 0);
                        XAmCap4        : in  std_logic_vector(255 downto 0);
                        XAmCap5        : in  std_logic_vector(255 downto 0);
                        XAmCap6        : in  std_logic_vector(255 downto 0);
                        XAmCap7        : in  std_logic_vector(255 downto 0);
                        Am             : in  std_logic_vector(5 downto 0);
                        XAm            : in  std_logic_vector(7 downto 0);
                        BAR            : in  std_logic_vector(4 downto 0);
                        AddrWidth      : in  std_logic_vector(1 downto 0);          
                        Funct_Sel      : out std_logic_vector(7 downto 0);
                        Base_Addr      : out std_logic_vector(63 downto 0);
                        Confaccess     : out std_logic;
                        CardSel        : out std_logic
                     );
              END COMPONENT;

              COMPONENT VME_Funct_Match
                 PORT(
                        clk_i          : in  std_logic;
                        s_reset        : in  std_logic;
                        s_decode       : in  std_logic;
                        s_mainFSMreset : in  std_logic;
                        Addr           : in  std_logic_vector(63 downto 0);
                        AddrWidth      : in  std_logic_vector(1 downto 0);
                        Ader0          : in  std_logic_vector(31 downto 0);
                        Ader1          : in  std_logic_vector(31 downto 0);
                        Ader2          : in  std_logic_vector(31 downto 0);
                        Ader3          : in  std_logic_vector(31 downto 0);
                        Ader4          : in  std_logic_vector(31 downto 0);
                        Ader5          : in  std_logic_vector(31 downto 0);
                        Ader6          : in  std_logic_vector(31 downto 0);
                        Ader7          : in  std_logic_vector(31 downto 0);
                        Adem0          : in  std_logic_vector(31 downto 0);
                        Adem1          : in  std_logic_vector(31 downto 0);
                        Adem2          : in  std_logic_vector(31 downto 0);
                        Adem3          : in  std_logic_vector(31 downto 0);
                        Adem4          : in  std_logic_vector(31 downto 0);
                        Adem5          : in  std_logic_vector(31 downto 0);
                        Adem6          : in  std_logic_vector(31 downto 0);
                        Adem7          : in  std_logic_vector(31 downto 0);          
                        FunctMatch     : out std_logic_vector(7 downto 0);
                        DFS_o          : out std_logic_vector(7 downto 0);
                        Nx_Base_Addr   : out std_logic_vector(63 downto 0)
                     );
              END COMPONENT;

              COMPONENT VME_CR_CSR_Space
                 PORT(
                        clk_i              : in  std_logic;
                        s_reset            : in  std_logic;
                        CR_addr            : in  std_logic_vector(11 downto 0);
                        CRAM_addr          : in  std_logic_vector(18 downto 0);
                        CRAM_data_i        : in  std_logic_vector(7 downto 0);
                        CRAM_Wen           : in  std_logic;
                        en_wr_CSR          : in  std_logic;
                        CrCsrOffsetAddr    : in  std_logic_vector(18 downto 0);
                        VME_GA_oversampled : in  std_logic_vector(5 downto 0);
                        locDataIn          : in  std_logic_vector(7 downto 0);
                        s_err_flag         : in  std_logic;          
                        CR_data            : out std_logic_vector(7 downto 0);
                        CRAM_data_o        : out std_logic_vector(7 downto 0);
                        s_reset_flag       : out std_logic;
                        CSRdata            : out std_logic_vector(7 downto 0);
                        Ader0              : out std_logic_vector(31 downto 0);
                        Ader1              : out std_logic_vector(31 downto 0);
                        Ader2              : out std_logic_vector(31 downto 0);
                        Ader3              : out std_logic_vector(31 downto 0);
                        Ader4              : out std_logic_vector(31 downto 0);
                        Ader5              : out std_logic_vector(31 downto 0);
                        Ader6              : out std_logic_vector(31 downto 0);
                        Ader7              : out std_logic_vector(31 downto 0);
                        ModuleEnable       : out std_logic;
                        Sw_Reset           : out std_logic;
								W32                : out std_logic;
                        numBytes           : in  std_logic_vector(12 downto 0);
                        transfTime         : in  std_logic_vector(39 downto 0);
                        MBLT_Endian_o      : out std_logic_vector(2 downto 0);
                        BAR_o              : out std_logic_vector(4 downto 0);
                        INT_Level          : out std_logic_vector(7 downto 0);
                        INT_Vector         : out std_logic_vector(7 downto 0)
                     );
              END COMPONENT;

              COMPONENT VME_Am_Match
                 PORT(
                        clk_i          : in  std_logic;
                        s_reset        : in  std_logic;
                        s_mainFSMreset : in  std_logic;
                        Ader0          : in  std_logic_vector(31 downto 0);
                        Ader1          : in  std_logic_vector(31 downto 0);
                        Ader2          : in  std_logic_vector(31 downto 0);
                        Ader3          : in  std_logic_vector(31 downto 0);
                        Ader4          : in  std_logic_vector(31 downto 0);
                        Ader5          : in  std_logic_vector(31 downto 0);
                        Ader6          : in  std_logic_vector(31 downto 0);
                        Ader7          : in  std_logic_vector(31 downto 0);
                        AmCap0         : in  std_logic_vector(63 downto 0);
                        AmCap1         : in  std_logic_vector(63 downto 0);
                        AmCap2         : in  std_logic_vector(63 downto 0);
                        AmCap3         : in  std_logic_vector(63 downto 0);
                        AmCap4         : in  std_logic_vector(63 downto 0);
                        AmCap5         : in  std_logic_vector(63 downto 0);
                        AmCap6         : in  std_logic_vector(63 downto 0);
                        AmCap7         : in  std_logic_vector(63 downto 0);
                        XAmCap0        : in  std_logic_vector(255 downto 0);
                        XAmCap1        : in  std_logic_vector(255 downto 0);
                        XAmCap2        : in  std_logic_vector(255 downto 0);
                        XAmCap3        : in  std_logic_vector(255 downto 0);
                        XAmCap4        : in  std_logic_vector(255 downto 0);
                        XAmCap5        : in  std_logic_vector(255 downto 0);
                        XAmCap6        : in  std_logic_vector(255 downto 0);
                        XAmCap7        : in  std_logic_vector(255 downto 0);
                        Am             : in  std_logic_vector(5 downto 0);
                        XAm            : in  std_logic_vector(7 downto 0);
                        DFS_i          : in  std_logic_vector(7 downto 0);
                        s_decode       : in  std_logic;          
                        AmMatch        : out std_logic_vector(7 downto 0)
                     );
              END COMPONENT;

              COMPONENT VME_Wb_master
                 PORT(
                        s_memReq        : in  std_logic;
                        clk_i           : in  std_logic;
                        s_cardSel       : in  std_logic;
                        s_reset         : in  std_logic;
                        s_mainFSMreset  : in  std_logic;
                        s_BERRcondition : in  std_logic;
                        s_sel           : in  std_logic_vector(7 downto 0);
                        s_beatCount     : in  std_logic_vector(8 downto 0);
                        s_locDataInSwap : in  std_logic_vector(63 downto 0);
                        s_rel_locAddr   : in  std_logic_vector(63 downto 0);
                        s_RW            : in  std_logic;
                        stall_i         : in  std_logic;
                        rty_i           : in  std_logic;
                        err_i           : in  std_logic;
                        wbData_i        : in  std_logic_vector(63 downto 0);
                        memAckWB_i      : in  std_logic;          
                        s_locDataOut    : out std_logic_vector(63 downto 0);
                        s_AckWithError  : out std_logic;
                        memAckWb        : out std_logic;
                        err             : out std_logic;
								W32             : in  std_logic;
                        rty             : out std_logic;
                        psize_o         : out std_logic_vector(8 downto 0);
                        cyc_o           : out std_logic;
                        memReq_o        : out std_logic;
                        WBdata_o        : out std_logic_vector(63 downto 0);
                        locAddr_o       : out std_logic_vector(63 downto 0);
                        WbSel_o         : out std_logic_vector(7 downto 0);
                        RW_o            : out std_logic
                     );
              END COMPONENT;

              COMPONENT VME_Init
                 PORT(
                        clk_i          : in    std_logic;
                        CRAddr         : in    std_logic_vector(18 downto 0);
                        CRdata_i       : in    std_logic_vector(7 downto 0);    
                        RSTedge        : inout std_logic;      
                        InitReadCount  : out   std_logic_vector(8 downto 0);
                        InitInProgress : out   std_logic;
                        BEG_USR_CR_o   : out   std_logic_vector(23 downto 0);
                        END_USR_CR_o   : out   std_logic_vector(23 downto 0);
                        BEG_USR_CSR_o  : out   std_logic_vector(23 downto 0);
                        END_USR_CSR_o  : out   std_logic_vector(23 downto 0);
                        BEG_CRAM_o     : out   std_logic_vector(23 downto 0);
                        END_CRAM_o     : out   std_logic_vector(23 downto 0);
                        FUNC0_ADEM_o   : out   std_logic_vector(31 downto 0);
                        FUNC1_ADEM_o   : out   std_logic_vector(31 downto 0);
                        FUNC2_ADEM_o   : out   std_logic_vector(31 downto 0);
                        FUNC3_ADEM_o   : out   std_logic_vector(31 downto 0);
                        FUNC4_ADEM_o   : out   std_logic_vector(31 downto 0);
                        FUNC5_ADEM_o   : out   std_logic_vector(31 downto 0);
                        FUNC6_ADEM_o   : out   std_logic_vector(31 downto 0);
                        FUNC7_ADEM_o   : out   std_logic_vector(31 downto 0);
                        FUNC0_AMCAP_o  : out   std_logic_vector(63 downto 0);
                        FUNC1_AMCAP_o  : out   std_logic_vector(63 downto 0);
                        FUNC2_AMCAP_o  : out   std_logic_vector(63 downto 0);
                        FUNC3_AMCAP_o  : out   std_logic_vector(63 downto 0);
                        FUNC4_AMCAP_o  : out   std_logic_vector(63 downto 0);
                        FUNC5_AMCAP_o  : out   std_logic_vector(63 downto 0);
                        FUNC6_AMCAP_o  : out   std_logic_vector(63 downto 0);
                        FUNC7_AMCAP_o  : out   std_logic_vector(63 downto 0);
                        FUNC0_XAMCAP_o : out   std_logic_vector(255 downto 0);
                        FUNC1_XAMCAP_o : out   std_logic_vector(255 downto 0);
                        FUNC2_XAMCAP_o : out   std_logic_vector(255 downto 0);
                        FUNC3_XAMCAP_o : out   std_logic_vector(255 downto 0);
                        FUNC4_XAMCAP_o : out   std_logic_vector(255 downto 0);
                        FUNC5_XAMCAP_o : out   std_logic_vector(255 downto 0);
                        FUNC6_XAMCAP_o : out   std_logic_vector(255 downto 0);
                        FUNC7_XAMCAP_o : out   std_logic_vector(255 downto 0)
                     );
              END COMPONENT;	

              COMPONENT VME_swapper
                 PORT(
                        d_i : in  std_logic_vector(63 downto 0);
                        sel : in  std_logic_vector(2 downto 0);          
                        d_o : out std_logic_vector(63 downto 0)
                     );
              END COMPONENT;
              component FlipFlopD is
                 port (
                         reset,enable,sig_i,clk_i     : in  std_logic;
                         sig_o                        : out std_logic := '0'
                      );
              end component;
              component EdgeDetection is
                 port (
                         sig_i,clk_i : in  std_logic;
                         sigEdge_o   : out std_logic := '0'
                      );
              end component;

              component FallingEdgeDetection is
                 port (
                 sig_i, clk_i : in  std_logic;
                 FallEdge_o   : out std_logic);
              end component;

              component RisEdgeDetection is
                 port (
                 sig_i, clk_i : in  std_logic;
                 RisEdge_o    : out std_logic);
              end component;

              component DoubleSigInputSample is
                 port (
                 sig_i, clk_i : in  std_logic;
                 sig_o        : out std_logic);
              end component;

              component SigInputSample is
                 port (
                 sig_i, clk_i : in  std_logic;
                 sig_o        : out std_logic);
              end component;  

              component DoubleRegInputSample is
                 generic(
                           width : natural := 8
                        );
                 port (
                         reg_i : in  std_logic_vector(width-1 downto 0);
                         reg_o : out std_logic_vector(width-1 downto 0) := (others => '0');
                         clk_i : in  std_logic
                      );
              end component;

              component RegInputSample is
                 generic(
                           width : natural := 8
                        );
                 port (
                         reg_i : in  std_logic_vector(width-1 downto 0);
                         reg_o : out std_logic_vector(width-1 downto 0) := (others => '0');
                         clk_i : in  std_logic
                      );
              end component;

              COMPONENT VME_IRQ_Controller
                 PORT(
                        clk_i           : in  std_logic;
                        reset           : in  std_logic;
                        VME_IACKIN_n_i  : in  std_logic;
                        VME_AS_n_i      : in  std_logic;
								VME_AS1_n_i     : in  std_logic;
                        VME_DS_n_i      : in  std_logic_vector(1 downto 0);
                        VME_LWORD_n_i   : in  std_logic;
                        VME_ADDR_123    : in  std_logic_vector(2 downto 0);
                        INT_Level       : in  std_logic_vector(7 downto 0);
                        INT_Vector      : in  std_logic_vector(7 downto 0);
                        INT_Req         : in  std_logic;          
                        VME_IRQ_n_o     : out std_logic_vector(6 downto 0);
                        VME_IACKOUT_n_o : out std_logic;
                        VME_DTACK_n_o   : out std_logic;
                        VME_DTACK_OE_o  : out std_logic;
                        VME_DATA_o      : out std_logic_vector(31 downto 0);
                        VME_DATA_DIR_o  : out std_logic
                     );
              END COMPONENT;

              COMPONENT dpblockram
                 generic (dl : integer := 8; 		-- Length of the data word 
                          al : integer := 19;			-- Size of the addr map (10 = 1024 words)
                          nw : integer := 2**19);    -- Number of words
                 PORT(
                        clk : in  std_logic;
                        we  : in  std_logic;
                        aw  : in  std_logic_vector(al - 1 downto 0);
                        ar  : in  std_logic_vector(al - 1 downto 0);
                        di  : in  std_logic_vector(dl - 1 downto 0);          
                        dw  : out std_logic_vector(dl - 1 downto 0);
                        do  : out std_logic_vector(dl - 1 downto 0)
                     );
              END COMPONENT;

           end vme64x_pack;
package body vme64x_pack is



end vme64x_pack;