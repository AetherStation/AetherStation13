/obj/machinery/mainframe
	icon = 'icons/obj/machines/mainframe.dmi'
	density = TRUE

/obj/machinery/mainframe/main_unit
	name = "Main Unit"
	desc = "Das komputermaschine ist nicht für der gefingerpoken und mittengraben! Zo relaxen und watschen der blinkenlichten."
	icon_state = "main_unit"
	subsystem_type = /datum/controller/subsystem/processing/fastprocess
	var/on = FALSE
	var/datum/mos6502/processor
	var/datum/mos6502_memory_map/signal/peripheral_memory_page

/obj/machinery/mainframe/main_unit/Initialize()
	. = ..()
	processor = new()
	// Random Access Memory.
	var/datum/mos6502_memory_map/memory/M = new(16)
	processor.add_memory_map(M, 0)
	// peripherals
	peripheral_memory_page = new(1)
	processor.add_memory_map(peripheral_memory_page, 32)
	for (var/obj/machinery/mainframe/external/E in oview(5))
		E.set_parent(src)

/obj/machinery/mainframe/main_unit/process(delta_time)
	if (!on)
		return
	// unrolled loop
	processor.execute()
	processor.execute()
	processor.execute()
	processor.execute()
	processor.execute()

/obj/machinery/mainframe/main_unit/examine(mob/user)
	. = ..()
	. += "It is currently [on ? "running" : "off"]."
	if(!(machine_stat & (NOPOWER|BROKEN)) && on)
		. += "A [num2text(processor.A, 3, 8)] X [num2text(processor.X, 3, 8)] Y [num2text(processor.Y, 3, 8)]"
		. += "SP [num2text(processor.SP, 3, 8)] PC [num2text(processor.PC, 6, 8)]"

/obj/machinery/mainframe/external
	var/obj/machinery/mainframe/main_unit/parent

/obj/machinery/mainframe/external/Destroy()
	. = ..()
	remove_parent()

/obj/machinery/mainframe/external/proc/set_parent(p)
	parent = p

/obj/machinery/mainframe/external/proc/remove_parent()
	parent = null

/obj/machinery/mainframe/external/read_only_memory
	name = "ROM Unit"
	icon_state = "rom_unit"
	var/obj/item/mainframe_rom_bank/banks[4]

/obj/machinery/mainframe/external/read_only_memory/Initialize()
	. = ..()
	for (var/i in 1 to 4)
		banks[i] = new /obj/item/mainframe_rom_bank(src)

/obj/machinery/mainframe/external/read_only_memory/set_parent(p)
	. = ..()
	for (var/i in 1 to 4)
		parent.processor.add_memory_map(banks[i].data, 256 - i)

/obj/machinery/mainframe/external/read_only_memory/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if (.)
		return
	var/L = list()
	for (var/i in 1 to 4)
		if (banks[i])
			L += "[i]"
	var/S = text2num(input("Select slot to remove memory bank from.", "ROM Unit") in L)
	user.put_in_hands(banks[S])
	parent.processor.remove_memory_map(banks[S].data)
	banks[S] = null

/obj/machinery/mainframe/external/read_only_memory/attackby(obj/item/weapon, mob/user, params)
	if (istype(weapon, /obj/item/mainframe_rom_bank))
		var/list/L = list()
		for (var/i in 1 to 4)
			if (!banks[i])
				L += "[i]"
		if (!L.len)
			to_chat(user, span_notice("There is no space for \the [weapon]."))
			return
		var/S = text2num(input("Select slot to put \the [weapon] in.", "ROM Unit") in L)
		if (!user.transferItemToLoc(weapon, src))
			return
		banks[S] = weapon
		parent.processor.add_memory_map(banks[S].data, 256 - S)
		user.visible_message(span_notice("[user] inserts \the [weapon] into \the [src]."))
		return
	return ..()

/obj/item/mainframe_rom_bank
	name = "mainframe ROM bank"
	desc = "A read-only memory circuit board"
	icon = 'icons/obj/machines/mainframe.dmi'
	icon_state = "rom_bank"
	var/datum/mos6502_memory_map/memory/data = new(1)

/obj/machinery/mainframe/external/removable_storage
	name = "Cassette Drive"
	icon_state = "cassette_drive"
	var/obj/item/mainframe_memory_cassette/inserted

/obj/machinery/mainframe/external/removable_storage/remove_parent()
	if (inserted)
		parent.processor.remove_memory_map(inserted.data)
	..()

/obj/machinery/mainframe/external/removable_storage/attackby(obj/item/weapon, mob/user, params)
	if (istype(weapon, /obj/item/mainframe_memory_cassette))
		if (inserted)
			to_chat(user, span_notice("There already is a disk inside \the [src]."))
			return
		if (!user.transferItemToLoc(weapon, src))
			return
		inserted = weapon
		parent.processor.add_memory_map(inserted.data, 16)
		user.visible_message(span_notice("[user] inserts \the [weapon] into \the [src]."))
		return
	return ..()

/obj/machinery/mainframe/external/removable_storage/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if (. || !inserted)
		return

	user.put_in_hands(inserted)
	parent.processor.remove_memory_map(inserted.data)
	user.visible_message(span_notice("[user] ejects \the [inserted] from \the [src]."))
	inserted = null

/obj/item/mainframe_memory_cassette
	name = "mainframe memory cassette"
	desc = "Massive cassette disk."
	// Disk is after RAM in address space.
	var/datum/mos6502_memory_map/memory/data = new(16)

/obj/machinery/mainframe/external/peripheral
	var/peripheral_address_start = 0
	var/peripheral_address_end = 4

/obj/machinery/mainframe/external/peripheral/set_parent(p)
	. = ..()
	RegisterSignal(parent.peripheral_memory_page, COMSIG_MOS6502_MEMORY_WRITE, .proc/mem_write)
	RegisterSignal(parent.peripheral_memory_page, COMSIG_MOS6502_MEMORY_READ, .proc/mem_read)

/obj/machinery/mainframe/external/peripheral/proc/mem_write(source, address, value)
	if (address < peripheral_address_start || address >= peripheral_address_end)
		return FALSE
	return TRUE

/obj/machinery/mainframe/external/peripheral/proc/mem_read(source, address)
	if (address < peripheral_address_start || address >= peripheral_address_end)
		return FALSE
	return TRUE

/obj/machinery/mainframe/external/peripheral/terminal
	name = "Terminal"
	desc = "Text mode only, I am afraid it is terminal."
	icon_state = "terminal"
	var/current_line = 0
	var/current_text[20] // 20 lines
	var/input_queue = ""

/obj/machinery/mainframe/external/peripheral/terminal/Initialize()
	. = ..()
	for (var/i in 1 to 20)
		current_text[i] = ""

/obj/machinery/mainframe/external/peripheral/terminal/mem_write(source, address, value)
	if (!..())
		return
	switch (address - peripheral_address_start)
		if (0) display_character(value)

/obj/machinery/mainframe/external/peripheral/terminal/proc/display_character(ascii)
	switch (ascii)
		if (0) return
		if (10, 13) current_line = (current_line + 1) % 20
		if (8)
			var/C = current_text[current_line + 1]
			current_text[current_line + 1] = copytext(C, 1, length(C))
		if (20) // XOFF is used as clear in this.
			for (var/i in 1 to 20)
				current_text[i] = ""
			current_line = 0
		else current_text[current_line + 1] += ascii2text(ascii)
	if (length(current_text[current_line + 1]) >= 40)
		current_line = (current_line + 1) % 20

/obj/machinery/mainframe/external/peripheral/printer
	name = "Printer"
	desc = "Likely the most advanced component of the entire system due to it using no ink."
	icon_state = "printer"
	peripheral_address_start = 4
	peripheral_address_end = 8
	var/paper_count = 6
	var/current_text = ""

/obj/machinery/mainframe/external/peripheral/printer/mem_write(source, address, value)
	if (!..())
		return
	switch (address - peripheral_address_start)
		if (0) print_character(value)

/obj/machinery/mainframe/external/peripheral/printer/proc/print_character(ascii)
	if (ascii == 0)
		print_paper()
		return
	if (length(current_text) >= 1000) // lets just keep the max at 1000 characters.
		print_paper()
	current_text += ascii2text(ascii)

/obj/machinery/mainframe/external/peripheral/printer/proc/print_paper()
	if (paper_count)
		var/obj/item/paper/P = new(get_turf(src))
		P.setText(html_encode(current_text))
		paper_count--
	current_text = ""
