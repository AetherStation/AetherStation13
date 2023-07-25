
/**
 * #Eldritch Knwoledge
 *
 * Datum that makes eldritch cultist interesting.
 *
 * Eldritch knowledge aren't instantiated anywhere roundstart, and are initalized and destroyed as the round goes on.
 */
/datum/eldritch_knowledge
	///Name of the knowledge
	var/name = "Basic knowledge"
	///Description of the knowledge
	var/desc = "Basic knowledge of forbidden arts."
	///What shows up
	var/gain_text = ""
	///Cost of knowledge in souls
	var/cost = 0
	/// The priority of the knowledge. Higher priority knowledge appear higher in the ritual list.
	/// Number itself is completely arbitrary. Does not need to be set for non-ritual knowledge.
	var/priority = 0
	///Next knowledge in the research tree
	var/list/next_knowledge = list()
	/// What knowledge is incompatible with this. Knowledge in this list cannot be researched with this current knowledge.
	var/list/banned_knowledge = list()
	/// The abstract parent type of the knowledge, used in determine mutual exclusivity in some cases
	var/datum/eldritch_knowledge/abstract_parent_type = /datum/eldritch_knowledge
	/// If TRUE, populates the banned_knowledge list of every other subtype of this knowledge's abstract_parent_type
	var/mutually_exclusive = FALSE
	///Used with rituals, how many items this needs
	var/list/required_atoms
	///What do we get out of this
	var/list/result_atoms = list()
	///Set to null
	var/route
	///wheter we registered the sharpen signal
	var/sharpen_off = TRUE

/**
 * What happens when this is assigned to an antag datum
 *
 * This proc is called whenever a new eldritch knowledge is added to an antag datum
 */
/datum/eldritch_knowledge/proc/on_gain(mob/user)
	to_chat(user, span_warning("[gain_text]"))

	if(sharpen_off && route == PATH_BLADE)
		RegisterSignal(user, COMSIG_HERETIC_BLADE_MANIPULATION, PROC_REF(allow_to_sharp))
		sharpen_off = FALSE

	if(!mutually_exclusive)
		return

	for(var/knowledge_type in subtypesof(abstract_parent_type))
		if(knowledge_type == type)
			continue
		banned_knowledge += knowledge_type
	return
/**
 * What happens when you loose this
 *
 * This proc is called whenever antagonist looses his antag datum, put cleanup code in here
 */
/datum/eldritch_knowledge/proc/on_lose(mob/user)
	return

/datum/eldritch_knowledge/proc/on_research(mob/user)
	return

//See Register
/datum/eldritch_knowledge/proc/allow_to_sharp(mob/user)
	return COMPONENT_SHARPEN

/datum/eldritch_knowledge/proc/on_dead(mob/user)
	return

/**
 * Determines if a heretic can actually attempt to invoke the knowledge as a ritual.
 * By default, we can only invoke knowledge with rituals associated.
 *
 * Return TRUE to have the ritual show up in the rituals list, FALSE otherwise.
*/
/datum/eldritch_knowledge/proc/can_be_invoked(datum/antagonist/heretic/invoker)
	return !!LAZYLEN(required_atoms)

/**
 * Special check for rituals.
 * Called before any of the required atoms are checked.
 *
 * If you are adding a more complex summoning,
 * or something that requires a special check
 * that parses through all the atoms,
 * you should override this.
 *
 * Arguments
 * * user - the mob doing the ritual
 * * atoms - a list of all atoms being checked in the ritual.
 * * selected_atoms - an empty list(!) instance passed in by the ritual. You can add atoms to it in this proc.
 * * loc - the turf the ritual's occuring on
 *
 * Returns: TRUE, if the ritual will continue, or FALSE, if the ritual is skipped / cancelled
*/
/datum/eldritch_knowledge/proc/recipe_snowflake_check(mob/living/user, list/atoms, list/selected_atoms, turf/loc)
	return TRUE

/**
 * Called whenever the knowledge's associated ritual is completed successfully.
 *
 * Creates atoms from types in result_atoms.
 * Override this is you want something else to happen.
 * This CAN sleep, such as for summoning rituals which poll for ghosts.
 *
 * Arguments
 * * user - the mob who did the  ritual
 * * selected_atoms - an list of atoms chosen as a part of this ritual.
 * * loc - the turf the ritual's occuring on
 *
 * Returns: TRUE, if the ritual should cleanup afterwards, or FALSE, to avoid calling cleanup after.
 */
/datum/eldritch_knowledge/proc/on_finished_recipe(mob/living/user, list/selected_atoms, turf/loc)
	if(!length(result_atoms))
		return FALSE
	for(var/result in result_atoms)
		new result(loc)
	return TRUE

/**
 * Called after on_finished_recipe returns TRUE
 * and a ritual was successfully completed.
 *
 * Goes through and cleans up (deletes)
 * all atoms in the selected_atoms list.
 *
 * Remove atoms from the selected_atoms
 * (either in this proc or in on_finished_recipe)
 * to NOT have certain atoms deleted on cleanup.
 *
 * Arguments
 * * selected_atoms - a list of all atoms we intend on destroying.
 */
/datum/eldritch_knowledge/proc/cleanup_atoms(list/selected_atoms)
	SHOULD_CALL_PARENT(TRUE)

	for(var/atom/sacrificed as anything in selected_atoms)
		if(isliving(sacrificed))
			continue
		if(istype(sacrificed, /obj/item/living_heart))
			continue
		if(isstack(sacrificed))
			var/obj/item/stack/sac_stack = sacrificed
			var/how_much_to_use = 0
			for(var/requirement in required_atoms)
				if(istype(sacrificed, requirement))
					how_much_to_use = min(required_atoms[requirement], sac_stack.amount)
					break
			sac_stack.use(how_much_to_use)
			continue

		selected_atoms -= sacrificed
		qdel(sacrificed)


//////////////
///Subtypes///
//////////////

/datum/eldritch_knowledge/spell
	abstract_parent_type = /datum/eldritch_knowledge/spell
	var/obj/effect/proc_holder/spell/spell_to_add

/datum/eldritch_knowledge/spell/Destroy(force, ...)
	if(istype(spell_to_add))
		QDEL_NULL(spell_to_add)
	return ..()

/datum/eldritch_knowledge/spell/on_gain(mob/user)
	spell_to_add = new spell_to_add()
	user.mind.AddSpell(spell_to_add)
	return ..()

/datum/eldritch_knowledge/spell/on_lose(mob/user)
	user.mind.RemoveSpell(spell_to_add)
	return ..()

/*
 * A knowledge subtype for knowledge that can only
 * have a limited amount of it's resulting atoms
 * created at once.
 */
/datum/eldritch_knowledge/limited_amount
	abstract_parent_type = /datum/eldritch_knowledge/limited_amount
	/// The limit to how many items we can create at once.
	var/limit = 1
	/// A list of weakrefs to all items we've created.
	var/list/datum/weakref/created_items

/datum/eldritch_knowledge/limited_amount/Destroy(force, ...)
	LAZYCLEARLIST(created_items)
	return ..()

/datum/eldritch_knowledge/limited_amount/recipe_snowflake_check(mob/living/user, list/atoms, list/selected_atoms, turf/loc)
	for(var/datum/weakref/ref as anything in created_items)
		var/atom/real_thing = ref.resolve()
		if(QDELETED(real_thing))
			LAZYREMOVE(created_items, ref)

	if(LAZYLEN(created_items) >= limit)
		user.balloon_alert(user, "ritual failed, at limit!")
		return FALSE

	return TRUE

/datum/eldritch_knowledge/limited_amount/on_finished_recipe(mob/living/user, list/selected_atoms, turf/loc)
	for(var/result in result_atoms)
		var/atom/created_thing = new result(loc)
		LAZYADD(created_items, WEAKREF(created_thing))
	return TRUE

/datum/eldritch_knowledge/starting
	abstract_parent_type = /datum/eldritch_knowledge/starting
	mutually_exclusive = TRUE
	priority = MAX_KNOWLEDGE_PRIORITY - 5
	cost = 1

/datum/eldritch_knowledge/starting/New()
	. = ..()
	// Starting path also determines the final knowledge we're limited too
	for(var/datum/eldritch_knowledge/final_knowledge_type as anything in subtypesof(/datum/eldritch_knowledge/final))
		if(initial(final_knowledge_type.route) == route)
			continue
		banned_knowledge += final_knowledge_type

/datum/eldritch_knowledge/mark
	abstract_parent_type = /datum/eldritch_knowledge/mark
	mutually_exclusive = TRUE
	cost = 2
	/// The status effect typepath we apply on people on mansus grasp.
	var/datum/status_effect/eldritch/mark_type

/datum/eldritch_knowledge/mark/on_gain(mob/user)
	RegisterSignal(user, COMSIG_HERETIC_MANSUS_GRASP_ATTACK, PROC_REF(on_mansus_grasp))
	RegisterSignal(user, COMSIG_HERETIC_BLADE_ATTACK, PROC_REF(on_eldritch_blade))

/datum/eldritch_knowledge/mark/on_lose(mob/user)
	UnregisterSignal(user, list(COMSIG_HERETIC_MANSUS_GRASP_ATTACK, COMSIG_HERETIC_BLADE_ATTACK))

/**
 * Signal proc for [COMSIG_HERETIC_MANSUS_GRASP_ATTACK].
 *
 * Whenever we cast mansus grasp on someone, apply our mark.
 */
/datum/eldritch_knowledge/mark/proc/on_mansus_grasp(mob/living/source, mob/living/target)
	SIGNAL_HANDLER

	create_mark(source, target)

/**
 * Signal proc for [COMSIG_HERETIC_BLADE_ATTACK].
 *
 * Whenever we attack someone with our blade, attempt to trigger any marks on them.
 */
/datum/eldritch_knowledge/mark/proc/on_eldritch_blade(mob/living/source, mob/living/target, obj/item/melee/sickly_blade/blade)
	SIGNAL_HANDLER

	trigger_mark(source, target)

/**
 * Creates the mark status effect on our target.
 * This proc handles the instatiate and the application of the station effect,
 * and returns the /datum/status_effect instance that was made.
 *
 * Can be overriden to set or pass in additional vars of the status effect.
 */
/datum/eldritch_knowledge/mark/proc/create_mark(mob/living/source, mob/living/target)
	return target.apply_status_effect(mark_type)

/**
 * Handles triggering the mark on the target.
 *
 * If there is no mark, returns FALSE. Returns TRUE if a mark was triggered.
 */
/datum/eldritch_knowledge/mark/proc/trigger_mark(mob/living/source, mob/living/target)
	var/datum/status_effect/eldritch/mark = target.has_status_effect(/datum/status_effect/eldritch)
	if(!istype(mark))
		return FALSE

	mark.on_effect()
	return TRUE

/*
 * A knowledge subtype for heretic knowledge that
 * upgrades their sickly blade, either on melee or range.
 *
 * A heretic can only learn one /blade_upgrade type knowledge.
 */
/datum/eldritch_knowledge/blade_upgrade
	abstract_parent_type = /datum/eldritch_knowledge/blade_upgrade
	mutually_exclusive = TRUE
	cost = 2

/datum/eldritch_knowledge/blade_upgrade/on_gain(mob/user)
	RegisterSignal(user, COMSIG_HERETIC_BLADE_ATTACK, PROC_REF(on_eldritch_blade))
	RegisterSignal(user, COMSIG_HERETIC_RANGED_BLADE_ATTACK, PROC_REF(on_ranged_eldritch_blade))

/datum/eldritch_knowledge/blade_upgrade/on_lose(mob/user)
	UnregisterSignal(user, list(COMSIG_HERETIC_BLADE_ATTACK, COMSIG_HERETIC_RANGED_BLADE_ATTACK))


/**
 * Signal proc for [COMSIG_HERETIC_BLADE_ATTACK].
 *
 * Apply any melee effects from hitting someone with our blade.
 */
/datum/eldritch_knowledge/blade_upgrade/proc/on_eldritch_blade(mob/living/source, mob/living/target, obj/item/melee/sickly_blade/blade)
	SIGNAL_HANDLER

	do_melee_effects(source, target, blade)

/**
 * Signal proc for [COMSIG_HERETIC_RANGED_BLADE_ATTACK].
 *
 * Apply any ranged effects from hitting someone with our blade.
 */
/datum/eldritch_knowledge/blade_upgrade/proc/on_ranged_eldritch_blade(mob/living/source, mob/living/target, obj/item/melee/sickly_blade/blade)
	SIGNAL_HANDLER

	do_ranged_effects(source, target, blade)

/**
 * Overridable proc that invokes special effects
 * whenever the heretic attacks someone in melee with their heretic blade.
 */
/datum/eldritch_knowledge/blade_upgrade/proc/do_melee_effects(mob/living/source, mob/living/target, obj/item/melee/sickly_blade/blade)
	return

/**
 * Overridable proc that invokes special effects
 * whenever the heretic clicks on someone at range with their heretic blade.
 */
/datum/eldritch_knowledge/blade_upgrade/proc/do_ranged_effects(mob/living/source, mob/living/target, obj/item/melee/sickly_blade/blade)
	return

/datum/eldritch_knowledge/curse
	abstract_parent_type = /datum/eldritch_knowledge/curse
	var/timer = 5 MINUTES
	var/list/fingerprints = list()
	var/list/dna = list()

/datum/eldritch_knowledge/curse/recipe_snowflake_check(mob/living/user, list/atoms, list/selected_atoms, turf/loc)
	fingerprints = list()
	for(var/atom/requirements as anything in atoms)
		fingerprints |= requirements.return_fingerprints()
	list_clear_nulls(fingerprints)
// No fingerprints? No ritual
	if(!length(fingerprints))
		user.balloon_alert(user, "ritual failed, no fingerprints!")
		return FALSE

	return TRUE

/datum/eldritch_knowledge/curse/on_finished_recipe(mob/living/user,list/atoms,loc)

	var/list/compiled_list = list()

	for(var/mob/living/carbon/human/human_to_check as anything in GLOB.human_list)
		if(fingerprints[md5(human_to_check.dna.unique_identity)])
			compiled_list |= human_to_check.real_name
			compiled_list[human_to_check.real_name] = human_to_check

	if(compiled_list.len == 0)
		to_chat(user, span_warning("These items don't possess the required fingerprints or DNA."))
		return FALSE

	var/chosen_mob = input("Select the person you wish to curse","Your target") as null|anything in sort_list(compiled_list, /proc/cmp_mob_realname_dsc)
	if(!chosen_mob)
		return FALSE
	curse(compiled_list[chosen_mob])
	addtimer(CALLBACK(src, PROC_REF(uncurse), compiled_list[chosen_mob]),timer)
	return TRUE

/datum/eldritch_knowledge/curse/proc/curse(mob/living/chosen_mob)
	return

/datum/eldritch_knowledge/curse/proc/uncurse(mob/living/chosen_mob)
	return

/*
 * A knowledge subtype lets the heretic summon a monster with the ritual.
 */
/datum/eldritch_knowledge/summon
	abstract_parent_type = /datum/eldritch_knowledge/summon
	/// Typepath of a mob to summon when we finish the recipe.
	var/mob/living/mob_to_summon

/datum/eldritch_knowledge/summon/on_finished_recipe(mob/living/user, list/selected_atoms, turf/loc)
	var/mob/living/summoned = new mob_to_summon(loc)
	// Fade in the summon while the ghost poll is ongoing.
	// Also don't let them mess with the summon while waiting
	summoned.alpha = 0
	summoned.notransform = TRUE
	summoned.move_resist = MOVE_FORCE_OVERPOWERING
	animate(summoned, 10 SECONDS, alpha = 155)

	message_admins("A [summoned.name] is being summoned by [ADMIN_LOOKUPFLW(user)] in [ADMIN_COORDJMP(summoned)].")
	var/list/mob/dead/observer/candidates = pollCandidatesForMob("Do you want to play as a [summoned.real_name]?", ROLE_HERETIC, FALSE, 10 SECONDS, summoned)
	if(!LAZYLEN(candidates))
		user.balloon_alert(user, "ritual failed, no ghosts!")
		animate(summoned, 0.5 SECONDS, alpha = 0)
		QDEL_IN(summoned, 0.6 SECONDS)
		return FALSE

	var/mob/dead/observer/picked_candidate = pick(candidates)
	// Ok let's make them an interactable mob now, since we got a ghost
	summoned.alpha = 255
	summoned.notransform = FALSE
	summoned.move_resist = initial(summoned.move_resist)

	summoned.ghostize(FALSE)
	summoned.key = picked_candidate.key

	log_game("[key_name(user)] created a [summoned.name], controlled by [key_name(picked_candidate)].")
	message_admins("[ADMIN_LOOKUPFLW(user)] created a [summoned.name], [ADMIN_LOOKUPFLW(summoned)].")

	var/datum/antagonist/heretic_monster/heretic_monster = summoned.mind.add_antag_datum(/datum/antagonist/heretic_monster)
	heretic_monster.set_owner(user.mind)

	var/datum/objective/heretic_summon/summon_objective = locate() in user.mind.get_all_objectives()
	summon_objective?.num_summoned++

	return TRUE

/// The amount of knowledge points the knowledge ritual gives on success.
#define KNOWLEDGE_RITUAL_POINTS 4

/*
 * A subtype of knowledge that generates random ritual components.
 */
/datum/eldritch_knowledge/knowledge_ritual
	name = "Ritual of Knowledge"
	desc = "A randomly generated transmutation ritual that rewards knowledge points and can only be completed once."
	gain_text = "Everything can be a key to unlocking the secrets behind the Gates. I must be wary and wise."
	abstract_parent_type = /datum/eldritch_knowledge/knowledge_ritual
	mutually_exclusive = TRUE
	cost = 1
	priority = MAX_KNOWLEDGE_PRIORITY - 10 // A pretty important midgame ritual.
	/// Whether we've done the ritual. Only doable once.
	var/was_completed = FALSE

/datum/eldritch_knowledge/knowledge_ritual/New()
	. = ..()
	var/static/list/potential_organs = list(
		/obj/item/organ/appendix,
		/obj/item/organ/tail,
		/obj/item/organ/eyes,
		/obj/item/organ/tongue,
		/obj/item/organ/ears,
		/obj/item/organ/heart,
		/obj/item/organ/liver,
		/obj/item/organ/stomach,
		/obj/item/organ/lungs,
	)

	var/static/list/potential_easy_items = list(
		/obj/item/shard,
		/obj/item/candle,
		/obj/item/book,
		/obj/item/pen,
		/obj/item/paper,
		/obj/item/toy/crayon,
		/obj/item/flashlight,
		/obj/item/clipboard,
	)

	var/static/list/potential_uncommoner_items = list(
		/obj/item/restraints/legcuffs/beartrap,
		/obj/item/restraints/handcuffs/cable/zipties,
		/obj/item/circular_saw,
		/obj/item/scalpel,
		/obj/item/binoculars,
		/obj/item/clothing/gloves/color/yellow,
		/obj/item/melee/baton,
		/obj/item/clothing/glasses/sunglasses,
	)

	required_atoms = list()
	// 2 organs. Can be the same.
	required_atoms[pick(potential_organs)] += 1
	required_atoms[pick(potential_organs)] += 1
	// 2-3 random easy items.
	required_atoms[pick(potential_easy_items)] += rand(2, 3)
	// 1 uncommon item.
	required_atoms[pick(potential_uncommoner_items)] += 1

/datum/eldritch_knowledge/knowledge_ritual/on_gain(mob/user)
	var/list/requirements_string = list()

	to_chat(user, span_hierophant("The [name] requires the following:"))
	for(var/obj/item/path as anything in required_atoms)
		var/amount_needed = required_atoms[path]
		to_chat(user, span_hypnophrase("[amount_needed] [initial(path.name)]\s..."))
		requirements_string += "[amount_needed == 1 ? "":"[amount_needed] "][initial(path.name)]\s"

	to_chat(user, span_hierophant("Completing it will reward you [KNOWLEDGE_RITUAL_POINTS] knowledge points. You can check the knowledge in your Researched Knowledge to be reminded."))

	desc = "Allows you to transmute [english_list(requirements_string)] for [KNOWLEDGE_RITUAL_POINTS] bonus knowledge points. This can only be completed once."

/datum/eldritch_knowledge/knowledge_ritual/can_be_invoked(datum/antagonist/heretic/invoker)
	return !was_completed

/datum/eldritch_knowledge/knowledge_ritual/recipe_snowflake_check(mob/living/user, list/atoms, list/selected_atoms, turf/loc)
	return !was_completed

/datum/eldritch_knowledge/knowledge_ritual/on_finished_recipe(mob/living/user, list/selected_atoms, turf/loc)
	var/mob/living/carbon/carbon_user = user
	for(var/obj/item/forbidden_book/book as anything in carbon_user.get_all_gear())
		if(!istype(book))
			continue
		book.charge += KNOWLEDGE_RITUAL_POINTS
		break
	was_completed = TRUE

	to_chat(user, span_boldnotice("[name] completed!"))
	desc += " (Completed!)"
	log_game("[key_name(user)] completed a [name] at [worldtime2text()].")
	return TRUE

#undef KNOWLEDGE_RITUAL_POINTS

//Ascension knowledge
/datum/eldritch_knowledge/final
	abstract_parent_type = /datum/eldritch_knowledge/final
	mutually_exclusive = TRUE // I guess, but it doesn't really matter by this point
	var/finished = FALSE
	priority = MAX_KNOWLEDGE_PRIORITY + 1 // Yes, the final ritual should be ABOVE the max priority.
	required_atoms = list(/mob/living/carbon/human = 3)
	cost = 3

/datum/eldritch_knowledge/final/can_be_invoked(datum/antagonist/heretic/invoker)
	if(invoker.ascended)
		return FALSE
	return TRUE

/datum/eldritch_knowledge/final/recipe_snowflake_check(mob/living/user, list/atoms, list/selected_atoms, turf/loc)
	if(finished)
		return FALSE
	var/counter = 0
	for(var/mob/living/carbon/human/sacrifices in atoms)
		selected_atoms |= sacrifices
		counter++
		if(counter == 3)
			return TRUE
	return FALSE

/datum/eldritch_knowledge/final/on_finished_recipe(mob/living/user, list/selected_atoms, turf/loc)
	var/datum/antagonist/heretic/heretic_datum = IS_HERETIC(user)
	heretic_datum.ascended = TRUE

	if(ishuman(user))
		var/mob/living/carbon/human/human_user = user
		human_user.physiology.brute_mod *= 0.5
		human_user.physiology.burn_mod *= 0.5
	return TRUE

/datum/eldritch_knowledge/final/cleanup_atoms(list/selected_atoms)
	for(var/mob/living/carbon/human/sacrifice in selected_atoms)
		selected_atoms -= sacrifice
		sacrifice.gib()

	return ..()
