/datum/mos6502
#define p(x) /datum/mos6502/proc/x
	var/static/instructions = list(
		p(BRK), p(ORA), p(udf), p(udf), p(udf), p(ORA), p(ASL), p(udf), p(PHP), p(ORA), p(ASL), p(udf), p(udf), p(ORA), p(ASL), p(udf),
		p(BPL), p(ORA), p(udf), p(udf), p(udf), p(ORA), p(ASL), p(udf), p(CLC), p(ORA), p(udf), p(udf), p(udf), p(ORA), p(ASL), p(udf),
		p(JSR), p(AND), p(udf), p(udf), p(BIT), p(AND), p(ROL), p(udf), p(PLP), p(AND), p(ROL), p(udf), p(BIT), p(AND), p(ROL), p(udf),
		p(BMI), p(AND), p(udf), p(udf), p(udf), p(AND), p(ROL), p(udf), p(SEC), p(AND), p(udf), p(udf), p(udf), p(AND), p(ROL), p(udf),
		p(RTI), p(EOR), p(udf), p(udf), p(udf), p(EOR), p(LSR), p(udf), p(PHA), p(EOR), p(LSR), p(udf), p(JMP), p(EOR), p(LSR), p(udf),
		p(BVC), p(EOR), p(udf), p(udf), p(udf), p(EOR), p(LSR), p(udf), p(CLI), p(EOR), p(udf), p(udf), p(udf), p(EOR), p(LSR), p(udf),
		p(RTS), p(ADC), p(udf), p(udf), p(udf), p(ADC), p(ROR), p(udf), p(PLA), p(ADC), p(ROR), p(udf), p(JMP), p(ADC), p(ROR), p(udf),
		p(BVS), p(ADC), p(udf), p(udf), p(udf), p(ADC), p(ROR), p(udf), p(SEI), p(ADC), p(udf), p(udf), p(udf), p(ADC), p(ROR), p(udf),
		p(udf), p(STA), p(udf), p(udf), p(STY), p(STA), p(STX), p(udf), p(DEY), p(udf), p(TXA), p(udf), p(STY), p(STA), p(STX), p(udf),
		p(BCC), p(STA), p(udf), p(udf), p(STY), p(STA), p(STX), p(udf), p(TYA), p(STA), p(TXS), p(udf), p(udf), p(STA), p(udf), p(udf),
		p(LDY), p(LDA), p(LDX), p(udf), p(LDY), p(LDA), p(LDX), p(udf), p(TAY), p(LDA), p(TAX), p(udf), p(LDY), p(LDA), p(LDX), p(udf),
		p(BCS), p(LDA), p(udf), p(udf), p(LDY), p(LDA), p(LDX), p(udf), p(CLV), p(LDA), p(TXS), p(udf), p(LDY), p(LDA), p(LDX), p(udf),
		p(CPY), p(CMP), p(udf), p(udf), p(CPY), p(CMP), p(DEC), p(udf), p(INY), p(CMP), p(DEX), p(udf), p(CPY), p(CMP), p(DEC), p(udf),
		p(BNE), p(CMP), p(udf), p(udf), p(udf), p(CMP), p(DEC), p(udf), p(CLD), p(CMP), p(udf), p(udf), p(udf), p(CMP), p(DEC), p(udf),
		p(CPX), p(SBC), p(udf), p(udf), p(CPX), p(SBC), p(INC), p(udf), p(INX), p(SBC), p(NOP), p(udf), p(CPX), p(SBC), p(INC), p(udf),
		p(BEQ), p(SBC), p(udf), p(udf), p(udf), p(SBC), p(INC), p(udf), p(SED), p(SBC), p(udf), p(udf), p(udf), p(SBC), p(INC), p(udf),
	)
#undef p

#define checkcarry(n) if (n & 0xFF00) { setflag6502(fC) } else { clearflag6502(fC) }
#define checkzero(n) if (n & 0xFF) { clearflag6502(fZ) } else { setflag6502(fZ) }
#define checksign(n) if (n & 0x80) { setflag6502(fN) } else { clearflag6502(fN) }

/datum/mos6502/proc/BRK()
	PC++
	push16(PC)
	push8(status | fB)
	setflag6502(fI)
	PC = read6502(0xFFFE) | read6502(0xFFFF) << 8

/datum/mos6502/proc/ORA()
	var/r = getvalue() | A
	checksign(r)
	checkzero(r)

	A = r & 0xFF

/datum/mos6502/proc/ASL()
	var/r = getvalue() << 1
	checkcarry(r)
	checkzero(r)
	checksign(r)

	setvalue(r)

/datum/mos6502/proc/PHP()
	push8(status | fB)

/datum/mos6502/proc/BPL()
	if (!(status & fN))
		PC += ea // relative address

/datum/mos6502/proc/CLC()
	clearflag6502(fC)

/datum/mos6502/proc/JSR()
	push16(PC - 1)
	PC = ea

/datum/mos6502/proc/AND()
	var/r = A & getvalue()
	checkzero(r)
	checksign(r)

	A = r & 0xFF

/datum/mos6502/proc/BIT()
	var/v = getvalue()
	var/r = A & v
	checkzero(r)
	status = (status & 0x3F) | (v & 0xC0)

/datum/mos6502/proc/ROL()
	var/r = (getvalue() << 1) | (status & fC)

	checkcarry(r)
	checkzero(r)
	checksign(r)

	setvalue(r)

/datum/mos6502/proc/PLP()
	status = pop8()

/datum/mos6502/proc/BMI()
	if (status & fZ)
		PC += ea // relative address

/datum/mos6502/proc/SEC()
	setflag6502(fC)

/datum/mos6502/proc/RTI()
	status = pop8()
	PC = pop16()

/datum/mos6502/proc/EOR()
	var/r = A ^ getvalue()
	checksign(r)
	checkzero(r)

	A = r & 0xFF

/datum/mos6502/proc/LSR()
	var/v = getvalue()
	var/r = v >> 1
	if (v & 1) setflag6502(fC)
	else clearflag6502(fC)
	checkzero(r)
	checksign(r)

	setvalue(r)

/datum/mos6502/proc/PHA()
	push8(A)

/datum/mos6502/proc/JMP()
	PC = ea

/datum/mos6502/proc/BVC()
	if (!(status & fV))
		PC += ea // relative address

/datum/mos6502/proc/CLI()
	clearflag6502(fI)

/datum/mos6502/proc/RTS()
	PC = pop16() + 1

/datum/mos6502/proc/ADC()
	var/v = getvalue()
	var/r = A + v + (status & fC)
	checkcarry(r)
	checkzero(r)
	if(!((A ^ v) & 0x80) && ((A ^ r) & 0x80)) setflag6502(fV)
	else clearflag6502(fV)
	checksign(r)

	if (status & fD)
		clearflag6502(fC)
		if ((A & 0x0F) > 0x09)
			A += 0x06
		if ((A & 0xF0) > 0x90)
			A += 0x60
			setflag6502(fC)
	A = r & 0xFF

/datum/mos6502/proc/ROR()
	var/v = getvalue()
	var/r = (v >> 1) | ((status & fC) << 7)

	if (v & 1) setflag6502(fC)
	else clearflag6502(fC)
	checkzero(r)
	checksign(r)

	setvalue(r)

/datum/mos6502/proc/PLA()
	A = pop8()
	checkzero(A)
	checksign(A)

/datum/mos6502/proc/BVS()
	if (status & fV)
		PC += ea // relative address

/datum/mos6502/proc/SEI()
	setflag6502(fI)

/datum/mos6502/proc/STA()
	setvalue(A)

/datum/mos6502/proc/STY()
	setvalue(Y)

/datum/mos6502/proc/STX()
	setvalue(X)

/datum/mos6502/proc/DEY()
	Y = (Y - 1) & 0xFF
	checkzero(Y)
	checksign(Y)

/datum/mos6502/proc/TXA()
	A = X
	checkzero(A)
	checksign(A)

/datum/mos6502/proc/BCC()
	if (!(status & fC))
		PC += ea // relative address

/datum/mos6502/proc/TYA()
	A = Y
	checkzero(A)
	checksign(A)

/datum/mos6502/proc/TXS()
	SP = X

/datum/mos6502/proc/LDY()
	Y = getvalue() & 0xFF
	checkzero(Y)
	checksign(Y)

/datum/mos6502/proc/LDA()
	A = getvalue() & 0xFF
	checkzero(A)
	checksign(A)

/datum/mos6502/proc/LDX()
	X = getvalue() & 0xFF
	checkzero(X)
	checksign(X)

/datum/mos6502/proc/TAY()
	Y = A
	checkzero(Y)
	checksign(Y)

/datum/mos6502/proc/TAX()
	X = A
	checkzero(X)
	checksign(X)

/datum/mos6502/proc/BCS()
	if (status & fC)
		PC += ea // relative address

/datum/mos6502/proc/CLV()
	clearflag6502(fV)

/datum/mos6502/proc/CPY()
	var/v = getvalue()
	var/r = Y - v
	if (Y >= (v & 0xFF)) setflag6502(fC)
	else clearflag6502(fC)
	if (Y == (v & 0xFF)) setflag6502(fZ)
	else clearflag6502(fZ)
	checksign(r)

/datum/mos6502/proc/CMP()
	var/v = getvalue()
	var/r = A - v
	if (A >= (v & 0xFF)) setflag6502(fC)
	else clearflag6502(fC)
	if (A == (v & 0xFF)) setflag6502(fZ)
	else clearflag6502(fZ)
	checksign(r)

/datum/mos6502/proc/DEC()
	var/r = (getvalue() - 1) & 0xFF
	checkzero(r)
	checksign(r)
	setvalue(r)

/datum/mos6502/proc/INY()
	Y = (Y + 1) & 0xFF
	checkzero(Y)
	checksign(Y)

/datum/mos6502/proc/DEX()
	X = (X - 1) & 0xFF
	checkzero(X)
	checksign(X)

/datum/mos6502/proc/BNE()
	if (!(status & fZ))
		PC += ea // relative address

/datum/mos6502/proc/CLD()
	clearflag6502(fD)

/datum/mos6502/proc/CPX()
	var/v = getvalue()
	var/r = X - v
	if (X >= (v & 0xFF)) setflag6502(fC)
	else clearflag6502(fC)
	if (X == (v & 0xFF)) setflag6502(fZ)
	else clearflag6502(fZ)
	checksign(r)

/datum/mos6502/proc/SBC()
	var/v = getvalue()
	var/r = A - v - !(status & fC)
	checkcarry(r)
	checkzero(r)
	if (((A ^ r) & 0x80) && ((A ^ v) & 0x80))
		setflag6502(fV)
	checksign(r)

	if (status & fD)
		clearflag6502(fC)
		A -= 0x66
		if ((A & 0x0F) > 0x09)
			A += 0x6
		if ((A & 0xF0) > 0x90)
			A += 0x60
			setflag6502(fC)
	A = r & 0xFF

/datum/mos6502/proc/INC()
	var/r = (getvalue() + 1) & 0xFF
	checkzero(r)
	checksign(r)
	setvalue(r)

/datum/mos6502/proc/INX()
	X = (X + 1) & 0xFF
	checkzero(X)
	checksign(X)

/datum/mos6502/proc/NOP()

/datum/mos6502/proc/BEQ()
	if (status & fZ)
		PC += ea // relative address

/datum/mos6502/proc/SED()
	setflag6502(fD)
