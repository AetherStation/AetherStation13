///////////////
///Base lore///
///////////////
GLOBAL_LIST_INIT(heretic_start_knowledge, initialize_starting_knowledge())

/**
 * Returns a list of all heretic knowledge TYPEPATHS
 * that have route set to PATH_START.
 */
/proc/initialize_starting_knowledge()
	. = list()
	for(var/datum/eldritch_knowledge/knowledge as anything in subtypesof(/datum/eldritch_knowledge))
		if(initial(knowledge.route) == PATH_START)
			. += knowledge

/datum/eldritch_knowledge/spell/basic
	name = "Break of Dawn"
	desc = "Starts your journey in the Mansus. Allows you to select a target using a living heart on a transmutation rune."
	gain_text = "Another day at a meaningless job. You feel a shimmer around you, as a realization of something strange in your backpack unfolds. You look at it, unknowingly opening a new chapter in your life."
	next_knowledge = list(
		/datum/eldritch_knowledge/starting/base_ash,
		/datum/eldritch_knowledge/starting/base_blade,
		/datum/eldritch_knowledge/starting/base_flesh,
		/datum/eldritch_knowledge/starting/base_rust,
		/datum/eldritch_knowledge/starting/base_void,
		)
	cost = 0
	priority = MAX_KNOWLEDGE_PRIORITY - 1 // Sacrifice will be the most important
	spell_to_add = /obj/effect/proc_holder/spell/targeted/touch/mansus_grasp
	required_atoms = list(/obj/item/living_heart)
	route = PATH_START

/datum/eldritch_knowledge/spell/basic/recipe_snowflake_check(mob/living/user, list/atoms, list/selected_atoms, turf/loc)
	. = ..()
	for(var/obj/item/living_heart/heart in atoms)
		if(!heart.target)
			selected_atoms += heart
			return TRUE
		if(heart.target in atoms)
			selected_atoms += heart
			return TRUE
	return FALSE

/datum/eldritch_knowledge/spell/basic/on_finished_recipe(mob/living/user, list/selected_atoms, turf/loc)
	. = TRUE
	var/mob/living/carbon/carbon_user = user
	for(var/obj/item/living_heart/heart in selected_atoms)

		if(heart.target && heart.target.stat == DEAD)
			user.balloon_alert(user, "Your patrons accepts your offer..")
			var/mob/living/carbon/human/current_target = heart.target
			current_target.gib()
			heart.target = null
			var/datum/antagonist/heretic/heretic_datum = carbon_user.mind.has_antag_datum(/datum/antagonist/heretic)

			heretic_datum.total_sacrifices++
			for(var/obj/item/forbidden_book/book as anything in carbon_user.get_all_gear())
				if(!istype(book))
					continue
				book.charge += 2
				break

		if(!heart.target)
			var/datum/objective/temp_objective = new
			temp_objective.owner = user.mind
			var/list/datum/team/teams = list()
			for(var/datum/antagonist/antag as anything in user.mind.antag_datums)
				var/datum/team/team = antag.get_team()
				if(team)
					teams |= team
			var/list/targets = list()
			for(var/i in 0 to 3)
				var/datum/mind/targeted =  temp_objective.find_target()//easy way, i dont feel like copy pasting that entire block of code
				var/is_teammate = FALSE
				for(var/datum/team/team as anything in teams)
					if(targeted in team.members)
						is_teammate = TRUE
						break
				if(!targeted)
					break
				targets["[targeted.current.real_name] the [targeted.assigned_role.title][is_teammate ? " (ally)" : ""]"] = targeted.current
			heart.target = targets[input(user,"Choose your next target","Target") in targets]
			qdel(temp_objective)
			if(heart.target)
				user.balloon_alert(user, "Your new target has been selected, go and sacrifice [heart.target.real_name]!")
			else
				user.balloon_alert(user, "Target could not be found for living heart.")
				return FALSE

/datum/eldritch_knowledge/living_heart
	name = "Living Heart"
	desc = "Allows you to create additional living hearts, using a heart, a pool of blood and a poppy. Living hearts when used on a transmutation rune will grant you a person to hunt and sacrifice on the rune. Every sacrifice gives you an additional charge in the book."
	gain_text = "The Gates of Mansus open up to your mind."
	cost = 0
	priority = MAX_KNOWLEDGE_PRIORITY - 2 // Knowing how to remake your heart is important
	required_atoms = list(
		/obj/item/organ/heart = 1,
		/obj/effect/decal/cleanable/blood = 1,
		/obj/item/food/grown/poppy = 1
		)
	result_atoms = list(/obj/item/living_heart)
	route = PATH_START

/datum/eldritch_knowledge/codex_cicatrix
	name = "Codex Cicatrix"
	desc = "Allows you to create a spare Codex Cicatrix if you have lost one, using a bible, human skin, a pen and a pair of eyes."
	gain_text = "Their hand is at your throat, yet you see Them not."
	cost = 0
	priority = MAX_KNOWLEDGE_PRIORITY - 3 // Not as important as making a heart or sacrificing, but important enough.
	required_atoms = list(
		/obj/item/organ/eyes = 1,
		/obj/item/stack/sheet/animalhide/human = 1,
		/obj/item/storage/book/bible = 1,
		/obj/item/pen = 1
		)
	result_atoms = list(/obj/item/forbidden_book/ritual)
	route = PATH_START
