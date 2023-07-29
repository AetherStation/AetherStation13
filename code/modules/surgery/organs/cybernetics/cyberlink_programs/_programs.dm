/**
 * Programs - passive abilities
 * Protocols - active abilities
 * Is it clear?
 */

/obj/item/cyberware
	name = "generic cyberlink program"
	desc = "you should never see this."
	icon = 'icons/obj/cyberlink_programs.dmi'
	w_class = WEIGHT_CLASS_TINY
	var/tier = CYBER_CLASS_DEFAULT
	var/hidden = FALSE
	var/cost = 0

/obj/item/cyberware/examine(mob/user)
	. = ..()
	if(HAS_TRAIT(user,TRAIT_DIAGNOSTIC_HUD))
		switch(tier)
			if(CYBER_CLASS_DEFAULT)
				. += "It is a program of unknown origin."
			if(CYBER_CLASS_NT_LOW)
				. += "It is a cheaply made Nanotrasen program."
			if(CYBER_CLASS_NT_HIGH)
				. += "It is a well made Nanotrasen program."
			if(CYBER_CLASS_SYNDICATE)
				. += "It is a program clearly manufactured by one of the Syndicate factions."
			if(CYBER_CLASS_TERRA)
				. += "It is a program manufactured by the Terran government."
			if(CYBER_CLASS_CRACKED)
				. += "This program has been heavily tinkered with, it's impossible to determine it's original manufacturer."
			if(CYBER_CLASS_ADMIN)
				. += "This program was made by beings that have capabilities far beyond our current technological progress."

/obj/item/cyberware/Initialize()
	. = ..()
	switch(tier)
		if(CYBER_CLASS_NT_LOW)
			icon_state = "nt1"
		if(CYBER_CLASS_NT_HIGH)
			icon_state = "nt2"
		if(CYBER_CLASS_SYNDICATE)
			icon_state = "syndie"
		if(CYBER_CLASS_TERRA,CYBER_CLASS_ADMIN)
			icon_state = "terra"
		if(CYBER_CLASS_CRACKED, CYBER_CLASS_CRACKED_BAD, CYBER_CLASS_DEFAULT)
			icon_state = "makeshift"

/obj/item/cyberware/proc/added_to_link(obj/item/organ/cyberimp/cyberlink/link)
	return

/obj/item/cyberware/proc/removed_from_link(obj/item/organ/cyberimp/cyberlink/link)
	return

/obj/item/cyberware/proc/removed_from_mob(mob/living/carbon/user)
	return

/obj/item/cyberware/proc/added_to_mob(mob/living/carbon/user)
	return

/obj/item/cyberware/proc/program_tick(mob/living/carbon/user)
	return

/obj/item/cyberware/proc/get_stress(obj/item/organ/cyberimp/cyberlink/link)
	if(link && link.implant_class == tier)
		return cost - 1
	return cost

/obj/item/cyberware/action
	var/action_type
	var/datum/action/action

/obj/item/cyberware/action/Initialize()
	. = ..()
	action = new action_type(src)

/obj/item/cyberware/action/added_to_mob(mob/living/carbon/user)
	action.Grant(user)

/obj/item/cyberware/action/removed_from_mob(mob/living/carbon/user)
	action.Remove(user)

/obj/item/cyberware/proc_holder
	var/ability_type
	var/obj/effect/proc_holder/ability

/obj/item/cyberware/proc_holder/Initialize()
	. = ..()
	ability = new ability_type(src)

/obj/item/cyberware/proc_holder/added_to_mob(mob/living/carbon/user)
	user.mind.AddSpell(ability)

/obj/item/cyberware/proc_holder/removed_from_mob(mob/living/carbon/user)
	user.mind.RemoveSpell(ability)
