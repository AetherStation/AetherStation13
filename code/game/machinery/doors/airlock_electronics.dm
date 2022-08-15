/obj/item/electronics/airlock
	name = "airlock electronics"
	req_access = list(ACCESS_MAINT_TUNNELS)
	var/usable_regions = list(REGION_GENERAL,REGION_SECURITY, REGION_MEDBAY, REGION_RESEARCH, REGION_ENGINEERING, REGION_SUPPLY, REGION_COMMAND)
	/// A list of all granted accesses
	var/list/accesses = list()
	/// If the airlock should require ALL or only ONE of the listed accesses
	var/one_access = 0
	/// Unrestricted sides, or sides of the airlock that will open regardless of access
	var/unres_sides = 0
	/// A holder of the electronics, in case of them working as an integrated part
	var/holder

/obj/item/electronics/airlock/examine(mob/user)
	. = ..()
	. += span_notice("Has a neat <i>selection menu</i> for modifying airlock access levels.")

/obj/item/electronics/airlock/ui_state(mob/user)
	return GLOB.hands_state

/obj/item/electronics/airlock/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "AirlockElectronics", name)
		ui.open()

/obj/item/electronics/airlock/ui_static_data(mob/user)
	var/list/data = list()
	data["regions"] = list()
	for (var/r in usable_regions)
		data["regions"][r] = SSid_access.tgui_access_list[r]
	return data

/obj/item/electronics/airlock/ui_data()
	var/list/data = list()
	data["accesses"] = accesses
	data["oneAccess"] = one_access
	data["unres_direction"] = unres_sides
	return data

/obj/item/electronics/airlock/ui_act(action, params)
	. = ..()
	if(.)
		return

	switch(action)
		if("clear_all")
			accesses = list()
			one_access = 0
			. = TRUE
		if("grant_region")
			accesses |= SSid_access.accesses_by_region[params["region"]]
			. = TRUE
		if("deny_region")
			accesses -= SSid_access.accesses_by_region[params["region"]]
			. = TRUE
		if("one_access")
			one_access = !one_access
			. = TRUE
		if("set")
			var/access = text2num(params["access"])
			if (!(access in accesses))
				accesses += access
			else
				accesses -= access
			. = TRUE
		if("direc_set")
			var/unres_direction = text2num(params["unres_direction"])
			unres_sides ^= unres_direction //XOR, toggles only the bit that was clicked
			. = TRUE

/obj/item/electronics/airlock/ui_host()
	if(holder)
		return holder
	return src
