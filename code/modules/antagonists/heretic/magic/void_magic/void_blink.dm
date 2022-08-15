/obj/effect/proc_holder/spell/pointed/void_blink
	name = "Void Phase"
	desc = "Let's you blink to your pointed destination, causes 3x3 aoe damage bubble around your pointed destination and your current location. It has a minimum range of 3 tiles and a maximum range of 9 tiles."
	invocation_type = INVOCATION_WHISPER
	school = SCHOOL_FORBIDDEN
	invocation = "RE'L'TY PH'S'E"
	clothes_req = FALSE
	range = 9
	action_background_icon_state = "bg_ecult"
	charge_max = 300
	action_icon = 'icons/mob/actions/actions_ecult.dmi'
	action_icon_state = "voidblink"
	selection_type = "range"

/obj/effect/proc_holder/spell/pointed/void_blink/can_target(atom/target, mob/user, silent)
	. = ..()
	if(get_dist(get_turf(user),get_turf(target)) < 3 )
		return FALSE

/obj/effect/proc_holder/spell/pointed/void_blink/cast(list/targets, mob/user)
	. = ..()
	var/target = targets[1]
	var/turf/targeted_turf = get_turf(target)

	playsound(user,'sound/magic/voidblink.ogg',100)
	playsound(targeted_turf,'sound/magic/voidblink.ogg',100)

	new /obj/effect/temp_visual/voidin(user.drop_location())
	new /obj/effect/temp_visual/voidout(targeted_turf)

	for(var/mob/living/living_mob in range(1,user)-user)
		if(IS_HERETIC_OR_MONSTER(living_mob))
			continue
		living_mob.adjustBruteLoss(40)

	for(var/mob/living/living_mob in range(1,targeted_turf)-user)
		if(IS_HERETIC_OR_MONSTER(living_mob))
			continue
		living_mob.adjustBruteLoss(40)

	do_teleport(user,targeted_turf,TRUE,no_effects = TRUE,channel=TELEPORT_CHANNEL_MAGIC)

/obj/effect/temp_visual/voidin
	icon = 'icons/effects/96x96.dmi'
	icon_state = "void_blink_in"
	alpha = 150
	duration = 6
	pixel_x = -32
	pixel_y = -32

/obj/effect/temp_visual/voidout
	icon = 'icons/effects/96x96.dmi'
	icon_state = "void_blink_out"
	alpha = 150
	duration = 6
	pixel_x = -32
	pixel_y = -32
