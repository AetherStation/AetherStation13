/obj/item/mainframe_linker
	name = "mainframe linking tool"
	desc = "Used to link external devices to a mainframe."
	icon = 'icons/obj/machines/mainframe.dmi'
	icon_state = "linker"
	var/datum/weakref/linked_mainframe

/obj/item/mainframe_linker/ui_data(mob/user)
	var/list/data = list()
	data["peripherals"] = list()
	var/current_address = 0
	var/obj/machinery/mainframe/main_unit/M = linked_mainframe.resolve()
	for (var/i in 1 to M.peripherals.len)
		var/obj/machinery/mainframe/external/peripheral/P = M.peripherals[i]
		data["peripherals"] += list(list(
			index = i,
			name = P.name,
			address = current_address,
			size = P.peripheral_memory_size
		))
		current_address += P.peripheral_memory_size
	return data

/obj/item/mainframe_linker/ui_act(action, list/params)
	. = ..()
	if (.)
		return
	var/obj/machinery/mainframe/main_unit/M = linked_mainframe.resolve()
	if (!M)
		return

	switch (action)
		if ("shift_up")
			var/index = params["index"]
			if (index >= M.peripherals.len)
				return
			M.peripherals.Swap(index, index + 1)
			return
		if ("shift_down")
			var/index = params["index"]
			if (index <= 1)
				return
			M.peripherals.Swap(index, index - 1)
			return
		if ("disconnect")
			var/index = params["index"]
			var/obj/machinery/mainframe/external/E = M.peripherals[index]
			E.remove_parent()
			return

/obj/item/mainframe_linker/ui_interact(mob/user, datum/tgui/ui)
	if (!linked_mainframe.resolve())
		return
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "MainframeLinker")
		ui.open()

/obj/item/mainframe_linker/pre_attack(atom/A, mob/living/user, params)
	if (istype(A, /obj/machinery/mainframe/main_unit))
		linked_mainframe = WEAKREF(A)
		to_chat(user, span_notice("You sync \the [src] with \the [A]."))
		return TRUE
	else if (istype(A, /obj/machinery/mainframe/external))
		if (!linked_mainframe || !linked_mainframe.resolve())
			to_chat(user, span_warning("You don't have a main unit synced to the linker."))
			return TRUE
		var/obj/machinery/mainframe/external/P = A
		if (P.parent)
			P.remove_parent()
		P.set_parent(linked_mainframe.resolve())
		to_chat(user, span_notice("You link \the [P] to \the [src]."))
		return TRUE
	. = ..()
