#define fC 1 // flag Carry
#define fZ 2 // flag Zero
#define fI 4 // flag Interrupt
#define fD 8 // flag Decimal
#define fB 16 // flag Break
// ?
#define fV 64 // flag oVerflow
#define fN 128 // flag Negative (sign)

#define clearflag6502(flag) status &= (~flag)
#define setflag6502(flag) status |= flag

#define read6502(address) (memory_map[(address >> 8) + 1].read(address))
#define write6502(address, value) (memory_map[(address >> 8) + 1].write(address, value & 0xFF))
