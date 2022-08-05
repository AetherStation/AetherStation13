/obj/machinery/mainframe
	icon = 'icons/obj/machines/mainframe.dmi'
	density = TRUE

///////////////////////////
//       Main Unit       //
///////////////////////////

/obj/machinery/mainframe/main_unit
	name = "main unit"
	desc = "Das komputermaschine ist nicht für der gefingerpoken und mittengraben! Zo relaxen und watschen der blinkenlichten."
	icon_state = "main_unit_off"
	subsystem_type = /datum/controller/subsystem/processing/mainframe
	var/on = FALSE
	var/pause = FALSE
	var/datum/mos6502/processor
	var/list/obj/machinery/mainframe/external/peripheral/peripherals = list()
	var/datum/mos6502_memory_map/signal/peripheral_memory_page

/obj/machinery/mainframe/main_unit/Initialize()
	. = ..()
	wires = new /datum/wires/mainframe(src)
	processor = new()
	// Random Access Memory.
	var/datum/mos6502_memory_map/memory/M = new(16)
	processor.add_memory_map(M, 0)
	// peripherals
	peripheral_memory_page = new(1)
	processor.add_memory_map(peripheral_memory_page, 32)
	RegisterSignal(peripheral_memory_page, COMSIG_MOS6502_MEMORY_WRITE, .proc/peripheral_write)
	RegisterSignal(peripheral_memory_page, COMSIG_MOS6502_MEMORY_READ, .proc/peripheral_read)

/obj/machinery/mainframe/main_unit/attackby(obj/item/O, mob/living/user, params)
	if(is_wire_tool(O))
		wires.interact(user)
		return TRUE
	return ..()

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
	if (!(machine_stat & (NOPOWER|BROKEN)) && !wires.is_cut(WIRE_POWER))
		on = !on
		visible_message(span_notice("\the [src] turns [on ? "on" : "off"]."))
		icon_state = "main_unit[on ? "" : "_off"]"
		processor.reset()

/obj/machinery/mainframe/main_unit/proc/peripheral_write(source, address, value)
	SIGNAL_HANDLER
	var/current_address = 0
	for (var/obj/machinery/mainframe/external/peripheral/P as anything in peripherals)
		if (current_address + P.peripheral_memory_size < address)
			current_address += P.peripheral_memory_size
			continue
		P.mem_write(address - current_address, value)
		break // overlapping peripherals aren't allowed, sowwy.

/obj/machinery/mainframe/main_unit/proc/peripheral_read(source, address)
	SIGNAL_HANDLER
	var/current_address = 0
	for (var/obj/machinery/mainframe/external/peripheral/P as anything in peripherals)
		if (current_address + P.peripheral_memory_size < address)
			current_address += P.peripheral_memory_size
			continue
		return P.mem_read(address - current_address)

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
	if ((machine_stat & (NOPOWER|BROKEN)) || wires.is_cut(WIRE_POWER))
		to_chat(user, span_warning("It is unresponsive."))
		return
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

////////////////////////////
//        External        //
////////////////////////////

/obj/machinery/mainframe/external
	var/obj/machinery/mainframe/main_unit/parent

/obj/machinery/mainframe/external/Destroy()
	. = ..()
	remove_parent()

/obj/machinery/mainframe/external/proc/set_parent(p)
	parent = p

/obj/machinery/mainframe/external/proc/remove_parent()
	parent = null
