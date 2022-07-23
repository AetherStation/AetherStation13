/datum/computer_file/program/card_mod
	filename = "plexagonidwriter"
	filedesc = "Plexagon Access Management"
	category = PROGRAM_CATEGORY_CREW
	program_icon_state = "id"
	extended_desc = "Program for programming employee ID cards to access parts of the station."
	transfer_access = ACCESS_HEADS
	requires_ntnet = 0
	size = 8
	tgui_id = "NtosCard"
	program_icon = "id-card"

	var/list/usable_regions
	/// The name/assignment combo of the ID card used to authenticate.
	var/authenticated_user

/**
 * Authenticates the program based on the specific ID card.
 *
 * If the card has ACCESS_CHANGE_IDs, it authenticates with all options.
 * Otherwise, it authenticates depending on SSid_access.sub_department_managers_tgui
 * compared to the access on the supplied ID card.
 * Arguments:
 * * user - Program's user.
 * * id_card - The ID card to attempt to authenticate under.
 */
/datum/computer_file/program/card_mod/proc/authenticate(mob/user, obj/item/card/id/id_card)
	if (!id_card)
		return FALSE

	var/accesses = id_card.get_access()
	if (ACCESS_CHANGE_IDS in accesses)
		usable_regions =  list(REGION_GENERAL, REGION_SECURITY, REGION_MEDBAY, REGION_RESEARCH, REGION_ENGINEERING, REGION_SUPPLY, REGION_COMMAND)
		update_static_data(user)
		return TRUE

	usable_regions = list()
	for (var/access in SSid_access.access_to_department_map)
		if (text2num(access) in accesses)
			usable_regions += SSid_access.access_to_department_map[access]
	update_static_data(user)
	return usable_regions.len > 0

/datum/computer_file/program/card_mod/ui_act(action, params)
	. = ..()
	if(.)
		return

	var/obj/item/computer_hardware/card_slot/card_slot
	var/obj/item/computer_hardware/card_slot/card_slot2
	var/obj/item/computer_hardware/printer/printer
	if(computer)
		card_slot = computer.all_components[MC_CARD]
		card_slot2 = computer.all_components[MC_CARD2]
		printer = computer.all_components[MC_PRINT]
		if(!card_slot || !card_slot2)
			return

	var/mob/user = usr
	var/obj/item/card/id/user_id_card = card_slot.stored_card
	var/obj/item/card/id/target_id_card = card_slot2.stored_card

	switch(action)
		// Log in.
		if("PRG_authenticate")
			if(!computer || !user_id_card)
				playsound(computer, 'sound/machines/terminal_prompt_deny.ogg', 50, FALSE)
				return TRUE
			if(authenticate(user, user_id_card))
				playsound(computer, 'sound/machines/terminal_on.ogg', 50, FALSE)
				authenticated_user = user_id_card.name
				return TRUE
		// Log out.
		if("PRG_logout")
			authenticated_user = null
			playsound(computer, 'sound/machines/terminal_off.ogg', 50, FALSE)
			return TRUE
		// Print a report.
		if("PRG_print")
			if(!computer || !printer)
				return TRUE
			if(!authenticated_user)
				return TRUE
			var/contents = {"<h4>Access Report</h4>
						<u>Prepared By:</u> [user_id_card?.registered_name ? user_id_card.registered_name : "Unknown"]<br>
						<u>For:</u> [target_id_card.registered_name ? target_id_card.registered_name : "Unregistered"]<br>
						<hr>
						<u>Assignment:</u> [target_id_card.assignment]<br>
						<u>Access:</u><br>
						"}

			if(!printer.print_text(contents,"access report"))
				to_chat(usr, span_notice("Hardware error: Printer was unable to print the file. It may be out of paper."))
				return TRUE
			else
				playsound(computer, 'sound/machines/terminal_on.ogg', 50, FALSE)
				computer.visible_message(span_notice("\The [computer] prints out a paper."))
			return TRUE
		// Eject the ID used to log on to the ID app.
		if("PRG_ejectauthid")
			if(!computer || !card_slot)
				return TRUE
			if(user_id_card)
				return card_slot.try_eject(user)
			else
				var/obj/item/I = user.get_active_held_item()
				if(istype(I, /obj/item/card/id))
					return card_slot.try_insert(I, user)
		// Eject the ID being modified.
		if("PRG_ejectmodid")
			if(!computer || !card_slot2)
				return TRUE
			if(target_id_card)
				GLOB.data_core.manifest_modify(target_id_card.registered_name, target_id_card.assignment)
				return card_slot2.try_eject(user)
			else
				var/obj/item/I = user.get_active_held_item()
				if(istype(I, /obj/item/card/id))
					return card_slot2.try_insert(I, user)
			return TRUE
		// Change ID card assigned name.
		if("PRG_edit")
			if(!computer || !authenticated_user || !target_id_card)
				return TRUE

			var/old_name = target_id_card.registered_name

			// Sanitize the name first. We're not using the full sanitize_name proc as ID cards can have a wider variety of things on them that
			// would not pass as a formal character name, but would still be valid on an ID card created by a player.
			var/new_name = sanitize(params["name"])

			if(!new_name)
				target_id_card.registered_name = null
				playsound(computer, "terminal_type", 50, FALSE)
				target_id_card.update_label()
				// We had a name before and now we have no name, so this will unassign the card and we update the icon.
				if(old_name)
					target_id_card.update_icon()
				return TRUE

			// However, we are going to reject bad names overall including names with invalid characters in them, while allowing numbers.
			new_name = reject_bad_name(new_name, allow_numbers = TRUE)

			if(!new_name)
				to_chat(usr, span_notice("Software error: The ID card rejected the new name as it contains prohibited characters."))
				return TRUE

			target_id_card.registered_name = new_name
			playsound(computer, "terminal_type", 50, FALSE)
			target_id_card.update_label()
			// Card wasn't assigned before and now it is, so update the icon accordingly.
			if(!old_name)
				target_id_card.update_icon()
			return TRUE
		// Change age
		if("PRG_age")
			if(!computer || !authenticated_user || !target_id_card)
				return TRUE

			var/new_age = params["id_age"]
			if(!isnum(new_age))
				stack_trace("[key_name(usr)] ([usr]) attempted to set invalid age \[[new_age]\] to [target_id_card]")
				return TRUE

			target_id_card.registered_age = new_age
			playsound(computer, "terminal_type", 50, FALSE)
			return TRUE
		// Change assignment
		if("PRG_assign")
			if(!computer || !authenticated_user || !target_id_card)
				return TRUE
			var/new_asignment = sanitize(params["assignment"])
			target_id_card.assignment = new_asignment
			playsound(computer, "terminal_type", 50, FALSE)
			target_id_card.update_label()
			return TRUE
		// Add/remove access.
		if("PRG_access")
			if(!computer || !authenticated_user || !target_id_card)
				return TRUE
			playsound(computer, "terminal_type", 50, FALSE)
			var/access_type = params["access_target"]

			if(access_type in target_id_card.access)
				target_id_card.remove_access(list(access_type))
				LOG_ID_ACCESS_CHANGE(user, target_id_card, "removed [SSid_access.get_access_name(access_type)]")
				return TRUE

			if(!target_id_card.add_access(list(access_type)))
				to_chat(usr, span_notice("ID error: ID card rejected your attempted access modification."))
				LOG_ID_ACCESS_CHANGE(user, target_id_card, "failed to add [SSid_access.get_access_name(access_type)]")
				return TRUE
			LOG_ID_ACCESS_CHANGE(user, target_id_card, "added [SSid_access.get_access_name(access_type)]")
			return TRUE
		if ("PRG_grant_region")
			if(!computer || !authenticated_user || !target_id_card)
				return TRUE
			playsound(computer, "terminal_type", 50, FALSE)

			target_id_card.add_access(SSid_access.accesses_by_region[params["region"]])
			LOG_ID_ACCESS_CHANGE(user, target_id_card, "added region [params["region"]]")
			return TRUE
		if ("PRG_deny_region")
			if(!computer || !authenticated_user || !target_id_card)
				return TRUE
			playsound(computer, "terminal_type", 50, FALSE)

			target_id_card.remove_access(SSid_access.accesses_by_region[params["region"]])
			LOG_ID_ACCESS_CHANGE(user, target_id_card, "removed region [params["region"]]")
			return TRUE
		// Apply template to ID card.
		if("PRG_template")
			if(!computer || !authenticated_user || !target_id_card)
				return TRUE

			playsound(computer, "terminal_type", 50, FALSE)
			var/template_path = params["path"]

			if(!template_path)
				return TRUE
			target_id_card.clear_access()
			SSid_access.apply_card_access(target_id_card, text2path(template_path))
			return TRUE

/datum/computer_file/program/card_mod/ui_static_data(mob/user)
	var/list/data = list()
	data["station_name"] = station_name()
	data["templates"] = list()
	for (var/datum/card_access/A in SSid_access.card_access_assignable)
		if (A.region in usable_regions)
			data["templates"][A.assignment] = A.type
	data["regions"] = list()
	for (var/r in usable_regions)
		data["regions"][r] = SSid_access.tgui_access_list[r]

	return data

/datum/computer_file/program/card_mod/ui_data(mob/user)
	var/list/data = get_header_data()

	data["station_name"] = station_name()

	var/obj/item/computer_hardware/card_slot/card_slot
	var/obj/item/computer_hardware/card_slot/card_slot2
	var/obj/item/computer_hardware/printer/printer

	if(computer)
		card_slot = computer.all_components[MC_CARD]
		card_slot2 = computer.all_components[MC_CARD2]
		printer = computer.all_components[MC_PRINT]
		data["have_auth_card"] = !!(card_slot)
		data["have_id_slot"] = !!(card_slot2)
		data["have_printer"] = !!(printer)
	else
		data["have_id_slot"] = FALSE
		data["have_printer"] = FALSE

	if(!card_slot2)
		return data //We're just gonna error out on the js side at this point anyway

	var/obj/item/card/id/auth_card = card_slot.stored_card
	data["authIDName"] = auth_card ? auth_card.name : "-----"

	data["authenticatedUser"] = authenticated_user

	var/obj/item/card/id/id_card = card_slot2.stored_card
	data["has_id"] = !!id_card
	data["id_name"] = id_card ? id_card.name : "-----"
	if(id_card)
		data["id_rank"] = id_card.assignment ? id_card.assignment : "Unassigned"
		data["id_owner"] = id_card.registered_name ? id_card.registered_name : "-----"
		data["access_on_card"] = id_card.access
		data["access_on_chip"] = id_card.additional_access
		data["id_age"] = id_card.registered_age
		data["id_tier"] = id_card.access_tier

	return data
