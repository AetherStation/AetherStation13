///////////////////////////
// Read Only Memory Bank //
///////////////////////////

/obj/item/mainframe_rom_bank
	name = "mainframe ROM bank"
	desc = "A read-only memory circuit board"
	icon = 'icons/obj/machines/mainframe.dmi'
	icon_state = "rom_bank"
	obj_flags = UNIQUE_RENAME
	var/datum/mos6502_memory_map/memory/read_only/data = new(1)

///////////////////////////
// Read Only Memory Unit //
///////////////////////////

/obj/machinery/mainframe/external/read_only_memory
	name = "read only memory unit"
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

///////////////////////////
//  ROM Bank Programmer  //
///////////////////////////

/obj/structure/rom_bank_editor
	name = "ROM bank programmer"
	icon = 'icons/obj/machines/mainframe.dmi'
	icon_state = "rom_editor"
	anchored = TRUE
	density = TRUE
	var/obj/item/mainframe_rom_bank/inserted

/obj/structure/rom_bank_editor/ui_data(mob/user)
	var/list/data = list()
	data["inserted"] = !!inserted
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
			to_chat(user, span_notice("There already is a ROM bank inside \the [src]."))
			return
		if (!user.transferItemToLoc(weapon, src))
			return
		inserted = weapon
		user.visible_message(span_notice("[user] puts \the [weapon] on \the [src]."))
		icon_state = "rom_editor_inserted"
		ui_interact(user)
		return
	return ..()

/obj/structure/rom_bank_editor/attack_hand_secondary(mob/user, list/modifiers)
	. = ..()
	if (. == SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN || !inserted)
		return
	user.put_in_hands(inserted)
	user.visible_message(span_notice("[user] takes \the [inserted] from \the [src]."))
	icon_state = "rom_editor"
	inserted = null

/obj/structure/rom_library
	name = "ROM database"
	desc = "Get your memory from here!"
	icon = 'icons/obj/machines/mainframe.dmi'
	icon_state = "rom_library"
	anchored = TRUE
	density = TRUE
	var/const/maximum_count = 16
	var/obj/item/mainframe_rom_bank/inserted

/obj/structure/rom_library/attackby(obj/item/weapon, mob/user, params)
	if (istype(weapon, /obj/item/mainframe_rom_bank))
		if (inserted)
			to_chat(user, span_notice("There already is a ROM bank inside \the [src]."))
			return
		if (!user.transferItemToLoc(weapon, src))
			return
		inserted = weapon
		icon_state = "rom_library_inserted"
		user.visible_message(span_notice("[user] puts \the [weapon] on \the [src]."))
		return
	return ..()

/obj/structure/rom_library/attack_hand_secondary(mob/user, list/modifiers)
	. = ..()
	if (. == SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN || !inserted)
		return
	user.put_in_hands(inserted)
	user.visible_message(span_notice("[user] takes \the [inserted] from \the [src]."))
	icon_state = "rom_library"
	inserted = null

/obj/structure/rom_library/ui_data(mob/user)
	var/list/data = list()
	data["inserted"] = !!inserted
	var/list/roms = list()
	for (var/n in SSpersistence.mainframe_roms)
		roms += n
	data["roms"] = roms
	return data

/obj/structure/rom_library/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "MainframeLibrary")
		ui.open()

/obj/structure/rom_library/ui_act(action, params)
	. = ..()
	if(.)
		return
	switch (action)
		if ("save")
			if (!inserted)
				return
			var/rom_name = copytext(inserted.name, 1, 16) // cut name.
			if (SSpersistence.mainframe_roms[rom_name])
				to_chat(usr, span_warning("This name is already taken."))
				playsound(src, 'sound/machines/terminal_error.ogg', 30, TRUE)
				return
			if (SSpersistence.mainframe_roms.len >= maximum_count)
				to_chat(usr, span_warning("There is too much stored in \the [src], make some space."))
				playsound(src, 'sound/machines/terminal_error.ogg', 30, TRUE)
				return
			playsound(src, 'sound/machines/terminal_success.ogg', 30, TRUE)
			SSpersistence.mainframe_roms[rom_name] = inserted.data.memory
			return
		if ("delete")
			if (!SSpersistence.mainframe_roms[params["name"]])
				return
			playsound(src, 'sound/machines/terminal_success.ogg', 30, TRUE)
			SSpersistence.mainframe_roms.Remove(params["name"])
			return
		if ("load")
			if (!SSpersistence.mainframe_roms[params["name"]] || !inserted)
				return
			playsound(src, 'sound/machines/terminal_success.ogg', 30, TRUE)
			inserted.name = params["name"]
			inserted.data.memory = SSpersistence.mainframe_roms[inserted.name]
			return
