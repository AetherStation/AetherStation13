/* Emags
 * Contains:
 * EMAGS AND DOORMAGS
 */


/*
 * EMAG AND SUBTYPES
 */
/obj/item/card/emag
	desc = "It's a card with a magnetic strip attached to some circuitry."
	name = "cryptographic sequencer"
	icon_state = "emag"
	inhand_icon_state = "card-id"
	lefthand_file = 'icons/mob/inhands/equipment/idcards_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/idcards_righthand.dmi'
	item_flags = NO_MAT_REDEMPTION | NOBLUDGEON
	slot_flags = ITEM_SLOT_ID
	worn_icon_state = "emag"
	var/prox_check = TRUE //If the emag requires you to be in range
	var/list/consumer_types //List of types that consume a charge upon hacking
	var/charges = 3 //How many charges do we currently have
	var/max_charges = 3 //How many charges can we hold in total
	var/charge_time = 1 MINUTES //How long does it take to gain a new charge
	var/current_cooldown //How long until we gain our next charge

/obj/item/card/emag/Initialize(mapload)
	. = ..()
	consumer_types = list(
		typesof(/obj/machinery/door/airlock),
		typesof(/obj/machinery/door/window/))

/obj/item/card/emag/attack_self(mob/user) //for traitors with balls of plastitanium
	if(Adjacent(user))
		user.visible_message(span_notice("[user] shows you: [icon2html(src, viewers(user))] [name]."), span_notice("You show [src]."))
	add_fingerprint(user)

/obj/item/card/emag/bluespace
	name = "bluespace cryptographic sequencer"
	desc = "It's a blue card with a magnetic strip attached to some circuitry. It appears to have some sort of transmitter attached to it."
	color = rgb(40, 130, 255)
	prox_check = FALSE

/obj/item/card/emag/halloween
	name = "hack-o'-lantern"
	desc = "It's a pumpkin with a cryptographic sequencer sticking out."
	icon_state = "hack_o_lantern"

/obj/item/card/emagfake
	desc = "It's a card with a magnetic strip attached to some circuitry. Closer inspection shows that this card is a poorly made replica, with a \"Donk Co.\" logo stamped on the back."
	name = "cryptographic sequencer"
	icon_state = "emag"
	inhand_icon_state = "card-id"
	slot_flags = ITEM_SLOT_ID
	worn_icon_state = "emag"
	lefthand_file = 'icons/mob/inhands/equipment/idcards_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/idcards_righthand.dmi'

/obj/item/card/emagfake/attack_self(mob/user) //for assistants with balls of plasteel
	if(Adjacent(user))
		user.visible_message(span_notice("[user] shows you: [icon2html(src, viewers(user))] [name]."), span_notice("You show [src]."))
	add_fingerprint(user)

/obj/item/card/emagfake/afterattack()
	. = ..()
	playsound(src, 'sound/items/bikehorn.ogg', 50, TRUE)

/obj/item/card/emag/afterattack(atom/target, mob/user, proximity)
	. = ..()
	var/atom/A = target
	if(!proximity && prox_check)
		return
	if(!can_emag(target, user))
		return
	log_combat(user, A, "attempted to emag")
	A.emag_act(user, src)

/obj/item/card/emag/proc/use_charge(mob/user)
	charges --
	to_chat(user, span_notice("You use [src]. It now has [charges] charges remaining."))
	current_cooldown = addtimer(CALLBACK(src, PROC_REF(recharge)), charge_time, TIMER_UNIQUE | TIMER_STOPPABLE)

/obj/item/card/emag/proc/can_emag(atom/target, mob/user)
	for (var/list/subtypelist in consumer_types)
		if((target.type in subtypelist) && charges <= 0)
			to_chat(user, span_warning("[src] is out of charges, give it <b>[timeleft(current_cooldown) * 0.1] seconds </b> to recharge!"))
			return FALSE
	return TRUE

/obj/item/card/emag/proc/recharge(mob/user)
	charges = min(charges+1, max_charges)
	playsound(src,'sound/machines/twobeep.ogg',10,TRUE, extrarange = SILENCED_SOUND_EXTRARANGE, falloff_distance = 0)

/obj/item/card/emag/examine(mob/user)
	. = ..()
	. += span_notice("It has [charges] charges remaining.")
	. += "[span_notice("<b>A small display on the back reads:")]</b>"
	var/timeleft = current_cooldown != TIMER_ID_NULL ? timeleft(current_cooldown) : 0
	var/loadingbar = num2loadingbar(timeleft/charge_time)
	if(charges == max_charges)
		. += span_notice("<b> All [charges] charges are ready for use!</b>")
	else
		. += span_notice("<b>[loadingbar] : [timeleft*0.1]s </b> Until the next charge.")
