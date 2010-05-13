-------------------------------------------------------------------------------
--
-- Title       : WB_bus
-- Design      : VME64xCore
-- Author      : Ziga Kroflic
-- Company     : Cosylab
--
-------------------------------------------------------------------------------
--
-- File        : WB_bus.vhd
-- Generated   : Tue Mar 30 11:59:59 2010
-- From        : interface description file
-- By          : Itf2Vhdl ver. 1.20
--
-------------------------------------------------------------------------------
--
-- Description : 
--
-------------------------------------------------------------------------------

--{{ Section below this comment is automatically maintained
--   and may be overwritten
--{entity {WB_bus} architecture {RTL}}

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_unsigned.all;

entity WB_bus is   
    port (
        clk_i:           in std_logic;
        reset_i:         in std_logic;                        -- propagated from VME
        
        RST_i:           in std_logic;
        DAT_i:           in std_logic_vector(63 downto 0);
        DAT_o:           out std_logic_vector(63 downto 0);
        ADR_o:           out std_logic_vector(63 downto 0);
        CYC_o:           out std_logic;
        ERR_i:           in std_logic;
        LOCK_o:          out std_logic;
        RTY_i:           in std_logic;
        SEL_o:           out std_logic_vector(7 downto 0);
        STB_o:           out std_logic;
        ACK_i:           in std_logic;
        WE_o:            out std_logic;
        STALL_i:         in std_logic;
        IRQ_i:           in std_logic;
        
        memReq_i:        in std_logic;                 
        memAck_o:        out std_logic;                  
        locData_o:       out std_logic_vector(63 downto 0); 
        locData_i:       in std_logic_vector(63 downto 0);
        locAddr_i:       in std_logic_vector(63 downto 0);
        sel_i:           in std_logic_vector(7 downto 0);
        RW_i:            in std_logic;                 
        lock_i:          in std_logic;                 
        IRQ_o:           out std_logic;
        err_o:           out std_logic;
        rty_o:           out std_logic;
        cyc_i:           in std_logic;
        
        mainFSMreset_i:  in std_logic;
        beatCount_i:     in std_logic_vector(7 downto 0);
        
        FIFOrden_o:      out std_logic;
		FIFOwren_o:      out std_logic;
        FIFOdata_i:      in std_logic_vector(63 downto 0);
        FIFOdata_o:      out std_logic_vector(63 downto 0);		
        writeFIFOempty_i: in std_logic;
        TWOeInProgress_i: in std_logic;
        WBbusy_o:        out std_logic
        
        );    
end WB_bus;

architecture RTL of WB_bus is

signal s_reset: std_logic;

signal s_locDataOut: std_logic_vector(63 downto 0);	   -- local data
SIgnal s_locAddr: std_logic_vector(63 downto 0);	   -- local address

signal s_FSMactive: std_logic;        -- signals when SST FIFO is being emptied
signal s_cyc: std_logic;            
signal s_stb: std_logic;                    
signal s_addrLatch: std_logic;    	  -- store initial address locally 

signal s_pipeCommActive: std_logic;

signal s_WE: std_logic;

signal s_runningBeatCount: std_logic_vector(8 downto 0);

type t_2eFSMstates is (IDLE, ADDR_LATCH, FIFO_CHECK, RDEN_SET, STB_SET, ADDR_INCREMENT, RETRY, CYC_ON);
signal s_2eFSMstate: t_2eFSMstates;      

begin 
    
s_reset <= reset_i or RST_i; 


-- WB handshaking

STB_o <= memReq_i         when s_FSMactive='0' else s_stb;
memAck_o <= ACK_i         when s_FSMactive='0' else '0';


-- WB data latching

p_dataLatch: process(clk_i)
begin
    if rising_edge(clk_i) then
        if ACK_i='1' then
            s_locDataOut <= DAT_i;
         else
            s_locDataOut <= s_locDataOut;
        end if;
    end if;
end process;

locData_o     <= s_locDataOut;
DAT_o         <= locData_i   when s_FSMactive='0' else FIFOdata_i;

ADR_o <= locAddr_i           when s_FSMactive='0' else s_locAddr;

WE_o     <= not RW_i         when s_FSMactive='0' else s_WE;
IRQ_o    <= IRQ_i;
LOCK_o   <= lock_i;
err_o    <= ERR_i            when s_FSMactive='0' else '0';
rty_o    <= RTY_i            when s_FSMactive='0' else '0';
SEL_o    <= sel_i            when s_FSMactive='0' else (others => '1');
CYC_o    <= cyc_i            when s_FSMactive='0' else s_cyc;

 
WBbusy_o <= s_FSMactive;    
    
-- SST write

p_SSTwriteFSM: process(clk_i)
begin 
    if rising_edge(clk_i) then
        if s_reset='1' then
            s_FSMactive              <='0';
            s_cyc                    <='0';
            s_pipeCommActive         <='0';
            s_WE                     <='0';
            s_addrLatch              <='0';
            s_2eFSMstate            <= IDLE;
        else
            case s_2eFSMstate is
                
                when IDLE =>
                s_FSMactive          <='0';
                s_cyc                <='0';
                s_WE                 <= not RW_i;
                s_addrLatch          <='0';
                s_pipeCommActive     <='0';
                if TWOeInProgress_i='1' then    
                    s_2eFSMstate    <= ADDR_LATCH;
                end if;
                
                when ADDR_LATCH =>
                s_FSMactive          <='1';
                s_cyc                <='0';
                s_WE                 <= s_WE;
                s_addrLatch          <='1';
                s_pipeCommActive     <='0';
                s_2eFSMstate        <= SET_CONTROL_SIGNALS;
				
                when SET_CONTROL_SIGNALS =>
                s_FSMactive          <='1';
                s_cyc                <='1';
                s_WE                 <= s_WE;
                s_addrLatch          <='0';	
                s_pipeCommActive     <='0';
                s_2eFSMstate        <= DO_PIPELINED_COMM;
				
				when DO_PIPELINED_COMM =>
                s_FSMactive          <='1';
                s_cyc                <='1';
                s_WE                 <= s_WE;
                s_addrLatch          <='0';
                s_pipeCommActive     <='1';
                s_2eFSMstate        <= DO_PIPELINED_COMM;
                
                when OTHERS =>
                s_FSMactive          <='0';
                s_cyc                <='0';
                s_WE                 <= s_WE;
                s_addrLatch          <='0';
                s_pipeCommActive     <='0';
                s_2eFSMstate        <= IDLE;
            
            end case;
        end if;
    end if;
end process;
                

-- Local address latching & incrementing

p_locAddrHandling: process(clk_i)
begin
    if rising_edge(clk_i) then
        if s_reset='1' then
            s_locAddr <= (others => '0');
        elsif s_addrLatch='1' then
            s_locAddr <= locAddr_i;
        elsif s_pipeCommActive='1' then																	     
            s_locAddr <= s_locAddr + 8;
        else
            s_locAddr <= s_locAddr;
        end if;
    end if;
end process;


-- Beat counter

p_FIFObeatCounter: process(clk_i)
begin
    if rising_edge(clk_i) then
        if s_reset='1' then
            s_runningBeatCount <= (others => '0');
        elsif s_pipeCommActive='1' then
            s_runningBeatCount <= s_runningBeatCount + 1;
        else
            s_runningBeatCount <= s_runningBeatCount;
        end if;
    end if;
end process;

s_beatCountEnd <= '0' when s_runningBeatCount < beatCount_i else '1';
 

-- 2e write	

FIFOrden  <= '1' when s_pipeCommActive='1' and s_WE='1' and STALL_i='0' and writeFIFOempty_i='0' else '0';
s_STB     <= '1' when s_pipeCommActive='1' and s_WE='1' and STALL_i='0' and writeFIFOempty_i='0' else '0';

        
end RTL;
