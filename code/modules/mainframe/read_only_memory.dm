///////////////////////////
// Read Only Memory Bank //
///////////////////////////

/obj/item/mainframe_rom_bank
	name = "mainframe ROM bank"
	desc = "A read-only memory circuit board"
	icon = 'icons/obj/machines/mainframe.dmi'
	icon_state = "rom_bank"
	obj_flags = UNIQUE_RENAME
	var/datum/mos6502_memory_map/memory/data = new(1)

///////////////////////////
// Read Only Memory Unit //
///////////////////////////

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

///////////////////////////
//  ROM Bank Programmer  //
///////////////////////////

/obj/structure/rom_bank_editor
	name = "ROM Bank Programmer"
	icon = 'icons/obj/machines/mainframe.dmi'
	icon_state = "rom_editor"
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
	ui_interact(user)
	inserted = null
