/datum/eldritch_knowledge/starting/base_void
	name = "Glimmer of Winter"
	desc = "Opens up the path of void to you. Allows you to transmute a knife in a sub-zero temperature into a void blade."
	gain_text = "I feel a shimmer in the air, atmosphere around me gets colder. I feel my body realizing the emptiness of existance. Something's watching me"
	next_knowledge = list(/datum/eldritch_knowledge/void_grasp)
	required_atoms = list(/obj/item/kitchen/knife = 1)
	result_atoms = list(/obj/item/melee/sickly_blade/void)
	cost = 1
	route = PATH_VOID

/datum/eldritch_knowledge/starting/base_void/recipe_snowflake_check(mob/living/user, list/atoms, list/selected_atoms, turf/loc)
	var/turf/open/turfie = loc
	if(turfie.GetTemperature() > T0C)
		return FALSE
	return ..()

/datum/eldritch_knowledge/void_grasp
	name = "Grasp of Void"
	desc = "Temporarily mutes your victim, also lowers their body temperature."
	gain_text = "I found the cold watcher who observes me. The resonance of cold grows within me. This isn't the end of the mystery."
	cost = 1
	route = PATH_VOID
	next_knowledge = list(/datum/eldritch_knowledge/cold_snap)

/datum/eldritch_knowledge/void_grasp/on_gain(mob/user)
	RegisterSignal(user, COMSIG_HERETIC_MANSUS_GRASP_ATTACK, .proc/on_mansus_grasp)
	RegisterSignal(user, COMSIG_HERETIC_BLADE_ATTACK, .proc/on_eldritch_blade)

/datum/eldritch_knowledge/void_grasp/on_lose(mob/user)
	UnregisterSignal(user, list(COMSIG_HERETIC_MANSUS_GRASP_ATTACK, COMSIG_HERETIC_BLADE_ATTACK))

/datum/eldritch_knowledge/void_grasp/proc/on_mansus_grasp(mob/living/source, mob/living/target)
	SIGNAL_HANDLER

	if(!iscarbon(target))
		return

	var/mob/living/carbon/carbon_target = target
	var/turf/open/target_turf = get_turf(carbon_target)
	target_turf.TakeTemperature(-20)
	carbon_target.adjust_bodytemperature(-40)
	carbon_target.silent += 4

/datum/eldritch_knowledge/void_grasp/proc/on_eldritch_blade(mob/living/user, mob/living/target)
	SIGNAL_HANDLER

	var/datum/status_effect/eldritch/mark = target.has_status_effect(/datum/status_effect/eldritch)
	if(!istype(mark))
		return

	mark.on_effect()

/datum/eldritch_knowledge/cold_snap
	name = "Aristocrat's Way"
	desc = "Makes you immune to cold temperatures, and you no longer need to breathe, you can still take damage from lack of pressure."
	gain_text = "I found a thread of cold breath. It lead me to a strange shrine, all made of crystals. Translucent and white, a depiction of a nobleman stood before me."
	cost = 1
	route = PATH_VOID
	next_knowledge = list(
		/datum/eldritch_knowledge/void_cloak,
		/datum/eldritch_knowledge/mark/void_mark,
		/datum/eldritch_knowledge/limited_amount/risen_corpse,
		)

/datum/eldritch_knowledge/cold_snap/on_gain(mob/user)
	ADD_TRAIT(user, TRAIT_RESISTCOLD, MAGIC_TRAIT)
	ADD_TRAIT(user, TRAIT_NOBREATH, MAGIC_TRAIT)

/datum/eldritch_knowledge/cold_snap/on_lose(mob/user)
	REMOVE_TRAIT(user, TRAIT_RESISTCOLD, MAGIC_TRAIT)
	REMOVE_TRAIT(user, TRAIT_NOBREATH, MAGIC_TRAIT)

/datum/eldritch_knowledge/mark/void_mark
	name = "Mark of Void"
	gain_text = "A gust of wind? Maybe a shimmer in the air. Presence is overwhelming, my senses betrayed me, my mind is my enemy."
	desc = "Your mansus grasp now applies mark of void status effect. To proc the mark, use your sickly blade on the marked. Mark of void when procced lowers the victims body temperature significantly."
	next_knowledge = list(/datum/eldritch_knowledge/knowledge_ritual/void)
	route = PATH_VOID
	mark_type = /datum/status_effect/eldritch/void

/datum/eldritch_knowledge/knowledge_ritual/void
	next_knowledge = list(/datum/eldritch_knowledge/spell/void_phase)
	route = PATH_VOID

/datum/eldritch_knowledge/spell/void_phase
	name = "Void Phase"
	gain_text = "Reality bends under the power of memory, for all is fleeting, and what else stays?"
	desc = "You gain a long range pointed blink that allows you to instantly teleport to your location, it causes aoe damage around you and your chosen location."
	cost = 1
	spell_to_add = /obj/effect/proc_holder/spell/pointed/void_blink
	next_knowledge = list(
		/datum/eldritch_knowledge/rune_carver,
		/datum/eldritch_knowledge/spell/blood_siphon,
		/datum/eldritch_knowledge/blade_upgrade/void,
	)
	route = PATH_VOID

/datum/eldritch_knowledge/blade_upgrade/void
	name = "Seeking blade"
	gain_text = "Fleeting memories, fleeting feet. I can mark my way with the frozen blood upon the snow. Covered and forgotten."
	desc = "You can now use your blade on a distant marked target to move to them and attack them."
	next_knowledge = list(/datum/eldritch_knowledge/spell/voidpull)
	route = PATH_VOID

/datum/eldritch_knowledge/blade_upgrade/void/do_ranged_effects(mob/living/user, mob/living/target, obj/item/melee/sickly_blade/blade)
	if(!target.has_status_effect(/datum/status_effect/eldritch))
		return

	var/dir = angle2dir(dir2angle(get_dir(user, target)) + 180)
	user.forceMove(get_step(target, dir))

	INVOKE_ASYNC(src, .proc/follow_up_attack, user, target, blade)

/datum/eldritch_knowledge/blade_upgrade/void/proc/follow_up_attack(mob/living/user, mob/living/target, obj/item/melee/sickly_blade/blade)
	blade.melee_attack_chain(user, target)

/datum/eldritch_knowledge/spell/voidpull
	name = "Void Pull"
	gain_text = "This entity calls itself the aristocrat, I'm close to ending what was started."
	desc = "You gain an ability that let's you pull people around you closer to you."
	cost = 1
	spell_to_add = /obj/effect/proc_holder/spell/targeted/void_pull
	next_knowledge = list(
		/datum/eldritch_knowledge/final/void_final,
		/datum/eldritch_knowledge/spell/cleave,
		/datum/eldritch_knowledge/summon/maid_in_the_mirror,
	)
	route = PATH_VOID

/datum/eldritch_knowledge/final/void_final
	name = "Waltz at the End of Time"
	desc = "Bring 3 corpses onto the transmutation rune. After you finish the ritual you will automatically silence people around you and will summon a snow storm around you."
	gain_text = "The world falls into darkness. I stand in an empty plane, small flakes of ice fall from the sky. Aristocrat stand before me, he motions to me. We will play a waltz to the whispers of dying reality, as the world is destroyed before our eyes."
	route = PATH_VOID
	///soundloop for the void theme
	var/datum/looping_sound/void_loop/sound_loop
	///Reference to the ongoing voidstrom that surrounds the heretic
	var/datum/weather/void_storm/storm

/datum/eldritch_knowledge/final/void_final/on_finished_recipe(mob/living/user, list/selected_atoms, turf/loc)
	. = ..()
	priority_announce("[generate_eldritch_text()] The nobleman of void [user.real_name] has arrived, step along the Waltz that ends worlds! [generate_eldritch_text()]","[generate_eldritch_text()]", ANNOUNCER_SPANOMALIES)
	user.client?.give_award(/datum/award/achievement/misc/void_ascension, user)
	ADD_TRAIT(user, TRAIT_RESISTLOWPRESSURE, MAGIC_TRAIT)

	// Let's get this show on the road!
	sound_loop = new(user, TRUE, TRUE)
	RegisterSignal(user, COMSIG_LIVING_LIFE, .proc/on_life)
	RegisterSignal(user, COMSIG_LIVING_DEATH, .proc/on_death)

/datum/eldritch_knowledge/final/void_final/on_lose(mob/user)
	on_death() // Losing is pretty much dying. I think
	RegisterSignal(user, list(COMSIG_LIVING_LIFE, COMSIG_LIVING_DEATH))

/**
 * Signal proc for [COMSIG_LIVING_LIFE].
 *
 * Any non-heretics nearby the heretic ([source])
 * are constantly silenced and battered by the storm.
 *
 * Also starts storms in any area that doesn't have one.
 */
/datum/eldritch_knowledge/final/void_final/proc/on_life(mob/living/source, delta_time, times_fired)
	SIGNAL_HANDLER

	for(var/mob/living/carbon/close_carbon in view(5, source))
		if(IS_HERETIC_OR_MONSTER(close_carbon))
			continue
		close_carbon.silent += 1
		close_carbon.adjust_bodytemperature(-20)

	var/turf/open/source_turf = get_turf(source)
	if(!isopenturf(source_turf))
		return
	source_turf.TakeTemperature(-20)

	var/area/source_area = get_area(source)

	if(!storm)
		storm = new /datum/weather/void_storm(list(source_turf.z))
		storm.telegraph()

	storm.area_type = source_area.type
	storm.impacted_areas = list(source_area)
	storm.update_areas()

/**
 * Signal proc for [COMSIG_LIVING_DEATH].
 *
 * Stop the storm when the heretic passes away.
 */
/datum/eldritch_knowledge/final/void_final/proc/on_death()
	SIGNAL_HANDLER

	if(sound_loop)
		sound_loop.stop()
	if(storm)
		storm.end()
		QDEL_NULL(storm)
