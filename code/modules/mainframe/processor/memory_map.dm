/datum/mos6502_memory_map
	var/start_address
	var/page_start
	var/page_count

/datum/mos6502_memory_map/New(count)
	. = ..()
	page_count = count

/datum/mos6502_memory_map/proc/write(address, value)

/datum/mos6502_memory_map/proc/read(address)

/datum/mos6502_memory_map/memory
	var/memory = ""

/datum/mos6502_memory_map/memory/New(count)
	. = ..()
	for (var/i in 1 to count * 256)
		memory += "00"

/datum/mos6502_memory_map/memory/write(address, value)
	address = (address - start_address) << 1
	memory = splicetext(memory, address + 1, address + 3, num2text(value, 2, 16))

/datum/mos6502_memory_map/memory/read(address)
	address = (address - start_address) << 1
	return text2num(copytext(memory, address + 1, address + 3), 16)

/datum/mos6502_memory_map/memory/read_only/write(address, value)
	return

/datum/mos6502_memory_map/signal

/datum/mos6502_memory_map/signal/write(address, value)
	SEND_SIGNAL(src, COMSIG_MOS6502_MEMORY_WRITE, address - start_address, value)

/datum/mos6502_memory_map/signal/read(address)
	return SEND_SIGNAL(src, COMSIG_MOS6502_MEMORY_READ, address - start_address)
