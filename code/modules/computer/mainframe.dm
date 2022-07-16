/obj/machinery/mainframe
	icon = 'icons/obj/machines/mainframe.dmi'
	density = TRUE

/obj/machinery/mainframe/main_unit
	name = "Main Unit"
	desc = "Das komputermaschine ist nicht für der gefingerpoken und mittengraben! Zo relaxen und watschen der blinkenlichten."
	icon_state = "main_unit_off"
	subsystem_type = /datum/controller/subsystem/processing/fastprocess
	var/on = FALSE
	var/pause = FALSE
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
	if (!on || pause)
		return
	// unrolled loop
	processor.execute()
	processor.execute()
	processor.execute()
	processor.execute()
	processor.execute()

/obj/machinery/mainframe/main_unit/proc/toggle_power()
	if (!(machine_stat & (NOPOWER|BROKEN)))
		on = !on
		visible_message(span_notice("\the [src] turns [on ? "on" : "off"]."))
		icon_state = "main_unit[on ? "" : "_off"]"
		processor.reset()

/obj/machinery/mainframe/main_unit/ui_data(mob/user)
	var/list/data = list()
	data["on"] = on
	data["pause"] = pause
	if (on)
		data["A"] = num2text(processor.A, 2, 16)
		data["X"] = num2text(processor.X, 2, 16)
		data["Y"] = num2text(processor.Y, 2, 16)
		data["SP"] = num2text(processor.SP, 2, 16)
		data["PC"] = num2text(processor.PC, 4, 16)
		data["status"] = processor.status
	if (pause)
		data["opcode"] = num2text(processor.opcode - 1, 2, 16)
	return data

/obj/machinery/mainframe/main_unit/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "MainframeMainUnit")
		ui.open()

/obj/machinery/mainframe/main_unit/ui_act(action, params)
	. = ..()
	if(.)
		return
	switch (action)
		if ("power")
			toggle_power()
		if ("reset")
			processor.reset()
		if ("step")
			if (!pause)
				pause = TRUE
			processor.execute()
		if ("pause")
			pause = !pause

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

/obj/machinery/mainframe/external/read_only_memory/ui_data(mob/user)
	var/list/data = list()
	data["banks"] = list()
	for (var/i in 1 to 4)
		data["banks"] += banks[i] ? banks[i].name : ""
	return data

/obj/machinery/mainframe/external/read_only_memory/ui_act(action, params)
	. = ..()
	if(.)
		return
	if (!params["slot"])
		return
	var/I = text2num(params["slot"])
	if (banks[I])
		var/obj/item/mainframe_rom_bank/B = banks[I]
		usr.put_in_hands(B)
		parent?.processor.remove_memory_map(B.data)
		banks[I] = null
		usr.visible_message(span_notice("[usr] removes \the [B] from \the [src]."))
	else
		var/obj/item/mainframe_rom_bank/B = usr.get_active_held_item()
		if (!istype(B))
			return
		if (!usr.transferItemToLoc(B, src))
			return
		banks[I] = B
		parent?.processor.add_memory_map(B.data, 256 - I)
		usr.visible_message(span_notice("[usr] inserts \the [B] into \the [src]."))

/obj/machinery/mainframe/external/read_only_memory/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "MainframeRomUnit")
		ui.open()

/obj/structure/rom_bank_editor
	name = "ROM Bank Editor" // todo: better name.
	icon = 'icons/obj/machines/mainframe.dmi'
	var/obj/item/mainframe_rom_bank/inserted

/obj/structure/rom_bank_editor/ui_data(mob/user)
	var/list/data = list()
	if (inserted)
		data["memory"] = inserted.data.memory
	return data

/obj/structure/rom_bank_editor/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui && inserted) // don't show UI if nothing is inserted.
		ui = new(user, src, "MainframePageEditor")
		ui.open()

/obj/structure/rom_bank_editor/ui_act(action, params)
	. = ..()
	if(.)
		return
	if (action == "save")
		var/M = params["data"]
		if (length(M) != 512) // 256 bytes as hexadecimal.
			return FALSE
		playsound(src, 'sound/machines/ping.ogg', 30, TRUE)
		inserted.data.memory = params["data"]

/obj/structure/rom_bank_editor/attackby(obj/item/weapon, mob/user, params)
	if (istype(weapon, /obj/item/mainframe_rom_bank))
		if (inserted)
			to_chat(user, span_notice("There already is a disk inside \the [src]."))
			return
		if (!user.transferItemToLoc(weapon, src))
			return
		inserted = weapon
		user.visible_message(span_notice("[user] puts \the [weapon] on \the [src]."))
		ui_interact(user)
		return
	return ..()

/obj/structure/rom_bank_editor/attack_hand_secondary(mob/user, list/modifiers)
	. = ..()
	if (. || !inserted)
		return
	user.put_in_hands(inserted)
	user.visible_message(span_notice("[user] takes \the [inserted] from \the [src]."))
	ui_interact(user)
	inserted = null

/obj/item/mainframe_rom_bank
	name = "mainframe ROM bank"
	desc = "A read-only memory circuit board"
	icon = 'icons/obj/machines/mainframe.dmi'
	icon_state = "rom_bank"
	obj_flags = UNIQUE_RENAME
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
	SIGNAL_HANDLER
	if (address < peripheral_address_start || address >= peripheral_address_end)
		return FALSE
	return TRUE

/obj/machinery/mainframe/external/peripheral/proc/mem_read(source, address)
	SIGNAL_HANDLER
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

/obj/machinery/mainframe/external/peripheral/terminal/mem_read(source, address, value)
	if (!..())
		return
	switch (address - peripheral_address_start)
		if (1)
			if (!input_queue)
				return 0
			var/C = input_queue[1]
			input_queue = copytext(input_queue, 2)
			return text2ascii(C)

/obj/machinery/mainframe/external/peripheral/terminal/proc/display_character(ascii)
	switch (ascii)
		if (0) return
		if (10, 13)
			current_line = (current_line + 1) % 20
			current_text[current_line + 1] = ""
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
		current_text[current_line + 1] = ""

/obj/machinery/mainframe/external/peripheral/terminal/ui_data(mob/user)
	var/list/data = list()
	data["text"] = current_text
	data["queue_length"] = length(input_queue)
	return data

/obj/machinery/mainframe/external/peripheral/terminal/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "MainframeTerminal")
		ui.open()

/obj/machinery/mainframe/external/peripheral/terminal/ui_act(action, params)
	. = ..()
	if(.)
		return
	if (action == "send")
		var/M = params["data"]
		if (length(input_queue) + length(M) >= 256)
			return FALSE
		input_queue += M

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
