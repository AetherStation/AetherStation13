/datum/eldritch_knowledge/starting/base_rust
	name = "Blacksmith's Tale"
	desc = "Opens up the Path of Rust to you. Allows you to transmute a kitchen knife, or its derivatives, with any trash item into a Rusty Blade."
	gain_text = "'Let me tell you a story', said the Blacksmith, as he gazed deep into his rusty blade."
	next_knowledge = list(/datum/eldritch_knowledge/rust_fist)
	required_atoms = list(
		/obj/item/kitchen/knife = 1,
		/obj/item/trash = 1
		)
	result_atoms = list(/obj/item/melee/sickly_blade/rust)
	route = PATH_RUST

/datum/eldritch_knowledge/rust_fist
	name = "Grasp of Rust"
	desc = "Empowers your Mansus Grasp to deal 500 damage to non-living matter and rust any surface it touches. Already rusted surfaces are destroyed. You only rust surfaces and machinery while in combat mode."
	gain_text = "On the ceiling of the Mansus, rust grows as moss does on a stone."
	cost = 1
	next_knowledge = list(/datum/eldritch_knowledge/rust_regen)
	var/rust_force = 500
	var/static/list/blacklisted_turfs = typecacheof(list(
		/turf/closed,
		/turf/open/space,
		/turf/open/lava,
		/turf/open/chasm,
	))
	route = PATH_RUST

/datum/eldritch_knowledge/rust_fist/on_gain(mob/user)
	RegisterSignal(user, COMSIG_HERETIC_MANSUS_GRASP_ATTACK, PROC_REF(on_mansus_grasp))
	RegisterSignal(user, COMSIG_HERETIC_MANSUS_GRASP_ATTACK_SECONDARY, PROC_REF(on_secondary_mansus_grasp))
	RegisterSignal(user, COMSIG_HERETIC_BLADE_ATTACK, PROC_REF(on_eldritch_blade))

/datum/eldritch_knowledge/rust_fist/on_lose(mob/user)
	UnregisterSignal(user, list(COMSIG_HERETIC_MANSUS_GRASP_ATTACK, COMSIG_HERETIC_MANSUS_GRASP_ATTACK_SECONDARY, COMSIG_HERETIC_BLADE_ATTACK))

/datum/eldritch_knowledge/rust_fist/proc/on_mansus_grasp(mob/living/source, mob/living/target)
	SIGNAL_HANDLER

	if(!issilicon(target) && !(target.mob_biotypes & MOB_ROBOTIC))
		return

	target.rust_heretic_act()

/datum/eldritch_knowledge/rust_fist/proc/on_secondary_mansus_grasp(mob/living/source, atom/target)
	SIGNAL_HANDLER

	target.rust_heretic_act()
	return COMPONENT_USE_CHARGE

/datum/eldritch_knowledge/rust_fist/proc/on_eldritch_blade(mob/living/user, mob/living/target)
	SIGNAL_HANDLER

	var/datum/status_effect/eldritch/mark = target.has_status_effect(/datum/status_effect/eldritch)
	if(!istype(mark))
		return

	mark.on_effect()

/datum/eldritch_knowledge/rust_regen
	name = "Leeching Walk"
	desc = "Passively heals you and provides stun resistance when you are on rusted tiles."
	gain_text = "The strength was unparalleled, unnatural. The Blacksmith was smiling."
	cost = 1
	next_knowledge = list(
		/datum/eldritch_knowledge/mark/rust_mark,
		/datum/eldritch_knowledge/armor,
		/datum/eldritch_knowledge/essence,
	)
	route = PATH_RUST

/datum/eldritch_knowledge/rust_regen/on_gain(mob/user)
	RegisterSignal(user, COMSIG_MOVABLE_MOVED, PROC_REF(on_move))
	RegisterSignal(user, COMSIG_LIVING_LIFE, PROC_REF(on_life))

/datum/eldritch_knowledge/rust_regen/on_lose(mob/user)
	UnregisterSignal(user, list(COMSIG_MOVABLE_MOVED, COMSIG_LIVING_LIFE))

/*
 * Signal proc for [COMSIG_MOVABLE_MOVED].
 *
 * Checks if we should have stun resistance on the new turf.
 */
/datum/eldritch_knowledge/rust_regen/proc/on_move(mob/source, atom/old_loc, dir, forced, list/old_locs)
	SIGNAL_HANDLER

	var/atom/mover_turf = get_turf(source)
	if(HAS_TRAIT(mover_turf, TRAIT_RUSTY))
		ADD_TRAIT(source, TRAIT_STUNRESISTANCE, type)
		return

	REMOVE_TRAIT(source, TRAIT_STUNRESISTANCE, type)

/**
 * Signal proc for [COMSIG_LIVING_LIFE].
 *
 * Gradually heals the heretic ([source]) on rust,
 * including stuns and stamina damage.
 */
/datum/eldritch_knowledge/rust_regen/proc/on_life(mob/living/source, delta_time, times_fired)
	SIGNAL_HANDLER

	var/turf/our_turf = get_turf(source)
	if(!HAS_TRAIT(our_turf, TRAIT_RUSTY))
		return

	source.adjustBruteLoss(-2, FALSE)
	source.adjustFireLoss(-2, FALSE)
	source.adjustToxLoss(-2, FALSE, forced = TRUE)
	source.adjustOxyLoss(-0.5, FALSE)
	source.adjustStaminaLoss(-2)
	source.AdjustAllImmobility(-5)

/datum/eldritch_knowledge/mark/rust_mark
	name = "Mark of Rust"
	desc = "Your Mansus Grasp now applies the Mark of Rust on hit. Attack the afflicted with your Sickly Blade to detonate the mark. Upon detonation, the Mark of Rust has a chance to deal between 0 to 200 damage to 75% of your enemy's held items."
	gain_text = "Rusted Hills help those in dire need at a cost."
	next_knowledge = list(/datum/eldritch_knowledge/knowledge_ritual/rust)
	route = PATH_RUST
	mark_type = /datum/status_effect/eldritch/rust

/datum/eldritch_knowledge/knowledge_ritual/rust
	next_knowledge = list(/datum/eldritch_knowledge/spell/area_conversion)
	route = PATH_RUST

/datum/eldritch_knowledge/spell/area_conversion
	name = "Agressive Spread"
	desc = "Spreads rust to nearby surfaces. Already rusted surfaces are destroyed."
	gain_text = "All wise men know well not to touch the Bound King."
	cost = 1
	spell_to_add = /obj/effect/proc_holder/spell/aoe_turf/rust_conversion
	next_knowledge = list(
		/datum/eldritch_knowledge/blade_upgrade/rust,
		/datum/eldritch_knowledge/curse/corrosion,
		/datum/eldritch_knowledge/crucible
	)
	route = PATH_RUST

/datum/eldritch_knowledge/blade_upgrade/rust
	name = "Toxic Blade"
	gain_text = "The Blade will guide you through the flesh, should you let it."
	desc = "Your blade of choice will now poison your enemies on hit."
	next_knowledge = list(/datum/eldritch_knowledge/spell/entropic_plume)
	route = PATH_RUST

/datum/eldritch_knowledge/blade_upgrade/rust/do_melee_effects(mob/living/source, mob/living/target, obj/item/melee/sickly_blade/blade)
	// No user == target check here, cause it's technically good for the heretic?
	target.reagents?.add_reagent(/datum/reagent/eldritch, 5)

/datum/eldritch_knowledge/spell/entropic_plume
	name = "Entropic Plume"
	desc = "You can now send a disorienting plume of pure entropy that blinds, poisons and makes enemies strike each other. It also rusts any tiles it affects."
	gain_text = "Messengers of Hope, fear the Rustbringer!"
	cost = 1
	spell_to_add = /obj/effect/proc_holder/spell/cone/staggered/entropic_plume
	next_knowledge = list(
		/datum/eldritch_knowledge/final/rust_final,
		/datum/eldritch_knowledge/summon/rusty,
		/datum/eldritch_knowledge/rifle,
		)
	route = PATH_RUST

/datum/eldritch_knowledge/final/rust_final
	name = "Rustbringer's Oath"
	desc = "The ascension ritual of the Path of Rust. \
		Bring 3 corpses to a transumation rune on the bridge of the station to complete the ritual. \
		When completed, the ritual site will endlessly spread rust onto any surface, stopping for nothing. \
		Additionally, you will become extremely resilient on rust, healing at triple the rate \
		and becoming immune to many effects and dangers."
	gain_text = "Champion of rust. Corruptor of steel. Fear the dark, for the RUSTBRINGER has come! \
		The Blacksmith forges ahead! Rusted Hills, CALL MY NAME! WITNESS MY ASCENSION!"
	route = PATH_RUST
	/// If TRUE, then immunities are currently active.
	var/immunities_active = FALSE
	/// A static list of traits we give to the heretic when on rust.
	var/static/list/conditional_immunities = list(
		TRAIT_STUNIMMUNE,
		TRAIT_SLEEPIMMUNE,
		TRAIT_PUSHIMMUNE,
		TRAIT_SHOCKIMMUNE,
		TRAIT_NOSLIPALL,
		TRAIT_RADIMMUNE,
		TRAIT_RESISTHIGHPRESSURE,
		TRAIT_RESISTLOWPRESSURE,
		TRAIT_RESISTCOLD,
		TRAIT_RESISTHEAT,
		TRAIT_PIERCEIMMUNE,
		TRAIT_BOMBIMMUNE,
		TRAIT_NOBREATH,
		)

/datum/eldritch_knowledge/final/rust_final/on_finished_recipe(mob/living/user, list/selected_atoms, turf/loc)
	. = ..()
	priority_announce("[generate_eldritch_text()] Fear the decay, for the Rustbringer, [user.real_name] has ascended! None shall escape the corrosion! [generate_eldritch_text()]","[generate_eldritch_text()]", ANNOUNCER_SPANOMALIES)
	new /datum/rust_spread(loc)
	RegisterSignal(user, COMSIG_MOVABLE_MOVED, PROC_REF(on_move))
	RegisterSignal(user, COMSIG_LIVING_LIFE, PROC_REF(on_life))
	user.client?.give_award(/datum/award/achievement/misc/rust_ascension, user)

/**
 * Signal proc for [COMSIG_MOVABLE_MOVED].
 *
 * Gives our heretic ([source]) buffs if they stand on rust.
 */
/datum/eldritch_knowledge/final/rust_final/proc/on_move(mob/source, atom/old_loc, dir, forced, list/old_locs)
	SIGNAL_HANDLER

	// If we're on a rusty turf, and haven't given out our traits, buff our guy
	var/turf/our_turf = get_turf(source)
	if(HAS_TRAIT(our_turf, TRAIT_RUSTY))
		if(!immunities_active)
			for(var/trait in conditional_immunities)
				ADD_TRAIT(source, trait, type)
			immunities_active = TRUE

	// If we're not on a rust turf, and we have given out our traits, nerf our guy
	else
		if(immunities_active)
			for(var/trait in conditional_immunities)
				REMOVE_TRAIT(source, trait, type)
			immunities_active = FALSE

/**
 * Signal proc for [COMSIG_LIVING_LIFE].
 *
 * Gradually heals the heretic ([source]) on rust.
 */
/datum/eldritch_knowledge/final/rust_final/proc/on_life(mob/living/source, delta_time, times_fired)
	SIGNAL_HANDLER

	var/turf/our_turf = get_turf(source)
	if(!HAS_TRAIT(our_turf, TRAIT_RUSTY))
		return

	source.adjustBruteLoss(-4, FALSE)
	source.adjustFireLoss(-4, FALSE)
	source.adjustToxLoss(-4, FALSE, forced = TRUE)
	source.adjustOxyLoss(-4, FALSE)
	source.adjustStaminaLoss(-20)

/**
 * #Rust spread datum
 *
 * Simple datum that automatically spreads rust around it
 *
 * Simple implementation of automatically growing entity
 */
/datum/rust_spread
	/// The rate of spread every tick.
	var/spread_per_sec = 6
	/// The very center of the spread.
	var/turf/centre
	/// List of turfs at the edge of our rust (but not yet rusted).
	var/list/edge_turfs = list()
	/// List of all turfs we've afflicted.
	var/list/rusted_turfs = list()
	/// Static blacklist of turfs we can't spread to.
	var/static/list/blacklisted_turfs = typecacheof(list(
		/turf/open/indestructible,
		/turf/closed/indestructible,
		/turf/open/space,
		/turf/open/lava,
		/turf/open/chasm
	))

/datum/rust_spread/New(loc)
	centre = get_turf(loc)
	centre.rust_heretic_act()
	rusted_turfs += centre
	START_PROCESSING(SSprocessing, src)

/datum/rust_spread/Destroy(force, ...)
	centre = null
	edge_turfs.Cut()
	rusted_turfs.Cut()
	STOP_PROCESSING(SSprocessing, src)
	return ..()

/datum/rust_spread/process(delta_time)
	var/spread_amount = round(spread_per_sec * delta_time)

	if(length(edge_turfs) < spread_amount)
		compile_turfs()

	for(var/i in 0 to spread_amount)
		if(!length(edge_turfs))
			break
		var/turf/afflicted_turf = pick_n_take(edge_turfs)
		afflicted_turf.rust_heretic_act()
		rusted_turfs |= afflicted_turf


/**
 * Compile turfs
 *
 * Recreates all edge_turfs as well as normal turfs.
 */
/datum/rust_spread/proc/compile_turfs()
	edge_turfs.Cut()

	var/max_dist = 1
	for(var/turf/found_turf as anything in rusted_turfs)
		if(!HAS_TRAIT(found_turf, TRAIT_RUSTY))
			rusted_turfs -= found_turf
		max_dist = max(max_dist, get_dist(found_turf, centre) + 1)

	for(var/turf/nearby_turf as anything in spiral_range_turfs(max_dist, centre, FALSE))
		if(nearby_turf in rusted_turfs || is_type_in_typecache(nearby_turf, blacklisted_turfs))
			continue

		for(var/turf/line_turf as anything in getline(nearby_turf, centre))
			if(get_dist(nearby_turf, line_turf) <= 1)
				edge_turfs |= nearby_turf
		CHECK_TICK
