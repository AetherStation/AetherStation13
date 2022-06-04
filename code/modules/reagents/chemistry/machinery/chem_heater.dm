///Tutorial states
#define TUT_NO_BUFFER 50
#define TUT_START 1
#define TUT_HAS_REAGENTS 2
#define TUT_IS_ACTIVE 3
#define TUT_IS_REACTING 4
#define TUT_FAIL 4.5
#define TUT_COMPLETE 5
#define TUT_MISSING 10

/obj/machinery/chem_heater
	name = "reaction chamber" //Maybe this name is more accurate?
	density = TRUE
	icon = 'icons/obj/chemical.dmi'
	icon_state = "mixer0b"
	base_icon_state = "mixer"
	use_power = IDLE_POWER_USE
	idle_power_usage = 40
	resistance_flags = FIRE_PROOF | ACID_PROOF
	circuit = /obj/item/circuitboard/machine/chem_heater

	var/obj/item/reagent_containers/beaker = null
	var/target_temperature = 300
	var/heater_coefficient = 0.05
	var/on = FALSE
	var/dispense_volume = 1
	//The list of active clients using this heater, so that we can update the UI on a reaction_step. I assume there are multiple clients possible.
	var/list/ui_client_list
	///If the user has the tutorial enabled
	var/tutorial_active = FALSE
	///What state we're at in the tutorial
	var/tutorial_state = 0

/obj/machinery/chem_heater/Initialize()
	. = ..()
	create_reagents(200, NO_REACT)//Lets save some calculations here
	//TODO: comsig reaction_start and reaction_end to enable/disable the UI autoupdater - this doesn't work presently as there's a hard divide between instant and processed reactions

/obj/machinery/chem_heater/deconstruct(disassembled)
	. = ..()
	if(beaker && disassembled)
		UnregisterSignal(beaker.reagents, COMSIG_REAGENTS_REACTION_STEP)
		beaker.forceMove(drop_location())
		beaker = null

/obj/machinery/chem_heater/Destroy()
	if(beaker)
		UnregisterSignal(beaker.reagents, COMSIG_REAGENTS_REACTION_STEP)
		QDEL_NULL(beaker)
	return ..()


/obj/machinery/chem_heater/handle_atom_del(atom/A)
	. = ..()
	if(A == beaker)
		beaker = null
		update_appearance()

/obj/machinery/chem_heater/update_icon_state()
	icon_state = "[base_icon_state][beaker ? 1 : 0]b"
	return ..()

/obj/machinery/chem_heater/AltClick(mob/living/user)
	. = ..()
	if(!user.canUseTopic(src, BE_CLOSE, FALSE, NO_TK))
		return
	replace_beaker(user)

/obj/machinery/chem_heater/proc/replace_beaker(mob/living/user, obj/item/reagent_containers/new_beaker)
	if(!user)
		return FALSE
	if(beaker)
		try_put_in_hand(beaker, user)
		UnregisterSignal(beaker.reagents, COMSIG_REAGENTS_REACTION_STEP)
		beaker = null
	if(new_beaker)
		beaker = new_beaker
		RegisterSignal(beaker.reagents, COMSIG_REAGENTS_REACTION_STEP, .proc/on_reaction_step)
	update_appearance()
	return TRUE

/obj/machinery/chem_heater/RefreshParts()
	heater_coefficient = 0.1
	for(var/obj/item/stock_parts/micro_laser/M in component_parts)
		heater_coefficient *= M.rating

/obj/machinery/chem_heater/examine(mob/user)
	. = ..()
	if(in_range(user, src) || isobserver(user))
		. += span_notice("The status display reads: Heating reagents at <b>[heater_coefficient*1000]%</b> speed.")

/obj/machinery/chem_heater/process(delta_time)
	..()
	if(machine_stat & NOPOWER)
		return
	if(on)
		if(beaker?.reagents.total_volume)
			if(beaker.reagents.is_reacting)//on_reaction_step() handles this
				return
			//keep constant with the chemical acclimator please
			beaker.reagents.adjust_thermal_energy((target_temperature - beaker.reagents.chem_temp) * heater_coefficient * delta_time * SPECIFIC_HEAT_DEFAULT * beaker.reagents.total_volume)
			beaker.reagents.handle_reactions()

/obj/machinery/chem_heater/attackby(obj/item/I, mob/user, params)
	if(default_deconstruction_screwdriver(user, "mixer0b", "mixer0b", I))
		return

	if(default_deconstruction_crowbar(I))
		return

	if(istype(I, /obj/item/reagent_containers) && !(I.item_flags & ABSTRACT) && I.is_open_container())
		. = TRUE //no afterattack
		var/obj/item/reagent_containers/B = I
		if(!user.transferItemToLoc(B, src))
			return
		replace_beaker(user, B)
		to_chat(user, span_notice("You add [B] to [src]."))
		updateUsrDialog()
		update_appearance()
		return

	if(beaker)
		if(istype(I, /obj/item/reagent_containers/dropper))
			var/obj/item/reagent_containers/dropper/D = I
			D.afterattack(beaker, user, 1)
			return
		if(istype(I, /obj/item/reagent_containers/syringe))
			var/obj/item/reagent_containers/syringe/S = I
			S.afterattack(beaker, user, 1)
			return
	return ..()

/obj/machinery/chem_heater/on_deconstruction()
	replace_beaker()
	return ..()

///Forces a UI update every time a reaction step happens inside of the beaker it contains. This is so the UI is in sync with the reaction since it's important that the output matches the current conditions for pH adjustment and temperature.
/obj/machinery/chem_heater/proc/on_reaction_step(datum/reagents/holder, num_reactions, delta_time)
	SIGNAL_HANDLER
	if(on)
		holder.adjust_thermal_energy((target_temperature - beaker.reagents.chem_temp) * heater_coefficient * delta_time * SPECIFIC_HEAT_DEFAULT * beaker.reagents.total_volume * (rand(8,11) * 0.1))//Give it a little wiggle room since we're actively reacting
	for(var/ui_client in ui_client_list)
		var/datum/tgui/ui = ui_client
		if(!ui)
			stack_trace("Warning: UI in UI client list is missing in [src] (chem_heater)")
			remove_ui_client_list(ui)
			continue
		ui.send_update()

/obj/machinery/chem_heater/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ChemHeater", name)
		ui.open()
		add_ui_client_list(ui)

/obj/machinery/chem_heater/ui_close(mob/user)
	for(var/ui_client in ui_client_list)
		var/datum/tgui/ui = ui_client
		if(ui.user == user)
			remove_ui_client_list(ui)
	return ..()

/*
*This adds an open ui client to the list - so that it can be force updated from reaction mechanisms.
* After adding it to the list, it enables a signal incase the ui is deleted - which will call a method to remove it from the list
* This is mostly to ensure we don't have defunct ui instances stored from any condition.
*/
/obj/machinery/chem_heater/proc/add_ui_client_list(new_ui)
	LAZYADD(ui_client_list, new_ui)
	RegisterSignal(new_ui, COMSIG_PARENT_QDELETING, .proc/on_ui_deletion)

///This removes an open ui instance from the ui list and deregsiters the signal
/obj/machinery/chem_heater/proc/remove_ui_client_list(old_ui)
	UnregisterSignal(old_ui, COMSIG_PARENT_QDELETING)
	LAZYREMOVE(ui_client_list, old_ui)

///This catches a signal and uses it to delete the ui instance from the list
/obj/machinery/chem_heater/proc/on_ui_deletion(datum/tgui/source, force)
	SIGNAL_HANDLER
	remove_ui_client_list(source)

/obj/machinery/chem_heater/ui_assets()
	. = ..() || list()
	. += get_asset_datum(/datum/asset/simple/tutorial_advisors)

/obj/machinery/chem_heater/ui_data(mob/user)
	var/data = list()
	data["targetTemp"] = target_temperature
	data["isActive"] = on
	data["isBeakerLoaded"] = beaker ? 1 : 0

	data["currentTemp"] = beaker ? beaker.reagents.chem_temp : null
	data["beakerCurrentVolume"] = beaker ? round(beaker.reagents.total_volume, 0.01) : null
	data["beakerMaxVolume"] = beaker ? beaker.volume : null
	data["currentpH"] = beaker ? round(beaker.reagents.ph, 0.01)  : null
	var/upgrade_level = heater_coefficient*10
	data["upgradeLevel"] = upgrade_level

	var/list/beaker_contents = list()
	for(var/r in beaker?.reagents.reagent_list)
		var/datum/reagent/reagent = r
		beaker_contents.len++
		beaker_contents[length(beaker_contents)] = list("name" = reagent.name, "volume" = round(reagent.volume, 0.01))
	data["beakerContents"] = beaker_contents

	var/list/active_reactions = list()
	var/flashing = DISABLE_FLASHING //for use with alertAfter - since there is no alertBefore, I set the after to 0 if true, or to the max value if false
	for(var/_reaction in beaker?.reagents.reaction_list)
		var/datum/equilibrium/equilibrium = _reaction
		if(!length(beaker.reagents.reaction_list))//I'm not sure why when it explodes it causes the gui to fail (it's missing danger (?) )
			stack_trace("how is this happening??")
			continue
		if(!equilibrium.reaction.results)//Incase of no result reactions
			continue
		var/_reagent = equilibrium.reaction.results[1]
		var/datum/reagent/reagent = beaker?.reagents.get_reagent(_reagent) //Reactions are named after their primary products
		if(!reagent)
			continue
		var/overheat = FALSE
		var/danger = FALSE
		var/purity_alert = 2 //same as flashing
		if(reagent.purity < equilibrium.reaction.purity_min)
			purity_alert = ENABLE_FLASHING//Because 0 is seen as null
			danger = TRUE
		if(!(flashing == ENABLE_FLASHING))//So that the pH meter flashes for ANY reactions out of optimal
			if(equilibrium.reaction.optimal_ph_min > beaker?.reagents.ph || equilibrium.reaction.optimal_ph_max < beaker?.reagents.ph)
				flashing = ENABLE_FLASHING
		if(equilibrium.reaction.is_cold_recipe)
			if(equilibrium.reaction.overheat_temp > beaker?.reagents.chem_temp && equilibrium.reaction.overheat_temp != NO_OVERHEAT)
				danger = TRUE
				overheat = TRUE
		else
			if(equilibrium.reaction.overheat_temp < beaker?.reagents.chem_temp)
				danger = TRUE
				overheat = TRUE
		if(equilibrium.reaction.reaction_flags & REACTION_COMPETITIVE) //We have a compeitive reaction - concatenate the results for the different reactions
			for(var/entry in active_reactions)
				if(entry["name"] == reagent.name) //If we have multiple reaction methods for the same result - combine them
					entry["reactedVol"] = equilibrium.reacted_vol
					entry["targetVol"] = round(equilibrium.target_vol, 1)//Use the first result reagent to name the reaction detected
					entry["quality"] = (entry["quality"] + equilibrium.reaction_quality) /2
					continue
		active_reactions.len++
		active_reactions[length(active_reactions)] = list("name" = reagent.name, "danger" = danger, "purityAlert" = purity_alert, "quality" = equilibrium.reaction_quality, "overheat" = overheat, "inverse" = reagent.inverse_chem_val, "minPure" = equilibrium.reaction.purity_min, "reactedVol" = equilibrium.reacted_vol, "targetVol" = round(equilibrium.target_vol, 1))//Use the first result reagent to name the reaction detected

	data["tutorialMessage"] = null
	return data

/obj/machinery/chem_heater/ui_act(action, params)
	. = ..()
	if(.)
		return
	switch(action)
		if("power")
			on = !on
			. = TRUE
		if("temperature")
			var/target = params["target"]
			if(text2num(target) != null)
				target = text2num(target)
				. = TRUE
			if(.)
				target_temperature = clamp(target, 0, 1000)
		if("eject")
			//Eject doesn't turn it off, so you can preheat for beaker swapping
			replace_beaker(usr)
			. = TRUE
		if("acidBuffer")
			var/target = params["target"]
			if(text2num(target) != null)
				target = text2num(target)
				. = TRUE
			if(.)
				move_buffer("acid", target)
		if("basicBuffer")
			var/target = params["target"]
			if(text2num(target) != null)
				target = text2num(target) //Because the input is flipped
				. = TRUE
			if(.)
				move_buffer("basic", target)
		if("disp_vol")
			var/target = params["target"]
			if(text2num(target) != null)
				target = text2num(target) //Because the input is flipped
				. = TRUE
			if(.)
				dispense_volume = target
		if("help")
			tutorial_active = !tutorial_active
			if(tutorial_active)
				tutorial_state = 1
				return
			tutorial_state = 0
			//Refresh window size
			ui_close(usr)
			ui_interact(usr, null)


///Moves a type of buffer from the heater to the beaker, or vice versa
/obj/machinery/chem_heater/proc/move_buffer(buffer_type, volume)
	if(!beaker)
		say("No beaker found!")
		return
	if(buffer_type == "acid")
		if(volume < 0)
			var/datum/reagent/acid_reagent
			if(!acid_reagent)
				say("Unable to find acidic buffer in beaker to draw from! Please insert a beaker containing acidic buffer.")
				return
			var/datum/reagent/acid_reagent_heater
			var/cur_vol = 0
			if(acid_reagent_heater)
				cur_vol = acid_reagent_heater.volume
			volume = 100 - cur_vol
			beaker.reagents.trans_id_to(src, acid_reagent.type, volume)//negative because we're going backwards
			return
		//We must be positive here
		return

	if(buffer_type == "basic")
		if(volume < 0)
			var/datum/reagent/basic_reagent
			if(!basic_reagent)
				say("Unable to find basic buffer in beaker to draw from! Please insert a beaker containing basic buffer.")
				return
			var/datum/reagent/basic_reagent_heater
			var/cur_vol = 0
			if(basic_reagent_heater)
				cur_vol = basic_reagent_heater.volume
			volume = 100 - cur_vol
			beaker.reagents.trans_id_to(src, basic_reagent.type, volume)//negative because we're going backwards
			return
		return


/obj/machinery/chem_heater/proc/get_purity_color(datum/equilibrium/equilibrium)
	var/_reagent = equilibrium.reaction.results[1]
	var/datum/reagent/reagent = equilibrium.holder.get_reagent(_reagent)
	switch(reagent.purity)
		if(1 to INFINITY)
			return "blue"
		if(0.8 to 1)
			return "green"
		if(reagent.inverse_chem_val to 0.8)
			return "olive"
		if(equilibrium.reaction.purity_min to reagent.inverse_chem_val)
			return "orange"
		if(-INFINITY to equilibrium.reaction.purity_min)
			return "red"

//Has a lot of buffer and is upgraded
/obj/machinery/chem_heater/debug
	name = "Debug Reaction Chamber"
	desc = "Now with even more buffers!"

/obj/machinery/chem_heater/debug/Initialize()
	. = ..()
	reagents.maximum_volume = 2000
	heater_coefficient = 0.4 //hack way to upgrade

#undef TUT_NO_BUFFER
#undef TUT_START
#undef TUT_HAS_REAGENTS
#undef TUT_IS_ACTIVE
#undef TUT_IS_REACTING
#undef TUT_FAIL
#undef TUT_COMPLETE
#undef TUT_MISSING
