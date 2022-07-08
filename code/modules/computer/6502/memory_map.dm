/datum/mos6502_memory_map
	var/page_start
	var/page_count

/datum/mos6502_memory_map/New(start, count)
	. = ..()
	page_start = start
	page_count = count

/datum/mos6502_memory_map/proc/write(address, value)

/datum/mos6502_memory_map/proc/read(address)

/datum/mos6502_memory_map/memory
	var/start_address
	var/memory = ""

/datum/mos6502_memory_map/memory/New(start, count)
	. = ..()
	start_address = start * 256
	for (var/i in 1 to count * 256)
		memory += "00"

/datum/mos6502_memory_map/memory/write(address, value)
	address = (address - start_address) << 1
	memory = splicetext(memory, address + 1, address + 3, num2text(value, 2, 16))

/datum/mos6502_memory_map/memory/read(address)
	address = (address - start_address) << 1
	return text2num(copytext(memory, address + 1, address + 3), 16)