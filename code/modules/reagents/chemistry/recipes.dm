/**
 * #Chemical Reaction
 *
 * Datum that makes the magic between reagents happen.
 *
 * Chemical reactions is a class that is instantiated and stored in a global list 'chemical_reactions_list'
 */
/datum/chemical_reaction
	///Results of the chemical reactions
	var/list/results = new/list()
	///Required chemicals that are USED in the reaction
	var/list/required_reagents = new/list()
	///Required chemicals that must be present in the container but are not USED.
	var/list/required_catalysts = new/list()

	// Both of these variables are mostly going to be used with slime cores - but if you want to, you can use them for other things
	/// the exact container path required for the reaction to happen
	var/required_container
	/// an integer required for the reaction to happen
	var/required_other = 0

	///Determines if a chemical reaction can occur inside a mob
	var/mob_react = TRUE
	///The message shown to nearby people upon mixing, if applicable
	var/mix_message = "The solution begins to bubble."
	///The sound played upon mixing, if applicable
	var/mix_sound = 'sound/effects/bubbles.ogg'

	/// Set to TRUE if you want the recipe to only react when it's BELOW the required temp.
	var/is_cold_recipe = FALSE
	///Required temperature for the reaction to begin, for fermimechanics it defines the lower area of bell curve for determining heat based rate reactions, aka the minimum
	var/required_temp = 100

/datum/chemical_reaction/New()
	. = ..()
	SSticker.OnRoundstart(CALLBACK(src,PROC_REF(update_info)))

/**
 * Updates information during the roundstart
 *
 * This proc is mainly used by explosives but can be used anywhere else
 * You should generally use the special reactions in [/datum/chemical_reaction/randomized]
 * But for simple variable edits, like changing the temperature or adding/subtracting required reagents it is better to use this.
 */
/datum/chemical_reaction/proc/update_info()
	return

///REACTION PROCS

/**
 * Shit that happens on reaction
 * Only procs at the START of a reaction
 * use reaction_step() for each step of a reaction
 * or reaction_end() when the reaction stops
 * If reaction_flags & REACTION_INSTANT then this is the only proc that is called.
 *
 * Proc where the additional magic happens.
 * You dont want to handle mob spawning in this since there is a dedicated proc for that.client
 * Arguments:
 * * holder - the datum that holds this reagent, be it a beaker or anything else
 * * created_volume - volume created when this is mixed. look at 'var/list/results'.
 */
/datum/chemical_reaction/proc/on_reaction(datum/reagents/holder, created_volume)
	return
	//I recommend you set the result amount to the total volume of all components.

/**
 * Magical mob spawning when chemicals react
 *
 * Your go to proc when you want to create new mobs from chemicals. please dont use on_reaction.
 * Arguments:
 * * holder - the datum that holds this reagent, be it a beaker or anything else
 * * amount_to_spawn - how much /mob to spawn
 * * reaction_name - what is the name of this reaction. be creative, the world is your oyster after all!
 * * mob_class - determines if the mob will be friendly, neutral or hostile
 * * mob_faction - used in determining targets, mobs from the same faction won't harm eachother.
 * * random - creates random mobs. self explanatory.
 */
/datum/chemical_reaction/proc/chemical_mob_spawn(datum/reagents/holder, amount_to_spawn, reaction_name, mob_class = HOSTILE_SPAWN, mob_faction = "chemicalsummon", random = TRUE)
	if(holder?.my_atom)
		var/atom/A = holder.my_atom
		var/turf/T = get_turf(A)
		var/message = "Mobs have been spawned in [ADMIN_VERBOSEJMP(T)] by a [reaction_name] reaction."
		message += " (<A HREF='?_src_=vars;Vars=[REF(A)]'>VV</A>)"

		var/mob/M = get(A, /mob)
		if(M)
			message += " - Carried By: [ADMIN_LOOKUPFLW(M)]"
		else
			message += " - Last Fingerprint: [(A.fingerprintslast ? A.fingerprintslast : "N/A")]"

		message_admins(message, 0, 1)
		log_game("[reaction_name] chemical mob spawn reaction occuring at [AREACOORD(T)] carried by [key_name(M)] with last fingerprint [A.fingerprintslast? A.fingerprintslast : "N/A"]")

		playsound(get_turf(holder.my_atom), 'sound/effects/phasein.ogg', 100, TRUE)

		for(var/mob/living/carbon/C in viewers(get_turf(holder.my_atom), null))
			C.flash_act()

		for(var/i in 1 to amount_to_spawn)
			var/mob/living/simple_animal/S
			if(random)
				S = create_random_mob(get_turf(holder.my_atom), mob_class)
			else
				S = new mob_class(get_turf(holder.my_atom))//Spawn our specific mob_class
			S.faction |= mob_faction
			if(prob(50))
				for(var/j = 1, j <= rand(1, 3), j++)
					step(S, pick(NORTH,SOUTH,EAST,WEST))

/**
 * Magical move-wooney that happens sometimes.
 *
 * Simulates a vortex that moves nearby movable atoms towards or away from the turf T.
 * Range also determines the strength of the effect. High values cause nearby objects to be thrown.
 * Arguments:
 * * T - turf where it happens
 * * setting_type - does it suck or does it blow?
 * * range - range.
 */
/proc/goonchem_vortex(turf/T, setting_type, range)
	for(var/atom/movable/X in orange(range, T))
		if(X.anchored)
			continue
		if(iseffect(X) || iscameramob(X) || isdead(X))
			continue
		var/distance = get_dist(X, T)
		var/moving_power = max(range - distance, 1)
		if(moving_power > 2) //if the vortex is powerful and we're close, we get thrown
			if(setting_type)
				var/atom/throw_target = get_edge_target_turf(X, get_dir(X, get_step_away(X, T)))
				X.throw_at(throw_target, moving_power, 1)
			else
				X.throw_at(T, moving_power, 1)
		else
			if(setting_type)
				if(step_away(X, T) && moving_power > 1) //Can happen twice at most. So this is fine.
					addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(_step_away), X, T), 2)
			else
				if(step_towards(X, T) && moving_power > 1)
					addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(_step_towards), X, T), 2)

//////////////////Generic explosions/failures////////////////////
// It is HIGHLY, HIGHLY recomended that you consume all/a good volume of the reagents/products in an explosion - because it will just keep going forever until the reaction stops
//If you have competitive reactions - it's a good idea to consume ALL reagents in a beaker (or product+reactant), otherwise it'll swing back with the deficit and blow up again

/*
 * The same method that pyrotechnic reagents used before
 * Now instead of defining the var as part of the reaction - any recipe can call it and define their own method
 * WILL REMOVE ALL REAGENTS
 *
 * arguments:
 * * holder - the reagents datum that it is being used on
 * * created_volume - the volume of reacting elements
 * * modifier - a flat additive numeric to the size of the explosion - set this if you want a minimum range
 * * strengthdiv - the divisional factor of the explosion, a larger number means a smaller range - This is the part that modifies an explosion's range with volume (i.e. it divides it by this number)
 */
/datum/chemical_reaction/proc/default_explode(datum/reagents/holder, created_volume, modifier = 0, strengthdiv = 10)
	var/power = modifier + round(created_volume/strengthdiv, 1)
	if(power > 0)
		var/turf/T = get_turf(holder.my_atom)
		var/inside_msg
		if(ismob(holder.my_atom))
			var/mob/M = holder.my_atom
			inside_msg = " inside [ADMIN_LOOKUPFLW(M)]"
		var/lastkey = holder.my_atom.fingerprintslast //This can runtime (null.fingerprintslast) - due to plumbing?
		var/touch_msg = "N/A"
		if(lastkey)
			var/mob/toucher = get_mob_by_key(lastkey)
			touch_msg = "[ADMIN_LOOKUPFLW(toucher)]"
		if(!istype(holder.my_atom, /obj/machinery/plumbing)) //excludes standard plumbing equipment from spamming admins with this shit
			message_admins("Reagent explosion reaction occurred at [ADMIN_VERBOSEJMP(T)][inside_msg]. Last Fingerprint: [touch_msg].")
		log_game("Reagent explosion reaction occurred at [AREACOORD(T)]. Last Fingerprint: [lastkey ? lastkey : "N/A"]." )
		var/datum/effect_system/reagents_explosion/e = new()
		e.set_up(power, holder.my_atom, 0, 0)
		e.start()
	holder.clear_reagents()

/*
 *Creates a flash effect only - less expensive than explode()
 *
 * *Arguments
 * * range - the radius around the holder's atom that is flashed
 * * length - how long it lasts in ds
 */
/datum/chemical_reaction/proc/explode_flash(datum/reagents/holder, range = 2, length = 25)
	var/turf/location = get_turf(holder.my_atom)
	for(var/mob/living/living_mob in viewers(range, location))
		living_mob.flash_act(length = length)
	holder.my_atom.visible_message("The [holder.my_atom] suddenly lets out a bright flash!")

/*
 *Deafens those in range causing ear damage and muting sound
 *
 * Arguments
 * * power - How much damage is applied to the ear organ (I believe?)
 * * stun - How long the mob is stunned for
 * * range - the radius around the holder's atom that is banged
 */
/datum/chemical_reaction/proc/explode_deafen(datum/reagents/holder, power = 3, stun = 20, range = 2)
	var/location = get_turf(holder.my_atom)
	playsound(location, 'sound/effects/bang.ogg', 25, TRUE)
	for(var/mob/living/carbon/carbon_mob in get_hearers_in_view(range, location))
		carbon_mob.soundbang_act(1, stun, power)

//Spews out the corrisponding reactions reagents  (products/required) of the beaker in a smokecloud. Doesn't spew catalysts
/datum/chemical_reaction/proc/explode_smoke(datum/reagents/holder, force_range = 0, clear_products = TRUE, clear_reactants = TRUE)
	var/datum/reagents/reagents = new/datum/reagents(2100, NO_REACT)//Lets be safe first
	var/datum/effect_system/smoke_spread/chem/smoke = new()
	reagents.my_atom = holder.my_atom //fingerprint
	var/sum_volume = 0
	for (var/datum/reagent/reagent as anything in holder.reagent_list)
		if((reagent.type in required_reagents) || (reagent.type in results))
			reagents.add_reagent(reagent.type, reagent.volume, no_react = TRUE)
			holder.remove_reagent(reagent.type, reagent.volume)
	if(!force_range)
		force_range = (sum_volume/6) + 3
	if(reagents.reagent_list)
		smoke.set_up(reagents, force_range, holder.my_atom)
		smoke.start()
	holder.my_atom.audible_message("The [holder.my_atom] suddenly explodes, launching the aerosolized reagents into the air!")
	if(clear_reactants)
		clear_reactants(holder)
	if(clear_products)
		clear_products(holder)

//Pushes everything out, and damages mobs with 10 brute damage.
/datum/chemical_reaction/proc/explode_shockwave(datum/reagents/holder, range = 3, damage = 5, sound_and_text = TRUE, implosion = FALSE)
	var/turf/this_turf = get_turf(holder.my_atom)
	if(sound_and_text)
		holder.my_atom.audible_message("The [holder.my_atom] suddenly explodes, sending a shockwave rippling through the air!")
		playsound(this_turf, 'sound/chemistry/shockwave_explosion.ogg', 80, TRUE)
	//Modified goonvortex
	for(var/atom/movable/movey as anything in orange(range, this_turf))
		if(!istype(movey, /atom/movable))
			continue
		if(isliving(movey) && damage)
			var/mob/living/live = movey
			live.apply_damage(damage)//Since this can be called multiple times
		if(movey.anchored)
			continue
		if(iseffect(movey) || iscameramob(movey) || isdead(movey))
			continue
		if(implosion)
			var/distance = get_dist(movey, this_turf)
			var/moving_power = max(4 - distance, 1)
			var/turf/target = get_turf(holder.my_atom)
			movey.throw_at(target, moving_power, 1)
		else
			var/distance = get_dist(movey, this_turf)
			var/moving_power = max(3 - distance, 1)//Make sure we're thrown out of range of the next one
			var/atom/throw_target = get_edge_target_turf(movey, get_dir(movey, get_step_away(movey, this_turf)))
			movey.throw_at(throw_target, moving_power, 1)

////////BEGIN FIRE BASED EXPLOSIONS

//Calls the default explosion subsystem handiler to explode with fire (random firespots and noise)
/datum/chemical_reaction/proc/explode_fire(datum/reagents/holder, range = 3)
	explosion(holder.my_atom, flame_range = range)
	holder.my_atom.audible_message("The [holder.my_atom] suddenly errupts in flames!")

/*
 * Creates a square of fire in a fire_range radius,
 * fire_range = 0 will be on the exact spot of the holder,
 * fire_range = 1 or more will be additional tiles around the holder. Every tile will be heated this way.
 * How clf3 works, you know!
 */
/datum/chemical_reaction/proc/explode_fire_square(datum/reagents/holder, fire_range = 1)
	var/turf/location = get_turf(holder.my_atom)
	if(fire_range == 0)
		new /obj/effect/hotspot(location)
		return
	for(var/turf/turf as anything in RANGE_TURFS(fire_range, location))
		new /obj/effect/hotspot(turf)

///////////END FIRE BASED EXPLOSIONS

/*
* Freezes in a circle around the holder location
* Arguments:
* * temp - the temperature to set the air to
* * radius - the range of the effect
* * freeze_duration - how long the icey spots remain for
* * snowball_chance - the chance to spawn a snowball on a turf
*/
/datum/chemical_reaction/proc/freeze_radius(datum/reagents/holder, temp, radius = 2, freeze_duration = 50 SECONDS, snowball_chance = 0)
	for(var/any_turf in circlerangeturfs(center = get_turf(holder.my_atom), radius = radius))
		if(!istype(any_turf, /turf/open))
			continue
		var/turf/open/open_turf = any_turf
		open_turf.MakeSlippery(TURF_WET_PERMAFROST, freeze_duration, freeze_duration, freeze_duration)
		open_turf.temperature = temp
		if(prob(snowball_chance))
			new /obj/item/toy/snowball(open_turf)

///Clears the beaker of the reagents only
///if volume is not set, it will remove all of the reactant
/datum/chemical_reaction/proc/clear_reactants(datum/reagents/holder, volume = 1000)
	if(!holder)
		return FALSE
	for(var/reagent in required_reagents)
		holder.remove_reagent(reagent, volume)

///Clears the beaker of the product only
/datum/chemical_reaction/proc/clear_products(datum/reagents/holder, volume = 1000)
	if(!holder)
		return FALSE
	for(var/reagent in results)
		holder.remove_reagent(reagent, volume)


///Clears the beaker of ALL reagents inside
/datum/chemical_reaction/proc/clear_reagents(datum/reagents/holder, volume = 1000)
	if(!holder)
		return FALSE
	if(!volume)
		volume = holder.total_volume
	holder.remove_all(volume)

/*
* "Attacks" all mobs within range with a specified reagent
* Will be blocked if they're wearing proper protective equipment unless disabled
* Arguments
* * reagent - the reagent typepath that will be added
* * vol - how much will be added
* * range - the range that this will affect mobs for
* * ignore_mask - if masks block the effect, making this true will affect someone regardless
* * ignore_eyes - if glasses block the effect, making this true will affect someone regardless
*/
/datum/chemical_reaction/proc/explode_attack_chem(datum/reagents/holder, reagent, vol, range = 3, ignore_mask = FALSE, ignore_eyes = FALSE)
	if(istype(reagent, /datum/reagent))
		var/datum/reagent/temp_reagent = reagent
		reagent = temp_reagent.type
	for(var/mob/living/carbon/target in orange(range, get_turf(holder.my_atom)))
		if(target.has_smoke_protection() && !ignore_mask)
			continue
		if(target.get_eye_protection() && !ignore_eyes)
			continue
		to_chat(target, "The [holder.my_atom.name] launches some of [holder.p_their()] contents at you!")
		target.reagents.add_reagent(reagent, vol)
