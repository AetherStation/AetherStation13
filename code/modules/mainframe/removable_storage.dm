
/obj/item/mainframe_memory_cassette
	name = "mainframe memory cassette"
	desc = "Honestly quite large cassette."
	icon = 'icons/obj/machines/mainframe.dmi'
	icon_state = "cassette"
	// Disk is after RAM in address space.
	var/datum/mos6502_memory_map/memory/data = new(16)

/obj/machinery/mainframe/external/removable_storage
	name = "cassette drive"
	icon_state = "cassette_drive"
	var/obj/item/mainframe_memory_cassette/inserted

/obj/machinery/mainframe/external/removable_storage/remove_parent()
	if (inserted)
		parent?.processor.remove_memory_map(inserted.data)
	..()

/obj/machinery/mainframe/external/removable_storage/attackby(obj/item/weapon, mob/user, params)
	if (istype(weapon, /obj/item/mainframe_memory_cassette))
		if (inserted)
			to_chat(user, span_notice("There already is a disk inside \the [src]."))
			return
		if (!user.transferItemToLoc(weapon, src))
			return
		inserted = weapon
		icon_state = "cassette_drive_inserted"
		parent?.processor.add_memory_map(inserted.data, 16)
		playsound(src, 'sound/items/taperecorder/taperecorder_open.ogg', 50, FALSE)
		user.visible_message(span_notice("[user] inserts \the [weapon] into \the [src]."))
		return
	return ..()

/obj/machinery/mainframe/external/removable_storage/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if (. || !inserted)
		return

	user.put_in_hands(inserted)
	parent?.processor.remove_memory_map(inserted.data)
	icon_state = "cassette_drive"
	playsound(src, 'sound/items/taperecorder/taperecorder_close.ogg', 50, FALSE)
	user.visible_message(span_notice("[user] ejects \the [inserted] from \the [src]."))
	inserted = null
