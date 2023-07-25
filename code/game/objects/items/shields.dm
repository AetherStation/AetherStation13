/obj/item/shield
	name = "shield"
	icon = 'icons/obj/shields.dmi'
	block_chance = 50
	armor = list(MELEE = 50, BULLET = 50, LASER = 50, ENERGY = 0, BOMB = 30, BIO = 0, RAD = 0, FIRE = 80, ACID = 70)
	var/transparent = FALSE // makes beam projectiles pass through the shield

/obj/item/shield/proc/on_shield_block(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", damage = 0, attack_type = MELEE_ATTACK)
	return TRUE

/obj/item/shield/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	if(transparent && (hitby.pass_flags & PASSGLASS))
		return FALSE
	if(attack_type == THROWN_PROJECTILE_ATTACK)
		final_block_chance += 30
	if(attack_type == LEAP_ATTACK)
		final_block_chance = 100
	. = ..()
	if(.)
		on_shield_block(owner, hitby, attack_text, damage, attack_type)

/obj/item/shield/energy
	name = "energy combat shield"
	desc = "A shield that reflects almost all energy projectiles, but is useless against physical attacks. It can be retracted, expanded, and stored anywhere."
	lefthand_file = 'icons/mob/inhands/equipment/shields_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/shields_righthand.dmi'
	w_class = WEIGHT_CLASS_TINY
	attack_verb_continuous = list("shoves", "bashes")
	attack_verb_simple = list("shove", "bash")
	throw_range = 5
	force = 3
	throwforce = 3
	throw_speed = 3
	base_icon_state = "eshield" // [base_icon_state]1 for expanded, [base_icon_state]0 for contracted
	var/on_force = 10
	var/on_throwforce = 8
	var/on_throw_speed = 2
	var/active = 0
	var/clumsy_check = TRUE

/obj/item/shield/energy/Initialize()
	. = ..()
	icon_state = "[base_icon_state]0"

/obj/item/shield/energy/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	return 0

/obj/item/shield/energy/IsReflect()
	return (active)

/obj/item/shield/energy/attack_self(mob/living/carbon/human/user)
	if(clumsy_check && HAS_TRAIT(user, TRAIT_CLUMSY) && prob(50))
		to_chat(user, span_userdanger("You beat yourself in the head with [src]!"))
		user.take_bodypart_damage(5)
	active = !active
	icon_state = "[base_icon_state][active]"

	if(active)
		force = on_force
		throwforce = on_throwforce
		throw_speed = on_throw_speed
		w_class = WEIGHT_CLASS_BULKY
		playsound(user, 'sound/weapons/saberon.ogg', 35, TRUE)
		to_chat(user, span_notice("[src] is now active."))
	else
		force = initial(force)
		throwforce = initial(throwforce)
		throw_speed = initial(throw_speed)
		w_class = WEIGHT_CLASS_TINY
		playsound(user, 'sound/weapons/saberoff.ogg', 35, TRUE)
		to_chat(user, span_notice("[src] can now be concealed."))
	add_fingerprint(user)

/obj/item/shield/riot
	name = "riot shield"
	desc = "A shield adept at blocking blunt objects from connecting with the torso of the shield wielder."
	icon_state = "riot"
	lefthand_file = 'icons/mob/inhands/equipment/shields_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/shields_righthand.dmi'
	slot_flags = ITEM_SLOT_BACK
	force = 10
	throwforce = 5
	throw_speed = 2
	throw_range = 3
	w_class = WEIGHT_CLASS_BULKY
	custom_materials = list(/datum/material/glass=7500, /datum/material/iron=1000)
	attack_verb_continuous = list("shoves", "bashes")
	attack_verb_simple = list("shove", "bash")
	var/cooldown = 0 //shield bash cooldown. based on world.time
	transparent = TRUE
	max_integrity = 75
	material_flags = MATERIAL_NO_EFFECTS
	var/fixing_material = /obj/item/stack/sheet/rglass
	var/flashmount_installed = FALSE //if shield has flashmount installed on it
	var/obj/item/assembly/flash/handheld/embedded_flash //flash inserted into the shield
	var/can_strobe = TRUE //whenever or not you can convert those shields into flash shields
	var/flashing = FALSE //if shield is flashing currently

/obj/item/shield/riot/Initialize()
	. = ..()
	if(flashmount_installed)
		embedded_flash = new(src)
		update_appearance()

/obj/item/shield/riot/ComponentInitialize()
	. = .. ()
	AddElement(/datum/element/update_icon_updates_onmob)

/obj/item/shield/riot/attack(mob/living/M, mob/user)
	if(user.istate.secondary)
		return ..()
	if(embedded_flash)
		if(embedded_flash.burnt_out)
			return ..()
		embedded_flash.attack(M, user)
		update_appearance(flash = TRUE)
	else
		. = ..()

/obj/item/shield/riot/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/melee/baton))
		if(cooldown < world.time - 25)
			user.visible_message(span_warning("[user] bashes [src] with [W]!"))
			playsound(user.loc, 'sound/effects/shieldbash.ogg', 50, TRUE)
			cooldown = world.time
		return

	if(istype(W, fixing_material))
		if (obj_integrity >= max_integrity)
			to_chat(user, span_warning("[src] is already in perfect condition."))
		else
			var/obj/item/stack/sheet/T = W
			T.use(1)
			obj_integrity = max_integrity
			to_chat(user, span_notice("You repair [src] with [T]."))
		return

	if(istype(W, /obj/item/wallframe/flasher) && can_strobe)
		if(flashmount_installed)
			to_chat("Flashbulb mount is already attached!")
			return
		to_chat(user, span_notice("You begin to attach the flashbulb mount..."))
		if(do_after(user, 20, target = user))
			if(!W || QDELETED(W))
				return
			playsound(src, 'sound/items/deconstruct.ogg', 50, TRUE)
			flashmount_installed = TRUE
			update_appearance()
			qdel(W)
		return

	if(istype(W, /obj/item/assembly/flash/handheld) && flashmount_installed)
		var/obj/item/assembly/flash/handheld/flash = W
		if(flash?.burnt_out)
			to_chat(user, span_warning("You feel like you want to reconsider putting a burnt out flashbulb inside!"))
		to_chat(user, span_notice("You begin to replace the flashbulb..."))
		if(do_after(user, 20, target = user))
			if(!flash || QDELETED(flash))
				return
			playsound(src, 'sound/items/deconstruct.ogg', 50, TRUE)
			if(embedded_flash)
				embedded_flash.forceMove(get_turf(src))
			embedded_flash = flash
			flash.forceMove(src)
			update_appearance()
		return

	if ((W.tool_behaviour == TOOL_WIRECUTTER) && embedded_flash)
		to_chat(user, span_notice("You begin to disconnect the flashbulb..."))
		if(W.use_tool(src, user, 20, volume=50) && embedded_flash)
			embedded_flash.forceMove(get_turf(src))
			embedded_flash = null
			update_appearance()
		return

	if (W.tool_behaviour == TOOL_CROWBAR)
		if(flashmount_installed && !embedded_flash)
			to_chat(user, span_notice("You begin to pry off the flashbulb mount..."))
			if(W.use_tool(src, user, 20, volume=50) && flashmount_installed)
				flashmount_installed = FALSE
				new /obj/item/wallframe/flasher(get_turf(src))
				update_appearance()
		else
			to_chat(user, span_warning("Remove flashbulb from the [src] first!"))
	return ..()

/obj/item/shield/riot/attack_self(mob/living/carbon/user)
	if(embedded_flash)
		if(embedded_flash.burnt_out)
			return ..()
		. = embedded_flash.attack_self(user)
		update_appearance(flash = TRUE)
	else
		return ..()

/obj/item/shield/riot/examine(mob/user)
	. = ..()
	var/healthpercent = round((obj_integrity/max_integrity) * 100, 1)
	switch(healthpercent)
		if(50 to 99)
			. += span_info("It looks slightly damaged.")
		if(25 to 50)
			. += span_info("It appears heavily damaged.")
		if(0 to 25)
			. += span_warning("It's falling apart!")

	if(flashmount_installed)
		. += span_info("It has a flashbulb mounting point installed [ embedded_flash ? "with a flashbulb inside" : "" ].")
	if(embedded_flash && istype(embedded_flash, /obj/item/assembly/flash/handheld/hypnotic))
		. += span_info("The flashbulb emits soothing purple light...")
	if(embedded_flash?.burnt_out)
		. += span_info("The mounted flashbulb has burnt out. You can try replacing it with a new one.")

/obj/item/shield/riot/emp_act(severity)
	. = ..()
	if(embedded_flash)
		embedded_flash.emp_act(severity)
		update_appearance(flash = TRUE)


/obj/item/shield/riot/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	. = ..()
	if (. && !embedded_flash.burnt_out)
		embedded_flash.activate()
		update_appearance(flash = TRUE)

/obj/item/shield/riot/on_shield_block(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", damage = 0, attack_type = MELEE_ATTACK)
	if (obj_integrity <= damage)
		var/turf/T = get_turf(owner)
		T.visible_message(span_warning("[hitby] destroys [src]!"))
		shatter(owner)
		qdel(src)
		return FALSE
	take_damage(damage)
	return ..()

/obj/item/shield/riot/proc/shatter(mob/living/carbon/human/owner)
	playsound(owner, 'sound/effects/glassbr3.ogg', 100)
	new /obj/item/shard((get_turf(src)))

/obj/item/shield/riot/update_icon_state()
	inhand_icon_state = "[flashmount_installed ? "[initial(icon_state)]strobe" : "[initial(icon_state)]"]"
	return ..()

/obj/item/shield/riot/update_overlays()
	. = ..()
	if(flashmount_installed)
		. += "flashmount"
	if(embedded_flash)
		. += "flash[embedded_flash.burnt_out ? "burnt" : "idle" ]"
	if(flashing && !(embedded_flash?.burnt_out))
		. += "flashact"

/obj/item/shield/riot/update_name()
	name = "[flashmount_installed ? "Strobe [initial(name)]" : "[initial(name)]"]"
	return ..()

/obj/item/shield/riot/update_appearance(updates, flash = FALSE)
	flashing = flash
	. = ..()
	if(flash)
		addtimer(CALLBACK(src, TYPE_PROC_REF(/atom, update_appearance)), 5)

/obj/item/shield/riot/strobe
	flashmount_installed = TRUE

/obj/item/shield/riot/buckler
	name = "wooden buckler"
	desc = "A medieval wooden buckler."
	icon_state = "buckler"
	inhand_icon_state = "buckler"
	lefthand_file = 'icons/mob/inhands/equipment/shields_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/shields_righthand.dmi'
	custom_materials = list(/datum/material/wood = MINERAL_MATERIAL_AMOUNT * 10)
	resistance_flags = FLAMMABLE
	block_chance = 30
	transparent = FALSE
	max_integrity = 55
	w_class = WEIGHT_CLASS_NORMAL
	fixing_material = /obj/item/stack/sheet/mineral/wood

/obj/item/shield/riot/buckler/shatter(mob/living/carbon/human/owner)
	playsound(owner, 'sound/effects/bang.ogg', 50)
	new /obj/item/stack/sheet/mineral/wood(get_turf(src))

/obj/item/shield/riot/buckler/strobe
	flashmount_installed = TRUE

/obj/item/shield/riot/roman
	name = "\improper Roman shield"
	desc = "Bears an inscription on the inside: <i>\"Romanes venio domus\"</i>."
	icon_state = "roman_shield"
	inhand_icon_state = "roman_shield"
	lefthand_file = 'icons/mob/inhands/equipment/shields_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/shields_righthand.dmi'
	transparent = FALSE
	custom_materials = list(/datum/material/iron=8500)
	max_integrity = 65
	fixing_material = /obj/item/stack/sheet/iron
	can_strobe = FALSE //this shield wont be able to become stroboscopic

/obj/item/shield/riot/roman/shatter(mob/living/carbon/human/owner)
	playsound(owner, 'sound/effects/grillehit.ogg', 100)
	new /obj/item/stack/sheet/iron(get_turf(src))

/obj/item/shield/riot/roman/fake
	desc = "Bears an inscription on the inside: <i>\"Romanes venio domus\"</i>. It appears to be a bit flimsy."
	block_chance = 50
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 0, ACID = 0)
	max_integrity = 20

/obj/item/shield/riot/tele
	name = "telescopic shield"
	desc = "An advanced riot shield made of lightweight materials that collapses for easy storage."
	icon_state = "teleriot0"
	lefthand_file = 'icons/mob/inhands/equipment/shields_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/shields_righthand.dmi'
	custom_materials = list(/datum/material/iron = 3600, /datum/material/glass = 3600, /datum/material/silver = 270, /datum/material/titanium = 180)
	slot_flags = null
	force = 3
	throwforce = 3
	throw_speed = 3
	throw_range = 4
	w_class = WEIGHT_CLASS_NORMAL
	var/active = 0

/obj/item/shield/riot/tele/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	if(active)
		return ..()
	return 0

/obj/item/shield/riot/tele/AltClick(mob/living/user)
	if(src != user.get_active_held_item())
		to_chat(user, span_alert("You need to hold \the [src] in hand!"))
		return
	active = !active
	playsound(src.loc, 'sound/weapons/batonextend.ogg', 50, TRUE)

	if(active)
		force = 8
		throwforce = 5
		throw_speed = 2
		w_class = WEIGHT_CLASS_BULKY
		slot_flags = ITEM_SLOT_BACK
		to_chat(user, span_notice("You extend \the [src]."))
	else
		force = 3
		throwforce = 3
		throw_speed = 3
		w_class = WEIGHT_CLASS_NORMAL
		slot_flags = null
		to_chat(user, span_notice("[src] can now be concealed."))
	add_fingerprint(user)
	update_appearance()

/obj/item/shield/riot/tele/update_icon_state()
	..()
	icon_state = "teleriot[active]"
	inhand_icon_state = "[flashmount_installed ? "teleriot[active]strobe" : "teleriot[active]"]"

/obj/item/shield/riot/tele/strobe
	flashmount_installed = TRUE
