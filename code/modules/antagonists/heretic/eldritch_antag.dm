/*
 * Simple helper to generate a string of
 * garbled symbols up to [length] characters.
 *
 * Used in creating spooky-text for heretic ascension announcements.
 */
/proc/generate_eldritch_text(length = 25)
	. = ""
	for(var/i in 1 to length)
		. += pick("!", "$", "^", "@", "&", "#", "*", "(", ")", "?")

/datum/antagonist/heretic
	name = "\improper Heretic"
	roundend_category = "Heretics"
	antagpanel_category = "Heretic"
	ui_name = "AntagInfoHeretic"
	antag_moodlet = /datum/mood_event/heretics
	job_rank = ROLE_HERETIC
	antag_hud_type = ANTAG_HUD_HERETIC
	antag_hud_name = "heretic"
	hijack_speed = 0.5
	suicide_cry = "THE MANSUS SMILES UPON ME!!"
	var/give_equipment = TRUE
	var/list/researched_knowledge = list()
	var/total_sacrifices = 0
	var/ascended = FALSE

/datum/antagonist/heretic/ui_static_data(mob/user)
	var/list/data = list()
	data["total_sacrifices"] = total_sacrifices
	data["ascended"] = ascended
	data["objectives"] = get_objectives()
	return data

/datum/antagonist/heretic/greet()
	owner.current.playsound_local(get_turf(owner.current), 'sound/ambience/antag/ecult_op.ogg', 100, FALSE, pressure_affected = FALSE, use_reverb = FALSE)//subject to change
	to_chat(owner, "<span class='warningplain'><font color=red><B>You are the Heretic!</B></font></span><br><B>The old ones gave you these tasks to fulfill:</B>")
	owner.announce_objectives()
	to_chat(owner, span_cult("<span class='warningplain'>The book whispers softly, its forbidden knowledge walks this plane once again!</span>"))
	var/policy = get_policy(ROLE_HERETIC)
	if(policy)
		to_chat(owner, policy)

/datum/antagonist/heretic/farewell()
	to_chat(owner.current, span_userdanger("Your mind begins to flare as the otherwordly knowledge escapes your grasp!"))
	owner.announce_objectives()

/datum/antagonist/heretic/on_gain()
	var/mob/living/current = owner.current
	if(ishuman(current))
		forge_primary_objectives()
		for(var/eldritch_knowledge in GLOB.heretic_start_knowledge)
			gain_knowledge(eldritch_knowledge)
	current.log_message("has been made into a heretic!", LOG_ATTACK, color="#960000")
	GLOB.reality_smash_track.AddMind(owner)
	START_PROCESSING(SSprocessing, src)
	RegisterSignal(owner.current, COMSIG_LIVING_DEATH, .proc/on_death)
	if(give_equipment)
		equip_cultist()
	return ..()

/datum/antagonist/heretic/on_removal()

	for(var/knowledge_index in researched_knowledge)
		var/datum/eldritch_knowledge/knowledge = researched_knowledge[knowledge_index]
		knowledge.on_lose(owner.current)

	owner.current.log_message("is no longer a heretic!", LOG_ATTACK, color="#960000")

	GLOB.reality_smash_track.RemoveMind(owner)
	STOP_PROCESSING(SSprocessing, src)

	on_death()
	UnregisterSignal(owner, COMSIG_HERETIC_BLADE_MANIPULATION)

	return ..()

/*
 * Get a list of all rituals this heretic can invoke on a rune.
 * Iterates over all of our knowledge and, if we can invoke it, adds it to our list.
 *
 * Returns an associated list of [knowledge name] to [knowledge datum] sorted by knowledge priority.
*/
/datum/antagonist/heretic/proc/get_rituals()
	var/list/rituals = list()
	for(var/knowledge_index in researched_knowledge)
		var/datum/eldritch_knowledge/knowledge = researched_knowledge[knowledge_index]
		if(!knowledge.can_be_invoked(src))
			continue
		rituals[knowledge.name] = knowledge

	return sortTim(rituals, /proc/cmp_eldritch_knowledge, associative = TRUE)

/datum/antagonist/heretic/process()

	if(owner.current.stat == DEAD)
		return

	for(var/knowledge_index in researched_knowledge)
		var/datum/eldritch_knowledge/knowledge = researched_knowledge[knowledge_index]
		knowledge.on_research(owner.current)

///What happens to the heretic once he dies, used to remove any custom perks
/datum/antagonist/heretic/proc/on_death()
	SIGNAL_HANDLER

	for(var/knowledge_index in researched_knowledge)
		var/datum/eldritch_knowledge/knowledge = researched_knowledge[knowledge_index]
		knowledge.on_dead(owner.current)

/datum/antagonist/heretic/proc/forge_primary_objectives()
	var/list/assasination = list()
	var/list/protection = list()

	var/choose_list_begin = list("assassinate","protect")
	var/choose_list_end = list("assassinate","hijack","protect","glory")

	var/pck1 = pick(choose_list_begin)
	var/pck2 = pick(choose_list_end)

	forge_objective(pck1,assasination,protection)
	forge_objective(pck2,assasination,protection)

	var/datum/objective/sacrifice_ecult/sac_objective = new
	sac_objective.owner = owner
	sac_objective.update_explanation_text()
	objectives += sac_objective

/datum/antagonist/heretic/proc/forge_objective(string,assasination,protection)
	switch(string)
		if("assassinate")
			var/datum/objective/assassinate/kill = new
			kill.owner = owner
			var/list/owners = kill.get_owners()
			kill.find_target(owners,protection)
			assasination += kill.target
			objectives += kill
		if("hijack")
			var/datum/objective/hijack/hijack = new
			hijack.owner = owner
			objectives += hijack
		if("glory")
			var/datum/objective/martyr/martyrdom = new
			martyrdom.owner = owner
			objectives += martyrdom
		if("protect")
			var/datum/objective/protect/protect = new
			protect.owner = owner
			var/list/owners = protect.get_owners()
			protect.find_target(owners,assasination)
			protection += protect.target
			objectives += protect

/datum/antagonist/heretic/apply_innate_effects(mob/living/mob_override)
	. = ..()
	var/mob/living/current = owner.current
	if(mob_override)
		current = mob_override
	add_antag_hud(antag_hud_type, antag_hud_name, current)
	handle_clown_mutation(current, mob_override ? null : "Ancient knowledge described in the book allows you to overcome your clownish nature, allowing you to use complex items effectively.")
	current.faction |= FACTION_HERETIC

/datum/antagonist/heretic/remove_innate_effects(mob/living/mob_override)
	. = ..()
	var/mob/living/current = owner.current
	if(mob_override)
		current = mob_override
	remove_antag_hud(antag_hud_type, current)
	handle_clown_mutation(current, removing = FALSE)
	current.faction -= FACTION_HERETIC

/datum/antagonist/heretic/roundend_report()
	var/list/parts = list()

	var/cultiewin = TRUE

	parts += printplayer(owner)
	parts += "<b>Sacrifices Made:</b> [total_sacrifices]"

	if(length(objectives))
		var/count = 1
		for(var/o in objectives)
			var/datum/objective/objective = o
			if(objective.check_completion())
				parts += "<b>Objective #[count]</b>: [objective.explanation_text] [span_greentext("Success!</b>")]"
			else
				parts += "<b>Objective #[count]</b>: [objective.explanation_text] [span_redtext("Fail.")]"
				cultiewin = FALSE
			count++
	if(ascended)
		parts += "<span class='greentext big'>THE HERETIC ASCENDED!</span>"
	else
		if(cultiewin)
			parts += span_greentext("The heretic was successful!")
		else
			parts += span_redtext("The heretic has failed.")

	parts += "<b>Knowledge Researched:</b> "

	var/list/knowledge_message = list()
	var/list/researched_knowledge = get_all_knowledge()
	for(var/knowledge_index in researched_knowledge)
		var/datum/eldritch_knowledge/knowledge = researched_knowledge[knowledge_index]
		knowledge_message += "[knowledge.name]"
	parts += knowledge_message.Join(", ")

	return parts.Join("<br>")
////////////////
// Knowledge //
////////////////

/datum/antagonist/heretic/proc/gain_knowledge(datum/eldritch_knowledge/knowledge)
	if(get_knowledge(knowledge))
		return FALSE
	var/datum/eldritch_knowledge/initialized_knowledge = new knowledge
	researched_knowledge[initialized_knowledge.type] = initialized_knowledge
	initialized_knowledge.on_gain(owner.current)
	return TRUE

/datum/antagonist/heretic/proc/get_researchable_knowledge()
	var/list/researchable_knowledge = list()
	var/list/banned_knowledge = list()
	for(var/knowledge_index in researched_knowledge)
		var/datum/eldritch_knowledge/knowledge = researched_knowledge[knowledge_index]
		researchable_knowledge |= knowledge.next_knowledge
		banned_knowledge |= knowledge.banned_knowledge
		banned_knowledge |= knowledge.type
	researchable_knowledge -= banned_knowledge
	return researchable_knowledge

/datum/antagonist/heretic/proc/get_knowledge(wanted)
	return researched_knowledge[wanted]

/datum/antagonist/heretic/proc/get_all_knowledge()
	return researched_knowledge

////////////////
//   Summon   //
////////////////

/datum/objective/heretic_summon
	name = "summon monsters"
	target_amount = 2
	explanation_text = "Summon 2 monsters from the Mansus into this realm."
	/// The total number of summons the objective owner has done
	var/num_summoned = 0

/datum/objective/heretic_summon/check_completion()
	return completed || (num_summoned >= target_amount)

////////////////
// Objectives //
////////////////

/datum/objective/sacrifice_ecult
	name = "sacrifice"

/datum/objective/sacrifice_ecult/update_explanation_text()
	. = ..()
	target_amount = rand(2,6)
	explanation_text = "Sacrifice at least [target_amount] people."

/datum/objective/sacrifice_ecult/check_completion()
	if(!owner)
		return FALSE
	var/datum/antagonist/heretic/cultie = owner.has_antag_datum(/datum/antagonist/heretic)
	if(!cultie)
		return FALSE
	return cultie.total_sacrifices >= target_amount


/*
 * Admin Buttons for heretic
 */

/datum/antagonist/heretic/admin_add(datum/mind/new_owner,mob/admin)
	give_equipment = FALSE
	new_owner.add_antag_datum(src)
	message_admins("[key_name_admin(admin)] has heresized [key_name_admin(new_owner)].")
	log_admin("[key_name(admin)] has heresized [key_name(new_owner)].")

/datum/antagonist/heretic/get_admin_commands()
	. = ..()
	.["Equip Cultist"] = CALLBACK(src, .proc/equip_cultist)
	.["Add Heart Target (Marked Mob)"] = CALLBACK(src, .proc/equip_target_as_sacrifice)
	.["Give Knowledge Points"] = CALLBACK(src, .proc/add_points)


/*
 * Admin procs for heretic
 */

/datum/antagonist/heretic/proc/equip_cultist()
	var/mob/living/carbon/heretic = owner.current
	if(!istype(heretic))
		return
	. += ecult_give_item(/obj/item/forbidden_book, heretic)
	. += ecult_give_item(/obj/item/living_heart, heretic)

/datum/antagonist/heretic/proc/equip_target_as_sacrifice(mob/admin)
	var/mob/living/carbon/heretic = owner.current
	if(!istype(heretic))
		return
	if(!admin.client?.holder)
		to_chat(admin, span_warning("You shouldn't be using this!"))
		return
	var/mob/living/carbon/human/new_target = admin.client?.holder.marked_datum
	if(!istype(new_target))
		to_chat(admin, span_warning("You need to mark a human to do this!"))
		return

	if(tgui_alert(admin, "Let them know their targets have been updated?", "Whispers of the Mansus", list("Yes", "No")) == "Yes")
		to_chat(owner.current, span_danger("The Mansus has modified your targets. Go find them!"))
		to_chat(owner.current, span_danger("[new_target.real_name], the [new_target.mind?.assigned_role || "human"]."))
	. += ecult_give_item(/obj/item/living_heart, heretic, new_target)

/datum/antagonist/heretic/proc/add_points(mob/admin)
	var/mob/living/carbon/heretic = owner.current
	if(!istype(heretic))
		return
	if(!admin.client?.holder)
		to_chat(admin, span_warning("You shouldn't be using this!"))
		return
	var/add_num = input(admin, "Add knowledge points", "Points", 0) as num|null
	if(!add_num || QDELETED(src))
		return

	. += ecult_give_item(/obj/item/forbidden_book/ritual, heretic, FALSE, add_num)

/datum/antagonist/heretic/proc/ecult_give_item(obj/item/item_path, mob/living/carbon/human/heretic, possible_target, add_points)
	var/list/slots = list(
		"backpack" = ITEM_SLOT_BACKPACK,
		"left pocket" = ITEM_SLOT_LPOCKET,
		"right pocket" = ITEM_SLOT_RPOCKET
	)
	var/T = new item_path(heretic)
	var/item_name = initial(item_path.name)
	var/where
	if(possible_target)
		var/obj/item/living_heart/heart = new()
		heart.target = possible_target
		where = heretic.equip_in_one_of_slots(heart, slots)
	else if(add_points)
		var/obj/item/forbidden_book/ritual/book = new()
		book.charge += add_points
		where = heretic.equip_in_one_of_slots(book, slots)
	else
		where = heretic.equip_in_one_of_slots(T, slots)

	if(!where)
		to_chat(heretic, span_userdanger("Unfortunately, you weren't able to get a [item_name]. This is very bad and you should adminhelp immediately (press F1)."))
		return FALSE
	else
		to_chat(heretic, span_danger("You have a [item_name] in your [where]."))
		if(where == "backpack")
			SEND_SIGNAL(heretic.back, COMSIG_TRY_STORAGE_SHOW, heretic)
		return TRUE
