asim VME_bus

wave clk_i
wave VME_RST_n_i
wave VME_AS_n_i 	
wave VME_LWORD_n_b
wave VME_RETRY_n_o
wave VME_WRITE_n_i
wave VME_DS_n_i 	
wave VME_GA_i 	
wave VME_DTACK_n_o
wave VME_BERR_n_o	
wave VME_ADDR_b 	
wave VME_DATA_b 	
wave VME_AM_i

wave s_mainFSMstate
wave s_mainFSMreset
wave s_VMEaddrLatch
wave s_memReq
wave s_memAckWB
wave s_dataToOutput
wave s_dataToAddrBus
wave s_locAddr
wave s_locAddrBeforeOffset
wave s_addrOffset
wave s_incrementAddr

wave s_cardSel
wave s_confAccess

wave s_funcMatch(0)
wave s_funcMatch(1)
wave s_funcMatch(2)
wave s_funcMatch(3)

wave CRAMaddr_o
wave CRAMdata_i
wave CRAMdata_o
wave CRAMwea_o

force clk_i 0 0, 1 0.5 ns -r 1 ns

force VME_RST_n_i 0 0, 1 5 ns

force VME_AS_n_i 1 0, 0 10 ns, 1 94 ns
force VME_DS_n_i "11" 0, "10" 11 ns, "11" 24 ns, "01" 30 ns, "11" 42 ns, "10" 55 ns, "11" 68 ns, "01" 78 ns, "11" 94 ns

force s_memAckWB 0 0, 1 19 ns, 0 22 ns, 1 38 ns, 0 41 ns, 1 63 ns, 0 66 ns, 1 87 ns, 0 90 ns

force s_FUNC_ADER(0) "16#FFFFFFFFE0000000" 0
force s_FUNC_ADEM(0) "16#FFFFFFFFE0000000" 0
force s_FUNC_ADER(1) "16#FFFFFFFFFFFFFFFF" 0
force s_FUNC_ADEM(1) "16#FFFFFFFFFFFFFFFF" 0
force s_FUNC_ADER(2) "16#FFFFFFFFFFFFFFFF" 0
force s_FUNC_ADEM(2) "16#FFFFFFFFFFFFFFFF" 0
force s_FUNC_ADER(3) "16#FFFFFFFFFFFFFFFF" 0
force s_FUNC_ADEM(3) "16#FFFFFFFFFFFFFFFF" 0

force VME_AM_i "16#2F" 0
force VME_ADDR_b "16#F0000000" 0
force VME_LWORD_n_b 1 0
force VME_WRITE_n_i 1 1

run 100 ns

endsim