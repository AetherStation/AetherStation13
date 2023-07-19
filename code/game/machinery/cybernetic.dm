/obj/machinery/computer/cybernetic_inspector
	name = "cybernetic inspection computer"
	desc = "Monitors patient vitals and displays surgery steps. Can be loaded with surgery disks to perform experimental procedures. Automatically syncs to stasis beds within its line of sight for surgical tech advancement."
	icon_screen = "crew"
	icon_keyboard = "rd_key"
	circuit = /obj/item/circuitboard/computer/cybernetic_inspector

	var/mob/living/carbon/human/patient
	var/obj/structure/chair/cached_chair
	light_color = LIGHT_COLOR_BLUE

/obj/machinery/computer/cybernetic_inspector/Initialize()
	. = ..()
	find_chair()

/obj/machinery/computer/cybernetic_inspector/proc/find_chair()
	for(var/direction in GLOB.alldirs)
		var/chair = locate(/obj/structure/chair) in get_step(src, direction)
		if(chair)
			cached_chair = chair
			break
	if(!cached_chair)
		return
	RegisterSignal(cached_chair, COMSIG_MOVABLE_BUCKLE, .proc/mob_buckled)
	RegisterSignal(cached_chair, COMSIG_MOVABLE_UNBUCKLE, .proc/mob_unbuckled)
	RegisterSignal(cached_chair, COMSIG_PARENT_QDELETING, .proc/chair_qdel)

/obj/machinery/computer/cybernetic_inspector/proc/mob_buckled(datum/source, mob/buckled)
	if(ishuman(buckled))
		patient = buckled

/obj/machinery/computer/cybernetic_inspector/proc/mob_unbuckled(datum/source, mob/buckled)
	patient = null

/obj/machinery/computer/cybernetic_inspector/proc/chair_qdel()
	cached_chair = null

/obj/machinery/computer/cybernetic_inspector/ui_state(mob/user)
	return GLOB.not_incapacitated_state

/obj/machinery/computer/cybernetic_inspector/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "CyberneticInspector", name)
		ui.open()

/obj/machinery/computer/cybernetic_inspector/ui_data(mob/user)
	var/list/data = list()
	if(!patient)
		data["no_patient"] = TRUE
		return data
	data["no_patient"] = FALSE
	data["patient"] = list()
	data["patient"]["name"] = patient.name
	data["patient"]["total_neural_stress"] = patient.current_implant_stress
	data["patient"]["neural_stress"] = patient.get_total_implant_stress()
	var/list/organs = list()
	for(var/obj/item/organ/O in patient.internal_organs)
		var/list/organ = list()
		organ["name"] = O.name
		organ["desc"] = O.desc
		organ["icon"] = icon2base64(icon(O.icon, O.icon_state,SOUTH,frame = 1))
		organ["cost"] = 0
		organ["class"] = "natural"
		organ["syndicate"] = FALSE
		if(istype(O,/obj/item/organ/cyberimp))
			var/obj/item/organ/cyberimp/CI = O
			organ["cost"] = GLOB.implant_class_tiers[CI.implant_class]
			organ["class"] = CI.implant_class
			organ["syndicate"] = CI.syndicate_implant
		organs += list(organ)
	data["organs"] = organs
	var/list/bodyparts = list()
	for(var/obj/item/bodypart/BP in patient.bodyparts)
		var/list/bodypart = list()
		bodypart["name"] = BP.name
		bodypart["icon"] = icon2base64(icon(BP.icon, initial(BP.icon_state), SOUTH))
		bodypart["organic"] = BP.is_organic_limb()
		bodyparts += list(bodypart)
	data["bodyparts"] = bodyparts
	return data

/obj/machinery/computer/cybernetic_inspector/ui_act(action, params)
	. = ..()
	if(.)
		return
	switch(action)
		if("find_chair")
			find_chair()
			. = TRUE
	. = TRUE
