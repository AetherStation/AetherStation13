/**
 * An armblade that instantly snuffs out lights
 */
/obj/item/light_eater
	name = "light eater" //as opposed to heavy eater
	icon = 'icons/obj/changeling_items.dmi'
	icon_state = "arm_blade"
	inhand_icon_state = "arm_blade"
	force = 25
	armour_penetration = 35
	lefthand_file = 'icons/mob/inhands/antag/changeling_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/antag/changeling_righthand.dmi'
	item_flags = ABSTRACT | DROPDEL | ACID_PROOF
	w_class = WEIGHT_CLASS_HUGE
	sharpness = SHARP_EDGED
	tool_behaviour = TOOL_MINING
	hitsound = 'sound/weapons/bladeslice.ogg'
	wound_bonus = -30
	bare_wound_bonus = 20

/obj/item/light_eater/Initialize()
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, HAND_REPLACEMENT_TRAIT)
	AddComponent(/datum/component/butchering, 80, 70)
	AddComponent(/datum/component/light_eater)

/obj/item/light_eater/afterattack(atom/target, mob/user, proximity)
	. = ..()
	if(!proximity)
		return

	if(istype(target, /obj/machinery/door/airlock))
		var/obj/machinery/door/airlock/A = target

		if((!A.requiresID() || A.allowed(user)) && A.hasPower())
			return
		if(A.locked)
			to_chat(user, span_warning("The airlock's bolts prevent it from being forced!"))
			return

		if(A.hasPower())
			user.visible_message(span_warning("[user] jams [src] into the airlock and starts prying it open!"), span_warning("You start forcing the [A] open."), \
			span_hear("You hear a metal screeching sound."))
			playsound(A, 'sound/machines/airlock_alien_prying.ogg', 100, TRUE)
			if(!do_after(user, 5 SECONDS, target = A))
				return
		user.visible_message(span_warning("[user] forces the airlock to open with [user.p_their()] [src]!"), span_warning("You force the [A] to open."), \
		span_hear("You hear a metal screeching sound."))
		A.open(2)
