/datum/mos6502
#define p(x) /datum/mos6502/proc/x
	var/static/instructions = list(
		p(brk), p(ora), p(udf), p(udf), p(udf), p(ora), p(asl), p(udf), p(php), p(ora), p(asl), p(udf), p(udf), p(ora), p(asl), p(udf),
		p(bpl), p(ora), p(udf), p(udf), p(udf), p(ora), p(asl), p(udf), p(clc), p(ora), p(udf), p(udf), p(udf), p(ora), p(asl), p(udf),
		p(jsr), p(and), p(udf), p(udf), p(bit), p(and), p(rol), p(udf), p(plp), p(and), p(rol), p(udf), p(bit), p(and), p(rol), p(udf),
		p(bmi), p(and), p(udf), p(udf), p(udf), p(and), p(rol), p(udf), p(sec), p(and), p(udf), p(udf), p(udf), p(and), p(rol), p(udf),
		p(rti), p(eor), p(udf), p(udf), p(udf), p(eor), p(lsr), p(udf), p(pha), p(eor), p(lsr), p(udf), p(jmp), p(eor), p(lsr), p(udf),
		p(bvc), p(eor), p(udf), p(udf), p(udf), p(eor), p(lsr), p(udf), p(cli), p(eor), p(udf), p(udf), p(udf), p(eor), p(lsr), p(udf),
		p(rts), p(adc), p(udf), p(udf), p(udf), p(adc), p(ror), p(udf), p(pla), p(adc), p(ror), p(udf), p(jmp), p(adc), p(ror), p(udf),
		p(bvs), p(adc), p(udf), p(udf), p(udf), p(adc), p(ror), p(udf), p(sei), p(adc), p(udf), p(udf), p(udf), p(adc), p(ror), p(udf),
		p(udf), p(sta), p(udf), p(udf), p(sty), p(sta), p(stx), p(udf), p(dey), p(udf), p(txa), p(udf), p(sty), p(sta), p(stx), p(udf),
		p(bcc), p(sta), p(udf), p(udf), p(sty), p(sta), p(stx), p(udf), p(tya), p(sta), p(txs), p(udf), p(udf), p(sta), p(udf), p(udf),
		p(ldy), p(lda), p(ldx), p(udf), p(ldy), p(lda), p(ldx), p(udf), p(tay), p(lda), p(tax), p(udf), p(ldy), p(lda), p(ldx), p(udf),
		p(bcs), p(lda), p(udf), p(udf), p(ldy), p(lda), p(ldx), p(udf), p(clv), p(lda), p(txs), p(udf), p(ldy), p(lda), p(ldx), p(udf),
		p(cpy), p(cmp), p(udf), p(udf), p(cpy), p(cmp), p(dec), p(udf), p(iny), p(cmp), p(dex), p(udf), p(cpy), p(cmp), p(dec), p(udf),
		p(bne), p(cmp), p(udf), p(udf), p(udf), p(cmp), p(dec), p(udf), p(cld), p(cmp), p(udf), p(udf), p(udf), p(cmp), p(dec), p(udf),
		p(cpx), p(sbc), p(udf), p(udf), p(cpx), p(sbc), p(inc), p(udf), p(inx), p(sbc), p(nop), p(udf), p(cpx), p(sbc), p(inc), p(udf),
		p(beq), p(sbc), p(udf), p(udf), p(udf), p(sbc), p(inc), p(udf), p(sed), p(sbc), p(udf), p(udf), p(udf), p(sbc), p(inc), p(udf),
	)
#undef p

#define checkcarry(n) if (n & 0xFF00) { setflag6502(flagC) } else { clearflag6502(flagC) }
#define checkzero(n) if (n & 0xFF) { clearflag6502(flagZ) } else { setflag6502(flagZ) }
#define checksign(n) if (n & 0x80) { setflag6502(flagN) } else { clearflag6502(flagN) }

/datum/mos6502/proc/brk()
	PC++
	push16(PC)
	push8(status | flagB)
	setflag6502(flagI)
	PC = read6502(0xFFFE) | read6502(0xFFFF) << 8

/datum/mos6502/proc/ora()
	var/r = getvalue() | A
	checksign(r)
	checkzero(r)

	A = r & 0xFF

/datum/mos6502/proc/asl()
	var/r = getvalue() << 1
	checkcarry(r)
	checkzero(r)
	checksign(r)

	setvalue(r)

/datum/mos6502/proc/php()
	push8(status | flagB)

/datum/mos6502/proc/bpl()
	if (!(status & flagN))
		PC += ea // relative address

/datum/mos6502/proc/clc()
	clearflag6502(flagC)

/datum/mos6502/proc/jsr()
	push16(PC - 1)
	PC = ea

/datum/mos6502/proc/and()
	var/r = A & getvalue()
	checkzero(r)
	checksign(r)

	A = r & 0xFF

/datum/mos6502/proc/bit()
	var/v = getvalue()
	var/r = A & v
	checkzero(r)
	status = (status & 0x3F) | (v & 0xC0)

/datum/mos6502/proc/rol()
	var/r = (getvalue() << 1) | (status & flagC)

	checkcarry(r)
	checkzero(r)
	checksign(r)

	setvalue(r)

/datum/mos6502/proc/plp()
	status = pop8()

/datum/mos6502/proc/bmi()
	if (status & flagZ)
		PC += ea // relative address

/datum/mos6502/proc/sec()
	setflag6502(flagC)

/datum/mos6502/proc/rti()
	status = pop8()
	PC = pop16()

/datum/mos6502/proc/eor()
	var/r = A ^ getvalue()
	checksign(r)
	checkzero(r)

	A = r & 0xFF

/datum/mos6502/proc/lsr()
	var/v = getvalue()
	var/r = v >> 1
	if (v & 1) setflag6502(flagC)
	else clearflag6502(flagC)
	checkzero(r)
	checksign(r)

	setvalue(r)

/datum/mos6502/proc/pha()
	push8(A)

/datum/mos6502/proc/jmp()
	PC = ea

/datum/mos6502/proc/bvc()
	if (!(status & flagV))
		PC += ea // relative address

/datum/mos6502/proc/cli()
	clearflag6502(flagI)

/datum/mos6502/proc/rts()
	PC = pop16() + 1

/datum/mos6502/proc/adc()
	var/v = getvalue()
	var/r = A + v + (status & flagC)
	checkcarry(r)
	checkzero(r)
	if(!((A ^ v) & 0x80) && ((A ^ r) & 0x80)) setflag6502(flagV)
	else clearflag6502(flagV)
	checksign(r)

	if (status & flagD)
		clearflag6502(flagC)
		if ((A & 0x0F) > 0x09)
			A += 0x06
		if ((A & 0xF0) > 0x90)
			A += 0x60
			setflag6502(flagC)
	A = r & 0xFF

/datum/mos6502/proc/ror()
	var/v = getvalue()
	var/r = (v >> 1) | ((status & flagC) << 7)

	if (v & 1) setflag6502(flagC)
	else clearflag6502(flagC)
	checkzero(r)
	checksign(r)

	setvalue(r)

/datum/mos6502/proc/pla()
	A = pop8()
	checkzero(A)
	checksign(A)

/datum/mos6502/proc/bvs()
	if (status & flagV)
		PC += ea // relative address

/datum/mos6502/proc/sei()
	setflag6502(flagI)

/datum/mos6502/proc/sta()
	setvalue(A)

/datum/mos6502/proc/sty()
	setvalue(Y)

/datum/mos6502/proc/stx()
	setvalue(X)

/datum/mos6502/proc/dey()
	Y = (Y - 1) & 0xFF
	checkzero(Y)
	checksign(Y)

/datum/mos6502/proc/txa()
	A = X
	checkzero(A)
	checksign(A)

/datum/mos6502/proc/bcc()
	if (!(status & flagC))
		PC += ea // relative address

/datum/mos6502/proc/tya()
	A = Y
	checkzero(A)
	checksign(A)

/datum/mos6502/proc/txs()
	SP = X

/datum/mos6502/proc/ldy()
	Y = getvalue() & 0xFF
	checkzero(Y)
	checksign(Y)

/datum/mos6502/proc/lda()
	A = getvalue() & 0xFF
	checkzero(A)
	checksign(A)

/datum/mos6502/proc/ldx()
	X = getvalue() & 0xFF
	checkzero(X)
	checksign(X)

/datum/mos6502/proc/tay()
	Y = A
	checkzero(Y)
	checksign(Y)

/datum/mos6502/proc/tax()
	X = A
	checkzero(X)
	checksign(X)

/datum/mos6502/proc/bcs()
	if (status & flagC)
		PC += ea // relative address

/datum/mos6502/proc/clv()
	clearflag6502(flagV)

/datum/mos6502/proc/cpy()
	var/v = getvalue()
	var/r = Y - v
	if (Y >= (v & 0xFF)) setflag6502(flagC)
	else clearflag6502(flagC)
	if (Y == (v & 0xFF)) setflag6502(flagZ)
	else clearflag6502(flagZ)
	checksign(r)

/datum/mos6502/proc/cmp()
	var/v = getvalue()
	var/r = A - v
	if (A >= (v & 0xFF)) setflag6502(flagC)
	else clearflag6502(flagC)
	if (A == (v & 0xFF)) setflag6502(flagZ)
	else clearflag6502(flagZ)
	checksign(r)

/datum/mos6502/proc/dec()
	var/r = (getvalue() - 1) & 0xFF
	checkzero(r)
	checksign(r)
	setvalue(r)

/datum/mos6502/proc/iny()
	Y = (Y + 1) & 0xFF
	checkzero(Y)
	checksign(Y)

/datum/mos6502/proc/dex()
	X = (X - 1) & 0xFF
	checkzero(X)
	checksign(X)

/datum/mos6502/proc/bne()
	if (!(status & flagZ))
		PC += ea // relative address

/datum/mos6502/proc/cld()
	clearflag6502(flagD)

/datum/mos6502/proc/cpx()
	var/v = getvalue()
	var/r = X - v
	if (X >= (v & 0xFF)) setflag6502(flagC)
	else clearflag6502(flagC)
	if (X == (v & 0xFF)) setflag6502(flagZ)
	else clearflag6502(flagZ)
	checksign(r)

/datum/mos6502/proc/sbc()
	var/v = getvalue()
	var/r = A - v - !(status & flagC)
	checkcarry(r)
	checkzero(r)
	if (((A ^ r) & 0x80) && ((A ^ v) & 0x80))
		setflag6502(flagV)
	checksign(r)

	if (status & flagD)
		clearflag6502(flagC)
		A -= 0x66
		if ((A & 0x0F) > 0x09)
			A += 0x6
		if ((A & 0xF0) > 0x90)
			A += 0x60
			setflag6502(flagC)
	A = r & 0xFF

/datum/mos6502/proc/inc()
	var/r = (getvalue() + 1) & 0xFF
	checkzero(r)
	checksign(r)
	setvalue(r)

/datum/mos6502/proc/inx()
	X = (X + 1) & 0xFF
	checkzero(X)
	checksign(X)

/datum/mos6502/proc/nop()

/datum/mos6502/proc/beq()
	if (status & flagZ)
		PC += ea // relative address

/datum/mos6502/proc/sed()
	setflag6502(flagD)

#undef flagC
#undef flagZ
#undef flagI
#undef flagD
#undef flagB
// ?
#undef flagV
#undef flagN

#undef clearflag6502
#undef setflag6502

#undef read6502
#undef write6502
