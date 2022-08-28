/obj/effect/proc_holder/spell/targeted/void_jaunt
	name = "Void Jaunt"
	desc = "Move through the void for a time, avoiding mortal eyes and lights."
	charge_max = 2 MINUTES
	clothes_req = FALSE
	antimagic_allowed = TRUE
	phase_allowed = TRUE
	selection_type = "range"
	range = -1
	include_user = TRUE
	overlay = null
	action_icon = 'icons/mob/actions/actions_spells.dmi'
	action_icon_state = "jaunt"

	var/apply_damage = TRUE

/obj/effect/proc_holder/spell/targeted/void_jaunt/cast(list/targets,mob/living/user = usr)
	var/L = user.loc
	if(istype(user.loc, /obj/effect/dummy/phased_mob))
		if(istype(user.loc, /obj/effect/dummy/phased_mob/void))
			var/obj/effect/dummy/phased_mob/shadow/S = L
			S.end_jaunt(FALSE)
		return	
	else
		playsound(get_turf(user), 'sound/magic/ethereal_enter.ogg', 50, 1, -1)
		if(apply_damage)
			user.visible_message("<span class='boldwarning'>[user] melts into the shadows!</span>",
													"<span class='alien'>Steeling yourself, you dive into the void.</span>")
		else
			user.visible_message("<span class='boldwarning'>[user] melts into the shadows!</span>",
													"<span class='alien'>You allow yourself to fall into the void.</span>")
		user.SetAllImmobility(0)
		user.setStaminaLoss(0, 0)
		var/obj/effect/dummy/phased_mob/shadow/S2 = new(get_turf(user.loc))
		S2.apply_damage = apply_damage
		user.forceMove(S2)
		S2.jaunter = user
		charge_counter = charge_max //Don't have to wait for cooldown to exit

///Amount of stamina damage dealed to nightmares when they exit this. Both have to be high to cancel out natural regeneration
#define VOIDJAUNT_STAM_PENALTY_DARK 10
#define VOIDJAUNT_STAM_PENALTY_LIGHT 35

/obj/effect/dummy/phased_mob/void
	name = "darkness"
	icon = 'icons/effects/effects.dmi'
	icon_state = "nothing"
	var/canmove = TRUE
	density = FALSE
	anchored = TRUE
	invisibility = 60
	resistance_flags = LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF

	var/mob/living/jaunter
	var/apply_damage = TRUE
	var/move_delay = 0			//Time until next move allowed
	var/move_speed = 2			//Deciseconds per move

/obj/effect/dummy/phased_mob/void/relaymove(mob/user, direction)
	if(move_delay > world.time && apply_damage)	//Ascendants get no slowdown
		return

	move_delay = world.time + move_speed
	var/turf/newLoc = get_step(src,direction)
	forceMove(newLoc)

/obj/effect/dummy/phased_mob/void/proc/check_light_level()
	var/turf/T = get_turf(src)
	var/light_amount = T.get_lumcount()
	if(light_amount > SHADOW_SPECIES_LIGHT_THRESHOLD)	//Increased penalty
		jaunter.adjustStaminaLoss(VOIDJAUNT_STAM_PENALTY_LIGHT)
	else
		jaunter.adjustStaminaLoss(VOIDJAUNT_STAM_PENALTY_DARK)

/obj/effect/dummy/phased_mob/void/proc/end_jaunt(forced = FALSE)
	if(jaunter)
		jaunter.forceMove(get_turf(src))
		if(forced)
			jaunter.visible_message("<span class='boldwarning'>A dark shape stumbles from a hole in the air and collapses!</span>",
															"<span class='alien'><b>Straining, you use the last of your energy to force yourself from the void.</b></span>")
		else
			jaunter.visible_message("<span class='boldwarning'>A dark shape tears itself from nothingness!</span>",
															"<span class='alien'>You exit the void.</span>")

		playsound(get_turf(jaunter), 'sound/magic/ethereal_exit.ogg', 50, 1, -1)
		jaunter = null
	qdel(src)

/obj/effect/dummy/phased_mob/void/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/effect/dummy/phased_mob/void/Destroy()
	STOP_PROCESSING(SSobj, src)
	. = ..()

/obj/effect/dummy/phased_mob/void/process()
	if(!jaunter)
		qdel(src)
	if(jaunter.loc != src)
		qdel(src)

	if(apply_damage)
		check_light_level()

		//True if jaunter entered stamcrit
		if(jaunter.IsParalyzed())
			end_jaunt(TRUE)
			return

/obj/effect/dummy/phased_mob/void/ex_act()
	return

/obj/effect/dummy/phased_mob/void/bullet_act()
	return BULLET_ACT_FORCE_PIERCE

/obj/effect/dummy/phased_mob/void/singularity_act()
	return

#undef VOIDJAUNT_STAM_PENALTY_DARK
#undef VOIDJAUNT_STAM_PENALTY_LIGHT
