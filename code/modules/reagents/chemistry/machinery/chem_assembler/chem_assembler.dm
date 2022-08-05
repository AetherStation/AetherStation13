/obj/machinery/chem_assembler
	name = "Chemical Assembler"
	desc = "Chemist-in-a-Box"
	density = TRUE
	icon = 'icons/obj/chemical.dmi'
	icon_state = "assembler"
	base_icon_state = "assembler"
	use_power = IDLE_POWER_USE
	idle_power_usage = 40
	interaction_flags_machine = INTERACT_MACHINE_OPEN | INTERACT_MACHINE_ALLOW_SILICON
	resistance_flags = FIRE_PROOF | ACID_PROOF
	circuit = /obj/item/circuitboard/machine/chem_assembler

	var/temp_error_margin = 0.15
	var/target_temperature = T20C
	var/heater_coefficient = 0.05
	var/transfer_speed = 10
	var/synth_speed = 5

	var/list/dispensable_reagents = list(
		/datum/reagent/aluminium,
		/datum/reagent/bromine,
		/datum/reagent/carbon,
		/datum/reagent/chlorine,
		/datum/reagent/copper,
		/datum/reagent/consumable/ethanol,
		/datum/reagent/fluorine,
		/datum/reagent/hydrogen,
		/datum/reagent/iodine,
		/datum/reagent/iron,
		/datum/reagent/lithium,
		/datum/reagent/mercury,
		/datum/reagent/nitrogen,
		/datum/reagent/oxygen,
		/datum/reagent/phosphorus,
		/datum/reagent/potassium,
		/datum/reagent/uranium/radium,
		/datum/reagent/silicon,
		/datum/reagent/sodium,
		/datum/reagent/stable_plasma,
		/datum/reagent/consumable/sugar,
		/datum/reagent/sulfur,
		/datum/reagent/toxin/acid,
		/datum/reagent/water,
		/datum/reagent/fuel
	)

	var/program_text = ""
	var/error
	var/manual_count = 3
	var/datum/chem_assembly_parser/parser
	var/datum/chem_assembly_instruction/program
	var/datum/chem_assembly_instruction/current

	var/datum/reagents/current_slot
	var/datum/reagents/chem_holder = new

	// This looks really bad.
	var/list/slots = list(
		"O" = 300, "H" = 300,
		"I1" = 100, "I2" = 100, "I3" = 100,
		"A1" = 100, "A2" = 100, "A3" = 100,
		"B1" = 100, "B2" = 100, "B3" = 100,
		"C1" = 100, "C2" = 100, "C3" = 100
	)

/obj/machinery/chem_assembler/Initialize()
	for (var/S in slots)
		var/datum/reagents/R = new /datum/reagents(slots[S])
		R.my_atom = src
		slots[S] = R
	reagents = slots["O"]
	reagents.flags |= DRAINABLE
	// B2 is in the middle.
	current_slot = slots["B2"]
	parser = new (list("reagents" = dispensable_reagents, "slots" = slots, "hold_size" = 100))
	if (program_text)
		var/ret = parser.parse(program_text)
		if (istext(ret))
			error = ret
		else
			program = ret
	. = ..()

/obj/machinery/chem_assembler/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/plumbing/supply/north, custom_receiver = slots["O"])
	AddComponent(/datum/component/plumbing/demand/east, custom_receiver = slots["I1"])
	AddComponent(/datum/component/plumbing/demand/south, custom_receiver = slots["I2"])
	AddComponent(/datum/component/plumbing/demand/west, custom_receiver = slots["I3"])

/obj/machinery/chem_assembler/Destroy()
	. = ..()
	reagents = null
	for (var/S in slots)
		qdel(slots[S])
		slots[S] = null
	current_slot = null
	qdel(chem_holder)
	chem_holder = null

/obj/machinery/chem_assembler/RefreshParts()
	heater_coefficient = 0.1
	for(var/obj/item/stock_parts/micro_laser/M in component_parts)
		heater_coefficient *= M.rating
	transfer_speed = 10
	for(var/obj/item/stock_parts/manipulator/M in component_parts)
		transfer_speed *= M.rating
	synth_speed = 5
	for(var/obj/item/stock_parts/capacitor/M in component_parts)
		synth_speed *= M.rating

/obj/machinery/chem_assembler/attackby(obj/item/I, mob/user, params)
	if(default_unfasten_wrench(user, I))
		return
	if(default_deconstruction_screwdriver(user, "dispenser", "dispenser", I))
		return
	if(default_deconstruction_crowbar(I))
		return

/obj/machinery/chem_assembler/process(delta_time)
	if (!anchored)
		return

	var/datum/reagents/heater = slots["H"]
	if (heater.total_volume)
		if (!heater.is_reacting)
			heater.adjust_thermal_energy((target_temperature - heater.chem_temp) * heater_coefficient * delta_time * SPECIFIC_HEAT_DEFAULT * heater.total_volume)
			heater.handle_reactions()
	if (!current)
		return

	var/R = current.execute(src, delta_time)
	if (R == CHEM_INST_FAIL)
		playsound(src, 'sound/machines/buzz-sigh.ogg', 50, TRUE)
		stop()
	else if (R == CHEM_INST_SUCCESS)
		if (!current.next)
			stop()
		else
			current = current.next

/obj/machinery/chem_assembler/proc/start()
	if (current)
		return
	current = program
	flick("assembler-start", src)
	icon_state = "assembler-running"

/obj/machinery/chem_assembler/proc/stop()
	if (!current)
		return
	current = null
	flick("assembler-stop", src)
	icon_state = "assembler"

/obj/machinery/chem_assembler/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ChemAssembler", name)
		ui.open()

/obj/machinery/chem_assembler/ui_data(mob/user)
	var/datum/reagents/R
	var/data = list()
	data["error"] = error
	data["running"] = !!current
	data["compiled"] = !!program
	data["program"] = program_text
	data["slots"] = list()
	for (var/S in slots)
		R = slots[S]
		data["slots"][S] = R.total_volume ? R.total_volume / R.maximum_volume : 0
	R = slots["H"]
	data["temp"] = R.chem_temp
	return data

/obj/machinery/chem_assembler/ui_act(action, params)
	. = ..()

	if(. || !anchored)
		return

	switch(action)
		if ("update_program")
			program_text = params["text"]
			playsound(src, "terminal_type", 50, TRUE)
		if ("compile_program")
			. = TRUE
			if (!program_text)
				error = "No program."
				playsound(src, 'sound/machines/synth_no.ogg', 50, TRUE)
				return
			var/ret = parser.parse(replacetext(program_text, "\t", " "))
			error = ""
			if (istext(ret))
				error = ret
				playsound(src, 'sound/machines/synth_no.ogg', 50, TRUE)
			else
				program = ret
				stop()
				playsound(src, 'sound/machines/synth_yes.ogg', 50, TRUE)
		if ("clear_program")
			. = TRUE
			error = program_text = ""
			stop()
			program = null
			playsound(src, 'sound/machines/twobeep.ogg', 50, TRUE)
		if ("run")
			if (current)
				stop()
				return TRUE
			if (!program)
				playsound(src, 'sound/machines/terminal_error.ogg', 50, TRUE)
				return
			start()
			playsound(src, 'sound/machines/ping.ogg', 50, TRUE)
		if ("manual")
			if (!manual_count)
				playsound(src, 'sound/machines/terminal_error.ogg', 50, TRUE)
				return
			manual_count--
			new /obj/item/paper/guides/chem_assembler(get_turf(src))
			playsound(src, 'sound/machines/ping.ogg', 50, TRUE)
