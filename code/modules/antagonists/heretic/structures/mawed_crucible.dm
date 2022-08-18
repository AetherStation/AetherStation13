/obj/structure/eldritch_crucible
	name = "Mawed Crucible"
	desc = "Immortalized cast iron, the steel-like teeth holding it in place, it's vile extract has the power of rebirthing things, remaking them from the very beginning."
	icon = 'icons/obj/eldritch.dmi'
	icon_state = "crucible"
	base_icon_state = "crucible"
	anchored = FALSE
	density = TRUE
	///How much mass this currently holds
	var/current_mass = 5
	///Maximum amount of mass
	var/max_mass = 5
	///Check to see if it is currently being used.
	var/in_use = FALSE

/obj/structure/eldritch_crucible/examine(mob/user)
	. = ..()
	if(!IS_HERETIC(user) && !IS_HERETIC_MONSTER(user))
		return
	if(current_mass < max_mass)
		. += "The Crucible requires [max_mass - current_mass] more organs or bodyparts!"
	else
		. += "The Crucible is ready to be used!"

	. += "You can anchor and reanchor it using Codex Cicatrix!"
	. += "It is currently [anchored == FALSE ? "unanchored" : "anchored"]"
	. += "This structure can brew 'Brew of Crucible soul' - when used it gives you the ability to phase through matter for 15 seconds, after the time elapses it teleports you back to your original location"
	. += "This structure can brew 'Brew of Dusk and Dawn' - when used it gives you xray for 1 minute"
	. += "This structure can brew 'Brew of Wounded Soldier' - when used it makes you immune to damage slowdown, additionally you start healing for every wound you have, quickly outpacing the damage caused by them."

/obj/structure/eldritch_crucible/attacked_by(obj/item/I, mob/living/user)
	if(istype(I,/obj/item/nullrod))
		qdel(src)
		return

	if(!IS_HERETIC(user) && !IS_HERETIC_MONSTER(user))
		if(iscarbon(user))
			devour(user)
		return

	if(istype(I,/obj/item/forbidden_book))
		playsound(src, 'sound/misc/desecration-02.ogg', 75, TRUE)
		set_anchored(!anchored)
		to_chat(user,span_notice("You [anchored == FALSE ? "unanchor" : "anchor"] the crucible"))
		return

	if(istype(I,/obj/item/bodypart) || istype(I,/obj/item/organ))
		//Both organs and bodyparts hold information if they are organic or robotic in the exact same way.
		var/obj/item/bodypart/forced = I
		if(forced.status != BODYPART_ORGANIC)
			return

		if(current_mass >= max_mass)
			to_chat(user,span_notice(" Crucible is already full!"))
			return
		playsound(src, 'sound/items/eatfood.ogg', 100, TRUE)
		to_chat(user,span_notice("Crucible devours [I.name] and fills itself with a little bit of liquid!"))
		current_mass++
		qdel(I)
		update_icon_state()
		return

	return ..()

/obj/structure/eldritch_crucible/attack_hand(mob/user)
	if(!IS_HERETIC(user) && !IS_HERETIC_MONSTER(user))
		if(iscarbon(user))
			devour(user)
		return

	if(in_use)
		to_chat(user,span_notice("Crucible is already in use!"))
		return

	if(current_mass < max_mass)
		to_chat(user,span_notice("Crucible isn't full! Bring it more organs or bodyparts!"))
		return

	in_use = TRUE
	var/list/lst = list()
	for(var/X in subtypesof(/obj/item/eldritch_potion))
		var/obj/item/eldritch_potion/potion = X
		lst[initial(potion.name)] = potion
	var/type = lst[input(user,"Choose your brew","Brew") in lst]
	playsound(src, 'sound/misc/desecration-02.ogg', 75, TRUE)
	new type(drop_location())
	current_mass = 0
	in_use = FALSE
	update_icon_state()

///Proc that eats the active limb of the victim
/obj/structure/eldritch_crucible/proc/devour(mob/living/carbon/user)
	if(HAS_TRAIT(user,TRAIT_NODISMEMBER))
		return
	playsound(src, 'sound/items/eatfood.ogg', 100, TRUE)
	to_chat(user,span_danger("Crucible grabs your arm and devours it whole!"))
	var/obj/item/bodypart/arm = user.get_active_hand()
	arm.dismember()
	qdel(arm)
	current_mass += current_mass < max_mass ? 1 : 0
	update_icon_state()

/obj/structure/eldritch_crucible/update_icon_state()
	icon_state = "[base_icon_state][(current_mass == max_mass) ? null : "_empty"]"
	return ..()

/obj/item/eldritch_potion
	name = "Brew of Day and Night"
	desc = "You should never see this"
	icon = 'icons/obj/eldritch.dmi'
	///Typepath to the status effect this is supposed to hold
	var/status_effect

/obj/item/eldritch_potion/attack_self(mob/user)
	. = ..()
	to_chat(user,span_notice("You drink the potion and with the viscous liquid, the glass dematerializes."))
	effect(user)
	qdel(src)

///The effect of the potion if it has any special one, in general try not to override this and utilize the status_effect var to make custom effects.
/obj/item/eldritch_potion/proc/effect(mob/user)
	if(!iscarbon(user))
		return
	var/mob/living/carbon/carbie = user
	carbie.apply_status_effect(status_effect)

/obj/item/eldritch_potion/crucible_soul
	name = "Brew of Crucible Soul"
	desc = "Allows you to phase through walls for 15 seconds, after the time runs out, you get teleported to your original location."
	icon_state = "crucible_soul"
	status_effect = /datum/status_effect/crucible_soul

/obj/item/eldritch_potion/duskndawn
	name = "Brew of Dusk and Dawn"
	desc = "Allows you to see clearly through walls and objects for 60 seconds."
	icon_state = "clarity"
	status_effect = /datum/status_effect/duskndawn

/obj/item/eldritch_potion/wounded
	name = "Brew of Wounded Soldier"
	desc = "For the next 60 seconds each wound will heal you, minor wounds heal 1 of it's damage type per second, moderate heal 3 and critical heal 6. You also become immune to damage slowdon."
	icon_state = "marshal"
	status_effect = /datum/status_effect/marshal
