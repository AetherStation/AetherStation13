/datum/eldritch_knowledge/hunt_and_sacrifice
	name = "Heartbeat of the Mansus"
	desc = "Allows you to sacrifice targets to the Mansus by bringing them to a rune in critical (or worse) condition. \
		If you have no targets, stand on a transmutation rune and invoke it to aquire some."
	required_atoms = list(/mob/living/carbon/human = 1)
	cost = 0
	route = PATH_START
	/// Whether we've generated a heretic sacrifice z-level yet, from any heretic.
	var/static/heretic_level_generated = FALSE
	/// If TRUE, we skip the ritual when our target list is empty. Done to avoid locking up the heretic.
	var/skip_this_ritual = FALSE
	/// A weakref to the mind of our heretic.
	var/datum/mind/heretic_mind
	/// Lazylist of minds that we won't pick as targets.
	var/list/datum/mind/target_blacklist
	/// An assoc list of [ref] to [timers] - a list of all the timers of people in the shadow realm currently
	var/return_timers

/datum/eldritch_knowledge/hunt_and_sacrifice/Destroy(force, ...)
	heretic_mind = null
	LAZYCLEARLIST(target_blacklist)
	return ..()

/datum/eldritch_knowledge/hunt_and_sacrifice/on_research(mob/user, regained = FALSE)
	. = ..()
	obtain_targets(user, silent = TRUE)
	heretic_mind = user.mind

/datum/eldritch_knowledge/hunt_and_sacrifice/recipe_snowflake_check(mob/living/user, list/atoms, list/selected_atoms, turf/loc)
	var/obj/item/organ/heart/our_heart = user.getorganslot(ORGAN_SLOT_HEART)
	if(!our_heart || !HAS_TRAIT(our_heart, TRAIT_LIVING_HEART))
		return FALSE

	// We've got no targets set, let's try to set some. Adds the user to the list of atoms,
	// then returns TRUE if skip_this_ritual is FALSE and the user's on top of the rune.
	// If skip_this_ritual is TRUE, returns FALSE to fail the check and move onto the next ritual.
	var/datum/antagonist/heretic/heretic_datum = IS_HERETIC(user)
	if(!LAZYLEN(heretic_datum.sac_targets))
		if(skip_this_ritual)
			return FALSE

		atoms += user
		return (user in range(1, loc))

	// Determine if livings in our atoms are valid
	for(var/mob/living/carbon/human/sacrifice in atoms)
		// If the mob's not in soft crit or worse, or isn't one of the sacrifices, remove it from the list
		if(sacrifice.stat < SOFT_CRIT || !(WEAKREF(sacrifice) in heretic_datum.sac_targets))
			atoms -= sacrifice

	// Finally, return TRUE if we have a mob remaining in our list
	// Otherwise, return FALSE and stop the ritual
	return !!(locate(/mob/living/carbon/human) in atoms)

/datum/eldritch_knowledge/hunt_and_sacrifice/on_finished_recipe(mob/living/user, list/selected_atoms, turf/loc)
	var/datum/antagonist/heretic/heretic_datum = IS_HERETIC(user)
	if(LAZYLEN(heretic_datum.sac_targets))
		sacrifice_process(user, selected_atoms, loc)
	else
		obtain_targets(user)

	return TRUE

/datum/eldritch_knowledge/hunt_and_sacrifice/proc/sacrifice_process(mob/living/carbon/user, list/selected_atoms)

	var/datum/antagonist/heretic/heretic_datum = IS_HERETIC(user)
	var/mob/living/carbon/human/sacrifice = locate() in selected_atoms
	if(!sacrifice)
		CRASH("[type] sacrifice_process didn't have a human in the atoms list. How'd it make it so far?")
	if(!(WEAKREF(sacrifice) in heretic_datum.sac_targets))
		CRASH("[type] sacrifice_process managed to get a non-target human. This is incorrect.")

	if(sacrifice.mind)
		LAZYADD(target_blacklist, sacrifice.mind)
	LAZYREMOVE(heretic_datum.sac_targets, WEAKREF(sacrifice))

	to_chat(user, span_hypnophrase("Your patrons accepts your offer."))

	heretic_datum.total_sacrifices++
	for(var/obj/item/forbidden_book/book as anything in user.get_all_gear())
		if(!istype(book))
			continue
		book.charge += 2
		break

	disembowel_target(sacrifice)

/**
 * Obtain a list of targets for the user to hunt down and sacrifice.
 * Tries to get four targets (minds) with living human currents.
 *
 * Returns FALSE if no targets are found, TRUE if the targets list was populated.
 */
/datum/eldritch_knowledge/hunt_and_sacrifice/proc/obtain_targets(mob/living/user, silent = FALSE)

	// First construct a list of minds that are valid objective targets.
	var/list/datum/mind/valid_targets = list()
	for(var/datum/mind/possible_target as anything in get_crewmember_minds())
		if(possible_target == user.mind)
			continue
		if(possible_target in target_blacklist)
			continue
		if(!ishuman(possible_target.current))
			continue
		if(possible_target.current.stat == DEAD)
			continue

		valid_targets += possible_target

	if(!length(valid_targets))
		if(!silent)
			to_chat(user, span_danger("No sacrifice targets could be found! Attempt the ritual later."))
		skip_this_ritual = TRUE
		addtimer(VARSET_CALLBACK(src, skip_this_ritual, FALSE), 5 MINUTES)
		return FALSE
	var/list/datum/mind/final_targets = list()

	var/target_sanity = 0
	while(length(final_targets) < 4 && length(valid_targets) > 4 && target_sanity < 25)
		final_targets += pick_n_take(valid_targets)
		target_sanity++

	var/datum/antagonist/heretic/heretic_datum = IS_HERETIC(user)

	if(!silent)
		to_chat(user, span_danger("Your targets have been determined. Your Living Heart will allow you to track their position. Go and sacrifice them!"))

	for(var/datum/mind/chosen_mind as anything in final_targets)
		heretic_datum.add_sacrifice_target(chosen_mind.current)
		if(!silent)
			to_chat(user, span_danger("[chosen_mind.current.real_name], the [chosen_mind.assigned_role?.title]."))

	return TRUE

/**
 * Disembowels the [sac_target] and brutilizes their body. Throws some gibs around for good measure.
 */
/datum/eldritch_knowledge/hunt_and_sacrifice/proc/disembowel_target(mob/living/carbon/human/sac_target)
	if(heretic_mind)
		log_combat(heretic_mind.current, sac_target, "disemboweled via sacrifice")
	sac_target.spill_organs()
	sac_target.apply_damage(250, BRUTE)
	if(sac_target.stat != DEAD)
		sac_target.death()
	sac_target.visible_message(
		span_danger("[sac_target]'s organs are pulled out of [sac_target.p_their()] chest by shadowy hands!"),
		span_userdanger("Your organs are violently pulled out of your chest by shadowy hands!")
	)

	new /obj/effect/gibspawner/human/bodypartless(get_turf(sac_target))
