#define GHOUL_MAX_HEALTH 25
#define MUTE_MAX_HEALTH 50

/datum/eldritch_knowledge/starting/base_flesh
	name = "Principle of Hunger"
	desc = "Opens up the Path of Flesh to you. \
		Allows you to transmute a knife and a pool of blood into a Bloody Blade. \
		You can only create three at a time."
	gain_text = "Hundreds of us starved, but not me... I found strength in my greed."
	next_knowledge = list(/datum/eldritch_knowledge/limited_amount/flesh_grasp)
	required_atoms = list(
		/obj/item/kitchen/knife = 1,
		/obj/effect/decal/cleanable/blood = 1
		)
	result_atoms = list(/obj/item/melee/sickly_blade/flesh)
	route = PATH_FLESH

/datum/eldritch_knowledge/limited_amount/flesh_grasp
	name = "Grasp of Flesh"
	desc = "Your Mansus Grasp gains the ability to create a ghoul out of corpse with a soul. \
		Ghouls have only 25 health and look like husks to the heathens' eyes, but can use Bloody Blades effectively. \
		You can only create one at a time by this method."
	gain_text = "My new found desires drove me to greater and greater heights."
	next_knowledge = list(/datum/eldritch_knowledge/limited_amount/flesh_ghoul)
	limit = 1
	cost = 1
	route = PATH_FLESH

/datum/eldritch_knowledge/limited_amount/flesh_grasp/on_gain(mob/user)
	RegisterSignal(user, COMSIG_HERETIC_MANSUS_GRASP_ATTACK, .proc/on_mansus_grasp)

/datum/eldritch_knowledge/limited_amount/flesh_grasp/on_lose(mob/user)
	UnregisterSignal(user, COMSIG_HERETIC_MANSUS_GRASP_ATTACK)

/datum/eldritch_knowledge/limited_amount/flesh_grasp/proc/on_mansus_grasp(mob/living/source, mob/living/target)
	SIGNAL_HANDLER

	if(target.stat != DEAD)
		return

	if(LAZYLEN(created_items) >= limit)
		target.balloon_alert(source, "at ghoul limit!")
		return COMPONENT_BLOCK_CHARGE_USE

	if(HAS_TRAIT(target, TRAIT_HUSK))
		target.balloon_alert(source, "husked!")
		return COMPONENT_BLOCK_CHARGE_USE

	if(!IS_VALID_GHOUL_MOB(target))
		target.balloon_alert(source, "invalid body!")
		return COMPONENT_BLOCK_CHARGE_USE

	target.grab_ghost()

	// The grab failed, so they're mindless or playerless. We can't continue
	if(!target.mind || !target.client)
		target.balloon_alert(source, "no soul!")
		return COMPONENT_BLOCK_CHARGE_USE

	make_ghoul(source, target)

/// Makes [victim] into a ghoul.
/datum/eldritch_knowledge/limited_amount/flesh_grasp/proc/make_ghoul(mob/living/user, mob/living/carbon/human/victim)
	log_game("[key_name(user)] created a ghoul, controlled by [key_name(victim)].")
	message_admins("[ADMIN_LOOKUPFLW(user)] created a ghoul, [ADMIN_LOOKUPFLW(victim)].")

	victim.apply_status_effect(
		/datum/status_effect/ghoul,
		GHOUL_MAX_HEALTH,
		user.mind,
		CALLBACK(src, .proc/apply_to_ghoul),
		CALLBACK(src, .proc/remove_from_ghoul),
	)

/// Callback for the ghoul status effect - Tracking all of our ghouls
/datum/eldritch_knowledge/limited_amount/flesh_grasp/proc/apply_to_ghoul(mob/living/ghoul)
	LAZYADD(created_items, WEAKREF(ghoul))

/// Callback for the ghoul status effect - Tracking all of our ghouls
/datum/eldritch_knowledge/limited_amount/flesh_grasp/proc/remove_from_ghoul(mob/living/ghoul)
	LAZYREMOVE(created_items, WEAKREF(ghoul))

/datum/eldritch_knowledge/limited_amount/flesh_ghoul
	name = "Imperfect Ritual"
	desc = "Allows you to transmute a corpse and a poppy to create a Voiceless Dead. \
		Voiceless Dead are mute ghouls and only have 50 health, but can use Bloody Blades effectively. \
		You can only create two at a time."
	gain_text = "I found notes of a dark ritual, unfinished... yet still, I pushed forward."
	cost = 1
	required_atoms = list(
		/mob/living/carbon/human = 1,
		/obj/item/food/grown/poppy = 1,
		)
	next_knowledge = list(
		/datum/eldritch_knowledge/mark/flesh_mark,
		/datum/eldritch_knowledge/void_cloak,
		/datum/eldritch_knowledge/ashen_eyes,
	)
	limit = 2
	route = PATH_FLESH

/datum/eldritch_knowledge/limited_amount/flesh_ghoul/recipe_snowflake_check(mob/living/user, list/atoms, list/selected_atoms, turf/loc)
	. = ..()
	if(!.)
		return FALSE

	for(var/mob/living/carbon/human/body in atoms)
		if(body.stat != DEAD)
			continue
		if(!IS_VALID_GHOUL_MOB(body) || HAS_TRAIT(body, TRAIT_HUSK))
			to_chat(user, span_hierophant_warning("[body] is not in a valid state to be made into a ghoul."))
			continue

		// We'll select any valid bodies here. If they're clientless, we'll give them a new one.
		selected_atoms += body
		return TRUE

	user.balloon_alert(user, "ritual failed, no valid body!")
	return FALSE

/datum/eldritch_knowledge/limited_amount/flesh_ghoul/on_finished_recipe(mob/living/user, list/selected_atoms, turf/loc)
	var/mob/living/carbon/human/soon_to_be_ghoul = locate() in selected_atoms
	if(QDELETED(soon_to_be_ghoul)) // No body? No ritual
		stack_trace("[type] reached on_finished_recipe without a human in selected_atoms to make a ghoul out of.")
		user.balloon_alert(user, "ritual failed, no valid body!")
		return FALSE

	soon_to_be_ghoul.grab_ghost()

	if(!soon_to_be_ghoul.mind || !soon_to_be_ghoul.client)
		message_admins("[ADMIN_LOOKUPFLW(user)] is creating a voiceless dead of a body with no player.")
		var/list/mob/dead/observer/candidates = pollCandidatesForMob("Do you want to play as a [soon_to_be_ghoul.real_name], a voiceless dead?", ROLE_HERETIC, ROLE_HERETIC, 5 SECONDS, soon_to_be_ghoul)
		if(!LAZYLEN(candidates))
			user.balloon_alert(user, "ritual failed, no ghosts!")
			return FALSE

		var/mob/dead/observer/chosen_candidate = pick(candidates)
		message_admins("[key_name_admin(chosen_candidate)] has taken control of ([key_name_admin(soon_to_be_ghoul)]) to replace an AFK player.")
		soon_to_be_ghoul.ghostize(FALSE)
		soon_to_be_ghoul.key = chosen_candidate.key

	selected_atoms -= soon_to_be_ghoul
	make_ghoul(user, soon_to_be_ghoul)
	return TRUE

/// Makes [victim] into a ghoul.
/datum/eldritch_knowledge/limited_amount/flesh_ghoul/proc/make_ghoul(mob/living/user, mob/living/carbon/human/victim)
	log_game("[key_name(user)] created a voiceless dead, controlled by [key_name(victim)].")
	message_admins("[ADMIN_LOOKUPFLW(user)] created a voiceless dead, [ADMIN_LOOKUPFLW(victim)].")

	victim.apply_status_effect(
		/datum/status_effect/ghoul,
		MUTE_MAX_HEALTH,
		user.mind,
		CALLBACK(src, .proc/apply_to_ghoul),
		CALLBACK(src, .proc/remove_from_ghoul),
	)

/// Callback for the ghoul status effect - Tracks all of our ghouls and applies effects
/datum/eldritch_knowledge/limited_amount/flesh_ghoul/proc/apply_to_ghoul(mob/living/ghoul)
	LAZYADD(created_items, WEAKREF(ghoul))
	ADD_TRAIT(ghoul, TRAIT_MUTE, MAGIC_TRAIT)

/// Callback for the ghoul status effect - Tracks all of our ghouls and applies effects
/datum/eldritch_knowledge/limited_amount/flesh_ghoul/proc/remove_from_ghoul(mob/living/ghoul)
	LAZYREMOVE(created_items, WEAKREF(ghoul))
	REMOVE_TRAIT(ghoul, TRAIT_MUTE, MAGIC_TRAIT)

/datum/eldritch_knowledge/mark/flesh_mark
	name = "Mark of Flesh"
	desc = "Your Mansus Grasp now applies the Mark of Flesh. The mark is triggered from an attack with your Bloody Blade. \
		When triggered, the victim begins to bleed significantly."
	gain_text = "That's when I saw them, the marked ones. They were out of reach. They screamed, and screamed."
	next_knowledge = list(/datum/eldritch_knowledge/knowledge_ritual/flesh)
	route = PATH_FLESH
	mark_type = /datum/status_effect/eldritch/flesh

/datum/eldritch_knowledge/knowledge_ritual/flesh
	next_knowledge = list(/datum/eldritch_knowledge/summon/raw_prophet)
	route = PATH_FLESH

/datum/eldritch_knowledge/summon/raw_prophet
	name = "Raw Ritual"
	gain_text = "The Uncanny Man, who walks alone in the valley between the worlds... I was able to summon his aid."
	desc = "You can now summon a Raw Prophet by transmutating a pair of eyes, a left arm and a pool of blood. Raw prophets have increased seeing range, as well as X-Ray vision, but they are very fragile."
	cost = 1
	required_atoms = list(
		/obj/item/organ/eyes = 1,
		/obj/effect/decal/cleanable/blood = 1,
		/obj/item/bodypart/l_arm = 1
		)
	mob_to_summon = /mob/living/simple_animal/hostile/eldritch/raw_prophet
	next_knowledge = list(
		/datum/eldritch_knowledge/blade_upgrade/flesh,
		/datum/eldritch_knowledge/curse/paralysis,
		/datum/eldritch_knowledge/spell/blood_siphon,
	)
	route = PATH_FLESH

/datum/eldritch_knowledge/blade_upgrade/flesh
	name = "Bleeding Steel"
	gain_text = "And then, blood rained from the heavens. That's when I finally understood the Marshal's teachings."
	desc = "Your Sickly Blade will now cause additional bleeding."
	next_knowledge = list(/datum/eldritch_knowledge/summon/stalker)
	route = PATH_FLESH

/datum/eldritch_knowledge/blade_upgrade/flesh/do_melee_effects(mob/living/source, mob/living/target, obj/item/melee/sickly_blade/blade)
	if(!iscarbon(target) || source == target)
		return

	var/mob/living/carbon/carbon_target = target
	var/obj/item/bodypart/bodypart = pick(carbon_target.bodyparts)
	bodypart.bleedstacks += 5

/datum/eldritch_knowledge/summon/stalker
	name = "Lonely Ritual"
	gain_text = "I was able to combine my greed and desires to summon an eldritch beast I had never seen before. An ever shapeshifting mass of flesh, it knew well my goals."
	desc = "You can now summon a Stalker by transmutating a pair of eyes, a candle, a pen and a piece of paper. Stalkers can shapeshift into harmless animals to get close to the victim."
	cost = 1
	required_atoms = list(
		/obj/item/pen = 1,
		/obj/item/organ/eyes = 1,
		/obj/item/candle = 1,
		/obj/item/paper = 1
		)
	mob_to_summon = /mob/living/simple_animal/hostile/eldritch/stalker
	next_knowledge = list(
		/datum/eldritch_knowledge/summon/ashy,
		/datum/eldritch_knowledge/spell/cleave,
		/datum/eldritch_knowledge/final/flesh_final
	)
	route = PATH_FLESH

/datum/eldritch_knowledge/final/flesh_final
	name = "Priest's Final Hymn"
	gain_text = "Men of this world. Hear me, for the time of the Lord of Arms has come! The Emperor of Flesh guides my army!"
	desc = "Bring 3 bodies onto a transmutation rune to shed your human form and ascend to untold power."
	route = PATH_FLESH

/datum/eldritch_knowledge/final/flesh_final/on_finished_recipe(mob/living/user, list/selected_atoms, turf/loc)
	. = ..()
	priority_announce("[generate_eldritch_text()] Ever coiling vortex. Reality unfolded. ARMS OUTREACHED, THE LORD OF THE NIGHT, [user.real_name] has ascended! Fear the ever twisting hand! [generate_eldritch_text()]", "[generate_eldritch_text()]", ANNOUNCER_SPANOMALIES)
	user.mind.AddSpell(new /obj/effect/proc_holder/spell/targeted/shed_human_form)
	user.client?.give_award(/datum/award/achievement/misc/flesh_ascension, user)

	var/datum/antagonist/heretic/heretic_datum = IS_HERETIC(user)
	var/datum/eldritch_knowledge/limited_amount/flesh_grasp/grasp_ghoul = heretic_datum.get_knowledge(/datum/eldritch_knowledge/limited_amount/flesh_grasp)
	grasp_ghoul.limit *= 3
	var/datum/eldritch_knowledge/limited_amount/flesh_ghoul/ritual_ghoul = heretic_datum.get_knowledge(/datum/eldritch_knowledge/limited_amount/flesh_ghoul)
	ritual_ghoul.limit *= 3

#undef GHOUL_MAX_HEALTH
#undef MUTE_MAX_HEALTH
