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

/datum/eldritch_knowledge/codex_cicatrix
	name = "Codex Cicatrix"
	desc = "Allows you to create a spare Codex Cicatrix if you have lost one, using a bible, human skin, a pen and a pair of eyes."
	gain_text = "Their hand is at your throat, yet you see Them not."
	cost = 0
	priority = MAX_KNOWLEDGE_PRIORITY - 3 // Not as important as sacrificing, but important enough.
	required_atoms = list(
		/obj/item/organ/eyes = 1,
		/obj/item/stack/sheet/animalhide/human = 1,
		/obj/item/storage/book/bible = 1,
		/obj/item/pen = 1
		)
	result_atoms = list(/obj/item/forbidden_book/ritual)
	route = PATH_START

/datum/heretic_knowledge/reroll_targets
	name = "The Relentless Heartbeat"
	desc = "Allows you transmute a harebell, a book, and a jumpsuit while standing over a rune \
		to reroll your sacrifice targets."
	gain_text = "The heart is the principle that continues and preserves."
	required_atoms = list(
		/obj/item/food/grown/harebell = 1,
		/obj/item/book = 1,
		/obj/item/clothing/under = 1,
		/mob/living/carbon/human = 1,
	)
	cost = 1
	route = PATH_START

/datum/heretic_knowledge/reroll_targets/recipe_snowflake_check(mob/living/user, list/atoms, list/selected_atoms, turf/loc)
	var/obj/item/organ/heart/our_heart = user.getorganslot(ORGAN_SLOT_HEART)
	if(!our_heart || !HAS_TRAIT(our_heart, TRAIT_LIVING_HEART))
		return FALSE

	var/datum/antagonist/heretic/heretic_datum = IS_HERETIC(user)
	if(!LAZYLEN(heretic_datum.sac_targets))
		return FALSE

	atoms += user
	return (user in range(1, loc))

/datum/heretic_knowledge/reroll_targets/on_finished_recipe(mob/living/user, list/selected_atoms, turf/loc)
	var/datum/antagonist/heretic/heretic_datum = IS_HERETIC(user)
	LAZYCLEARLIST(heretic_datum.sac_targets)

	var/datum/heretic_knowledge/hunt_and_sacrifice/target_finder = heretic_datum.get_knowledge(/datum/heretic_knowledge/hunt_and_sacrifice)
	if(!target_finder)
		CRASH("Heretic datum didn't have a hunt_and_sacrifice knowledge learned, what?")

	if(!target_finder.obtain_targets(user))
		return FALSE

	return TRUE

/**
 * The Living Heart heretic knowledge.
 *
 * Gives the heretic a living heart.
 * Also includes a ritual to turn their heart into a living heart.
 */
/datum/heretic_knowledge/living_heart
	name = "The Living Heart"
	desc = "Grants you a Living Heart, allowing you to track sacrifice targets. \
		Should you lose your heart, you can transmute a poppy and a pool of blood \
		to awaken your heart into a Living Heart. If your heart is cybernetic, \
		you will additionally require a usable organic heart in the transmutation."
	required_atoms = list(
		/obj/effect/decal/cleanable/blood = 1,
		/obj/item/food/grown/poppy = 1,
	)
	cost = 0
	route = PATH_START

/datum/heretic_knowledge/living_heart/on_research(mob/user)
	. = ..()

	var/obj/item/organ/heart/our_heart = user.getorganslot(ORGAN_SLOT_HEART)
	if(our_heart)
		our_heart.AddComponent(/datum/component/living_heart)

/datum/heretic_knowledge/living_heart/on_lose(mob/user)
	var/obj/item/organ/heart/our_heart = user.getorganslot(ORGAN_SLOT_HEART)
	if(our_heart)
		qdel(our_heart.GetComponent(/datum/component/living_heart))

/datum/heretic_knowledge/living_heart/recipe_snowflake_check(mob/living/user, list/atoms, list/selected_atoms, turf/loc)
	var/obj/item/organ/heart/our_heart = user.getorganslot(ORGAN_SLOT_HEART)
	if(!our_heart || HAS_TRAIT(our_heart, TRAIT_LIVING_HEART))
		return FALSE

	if(our_heart.status == ORGAN_ORGANIC)
		return TRUE

	else
		for(var/obj/item/organ/heart/nearby_heart in atoms)
			if(nearby_heart.status == ORGAN_ORGANIC && nearby_heart.useable)
				selected_atoms += nearby_heart
				return TRUE

		return FALSE


/datum/heretic_knowledge/living_heart/on_finished_recipe(mob/living/user, list/selected_atoms, turf/loc)

	var/obj/item/organ/heart/our_heart = user.getorganslot(ORGAN_SLOT_HEART)

	if(our_heart.status != ORGAN_ORGANIC)
		var/obj/item/organ/heart/our_replacement_heart = locate() in selected_atoms
		if(our_replacement_heart)
			user.visible_message("[user]'s [our_replacement_heart.name] bursts suddenly out of [user.p_their()] chest!")
			INVOKE_ASYNC(user, /mob/proc/emote, "scream")
			user.apply_damage(20, BRUTE, BODY_ZONE_CHEST)

			our_replacement_heart.Insert(user, special = TRUE, drop_if_replaced = TRUE)
			our_heart.throw_at(get_edge_target_turf(user, pick(GLOB.alldirs)), 2, 2)
			our_heart = our_replacement_heart

	if(!our_heart)
		CRASH("[type] somehow made it to on_finished_recipe without a heart. What?")

	if(our_heart in selected_atoms)
		selected_atoms -= our_heart
	our_heart.AddComponent(/datum/component/living_heart)
	to_chat(user, span_warning("You feel your [our_heart.name] begin pulse faster and faster as it awakens!"))
	playsound(user, 'sound/magic/demon_consume.ogg', 50, TRUE)
	return TRUE
