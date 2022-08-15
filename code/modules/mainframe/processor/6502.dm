#define flagC 1 // flag Carry
#define flagZ 2 // flag Zero
#define flagI 4 // flag Interrupt
#define flagD 8 // flag Decimal
#define flagB 16 // flag Break
// ?
#define flagV 64 // flag oVerflow
#define flagN 128 // flag Negative (sign)

#define clearflag6502(flag) status &= (~flag)
#define setflag6502(flag) status |= flag

#define read6502(address) (memory_map[(address >> 8) + 1]?.read(address))
#define write6502(address, value) (memory_map[(address >> 8) + 1]?.write(address, value & 0xFF))

#define imm 0
#define rel 1
#define zpg 2
#define zpx 3
#define zpy 4
#define abo 5
#define abx 6
#define aby 7
#define ind 8
#define idx 9
#define idy 10
#define acc 11
#define imp 12
/datum/mos6502
	var/A = 0
	var/X = 0
	var/Y = 0
	var/SP = 0
	var/PC = 0
	var/status = 0

	var/jam = FALSE

	var/ea = 0

	var/datum/mos6502_memory_map/memory_map[256]
	var/opcode

	var/static/addressing = list(
		/*	0    1    2    3    4    5    6    7    8    9    A    B    C    D    E    F   */
	/* 0 */ imp, idx, imp, imp, zpg, zpg, zpg, imp, imp, imm, acc, imp, abo, abo, abo, imp,
	/* 1 */ rel, idy, imp, imp, zpx, zpx, zpx, imp, imp, aby, imp, imp, abx, abx, abx, imp,
	/* 2 */ abo, idx, imp, imp, zpg, zpg, zpg, imp, imp, imm, acc, imp, abo, abo, abo, imp,
	/* 3 */ rel, idy, imp, imp, zpx, zpx, zpx, imp, imp, aby, imp, imp, abx, abx, abx, imp,
	/* 4 */ imp, idx, imp, imp, zpg, zpg, zpg, imp, imp, imm, acc, imp, abo, abo, abo, imp,
	/* 5 */ rel, idy, imp, imp, zpx, zpx, zpx, imp, imp, aby, imp, imp, abx, abx, abx, imp,
	/* 6 */ imp, idx, imp, imp, zpg, zpg, zpg, imp, imp, imm, acc, imp, ind, abo, abo, imp,
	/* 7 */ rel, idy, imp, imp, zpx, zpx, zpx, imp, imp, aby, imp, imp, abx, abx, abx, imp,
	/* 8 */ imm, idx, imp, imp, zpg, zpg, zpg, imp, imp, imm, imp, imp, abo, abo, abo, imp,
	/* 9 */ rel, idy, imp, imp, zpx, zpx, zpy, imp, imp, aby, imp, imp, abx, abx, aby, imp,
	/* A */ imm, idx, imm, imp, zpg, zpg, zpg, imp, imp, imm, imp, imp, abo, abo, abo, imp,
	/* B */ rel, idy, imp, imp, zpx, zpx, zpy, imp, imp, aby, imp, imp, abx, abx, aby, imp,
	/* C */ imm, idx, imp, imp, zpg, zpg, zpg, imp, imp, imm, imp, imp, abo, abo, abo, imp,
	/* D */ rel, idy, imp, imp, zpx, zpx, zpx, imp, imp, aby, imp, imp, abx, abx, abx, imp,
	/* E */ imm, idx, imp, imp, zpg, zpg, zpg, imp, imp, imm, imp, imp, abo, abo, abo, imp,
	/* F */ rel, idy, imp, imp, zpx, zpx, zpx, imp, imp, aby, imp, imp, abx, abx, aby, imp,
	)

/datum/mos6502/New()
	. = ..()
	reset()

/datum/mos6502/proc/add_memory_map(datum/mos6502_memory_map/M, page_start)
	M.page_start = page_start // used in removing.
	M.start_address = page_start * 256
	for (var/i in (page_start + 1) to (page_start + M.page_count))
		if (memory_map[i])
			CRASH("Attempted to add memory map to used page.")
		memory_map[i] = M

/datum/mos6502/proc/remove_memory_map(datum/mos6502_memory_map/M)
	for (var/i in (M.page_start + 1) to (M.page_start + M.page_count))
		if (!memory_map[i])
			CRASH("Attempted to remove memory map not added.")
		memory_map[i] = null

/datum/mos6502/proc/reset()
	PC = read6502(0xFFFC) | read6502(0xFFFD) << 8
	A = 0
	X = 0
	Y = 0
	SP = 0xFD
	status = 0
	jam = FALSE

/datum/mos6502/proc/irq() // Interrupt Request
	if (!(status & flagI))
		push16(PC)
		push8(status)
		setflag6502(flagI)
		PC = read6502(0xFFFE) | (read6502(0xFFFF) << 8)

/datum/mos6502/proc/nmi() // Non-Maskable Interrupt
	push16(PC)
	push8(status)
	setflag6502(flagI)
	PC = read6502(0xFFFA) | (read6502(0xFFFB) << 8)

/datum/mos6502/proc/execute()
	if (jam) return
	opcode = read6502(PC) + 1 // BYOND list index starts from 1 so that is why the + 1
	PC++
	switch (addressing[opcode])
		if (imm) // immediate
			ea = PC++
		if (rel) // XXX: this uses the ea variable because there is no instruction that has another addressing mode with this.
			ea = read6502(PC)
			ea -= ((ea & 0x80) * 2) // rel is signed.
			PC++
		if (zpg)
			ea = read6502(PC)
			PC++
		if (zpx)
			ea = (read6502(PC) + X) & 0xFF
			PC++
		if (zpy)
			ea = (read6502(PC) + Y) & 0xFF
			PC++
		if (abo)
			ea = read6502(PC) | (read6502(PC + 1) << 8)
			PC += 2
		if (abx)
			ea = read6502(PC) | (read6502(PC + 1) << 8)
			ea += X
			PC += 2
		if (aby)
			ea = read6502(PC) | (read6502(PC + 1) << 8)
			ea += Y
			PC += 2
		if (ind)
			var/r = read6502(PC) | (read6502(PC + 1) << 8)
			var/r2 = (r & 0xFF00) | ((r + 1) & 0x00FF) // replicate 6502 page-boundary bug
			ea = read6502(r) | (read6502(r2) << 8)
			PC += 2
		if (idx)
			var/r = read6502(PC) + (X & 0xFF)
			ea = read6502(r & 0xFF) | (read6502((r + 1) & 0xFF) << 8)
			PC++
		if (idy)
			var/r = read6502(PC)
			var/r2 = (r & 0xFF00) | ((r + 1) & 0x00FF)
			ea = read6502(r) | (read6502(r2) << 8)
			ea += Y
			PC++
	call(src, instructions[opcode])()


/datum/mos6502/proc/udf()
	jam = TRUE // while most "illegal opcodes" don't jam the processor, I am going to jam it here always.

/datum/mos6502/proc/getvalue()
	if (addressing[opcode] == acc)
		return A & 0xFF
	return read6502(ea)

/datum/mos6502/proc/setvalue(val)
	if (addressing[opcode] == acc)
		A = val & 0xFF
	write6502(ea, val)

#define STACK_BASE 0x100

/datum/mos6502/proc/push8(value)
	write6502(STACK_BASE + SP, value)
	if (SP == 0) SP = 0xFF
	else SP--

/datum/mos6502/proc/push16(value)
	write6502(STACK_BASE + SP, (value >> 8) & 0xFF)
	write6502(STACK_BASE + ((SP - 1) & 0xFF), value & 0xFF)
	SP = WRAP(SP - 2, 0, 256)

/datum/mos6502/proc/pop8()
	if (SP == 0xFF) SP = 0
	else SP++
	return read6502(STACK_BASE + SP)

/datum/mos6502/proc/pop16()
	var/r = read6502(STACK_BASE + ((SP + 1) & 0xFF)) | (read6502(STACK_BASE + ((SP + 2) & 0xFF)) << 8)
	SP += 2
	return r

#undef STACK_BASE

#undef imm
#undef rel
#undef zpg
#undef zpx
#undef zpy
#undef abo
#undef abx
#undef aby
#undef ind
#undef idx
#undef idy
#undef acc
#undef imp
