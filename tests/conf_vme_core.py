import pyvmelib

class CVmeCrPos:
    def __init__(self, add, nbytes, name):
        self.name = name;
        self.nbytes = nbytes;
        self.add = add;
        for i in range[self.nbytes]:
            self.value[i] = 0;
        self.readdone = 0;
        self.writedone = 0;
        self.debug = 1;


    def read(self, map):
        for i in range[self.nbytes]:
            self.value[i] = map.read(offset=self.add+i*4, width=8)[0];
            if self.debug == 1: 
                print self.readone
            self.readdone=1+self.readdone;
    def write(self, map, data):
        for i in range[self.nbytes]:
            map.write(offset=self.add+i*4, width=8, values=data[i])
        self.writedone=1+self.writedone;


class CVmeCrList:
    def __init__(self,ga):
        par = self.parityOf(ga);
        self.gad = (ga <<23) + (par << 26);
        self.size = 0x10000;
        self.data_width = 8;
        self.am = 0x2f;
        self.map = pyvmelib.Mapping(am=0x2f, base_address=self.gad, data_width=self.data_width, size=self.size);
        self.cr = ["CHKSUMP": CVMeCrPos(0x03,1,"CHKSUM"), 
                   "CRDW":  CVMeCrPos(0x13,3,"CRDW"), 
                   "ACSRDW": CVMeCrPos(0x17,1,"ACSRDW"), 
                   "SPACEID": CVMeCrPos(0x1B,1,"SPACEID"),
                   "CASCII": CVMeCrPos(0x1F,1,"CASCII"),
                   "RASCII": CVMeCrPos(0x23,1,"RASCII"),
                   "MID": CVMeCrPos(0x27,3,"MID"),
                   "BID": CVMeCrPos(0x33,4,"BID"),
                   "RID": CVMeCrPos(0x43,4,"RID"),
                   "STRP": CVMeCrPos(0x53,3,"STRP"),
                   "PID": CVMeCrPos(0x7F,8,"PID"),
                   "FDAW0": CVMeCrPos(0x103,1,"FDAW0"),
                   "FDAW1": CVMeCrPos(0x107,1,"FDAW1"),
                   "FDAW2": CVMeCrPos(0x10B,1,"FDAW2"),
                   "FDAW3": CVMeCrPos(0x10F,1,"FDAW3"),                  
                   "FDAW4": CVMeCrPos(0x103,1,"FDAW4"),
                   "FDAW5": CVMeCrPos(0x107,1,"FDAW5"),
                   "FDAW6":  CVMeCrPos(0x10B,1,"FDAW6"),
                   "FDAW7": CVMeCrPos(0x10F,1,"FDAW7")]

    def parityOf(int_type):
        parity = 0;
        while (int_type):
            parity = ~parity
            int_type = int_type & (int_type - 1)
            return(parity)





for i in range(16):
    map = pyvmelib.Mapping(am=0x2f, base_address=0x280000, data_width=32, size=0x10000);

value = map.read(offset=0x3, width=32)[0]
print hex(value)

map.write(offset=0x3, width=8, values=0xa5)
map.write(offset=0x3, width=8, values=[0xa5, 0xff])