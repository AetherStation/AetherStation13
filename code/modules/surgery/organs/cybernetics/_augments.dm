/obj/item/organ/cyberimp
	name = "cybernetic implant"
	desc = "A state-of-the-art implant that improves a baseline's functionality."
	status = ORGAN_ROBOTIC
	organ_flags = ORGAN_SYNTHETIC
	var/hacked = FALSE
	var/implant_color = "#FFFFFF"
	var/implant_overlay
	var/syndicate_implant = FALSE //Makes the implant invisible to health analyzers and medical HUDs.

	var/implant_class = CYBER_CLASS_DEFAULT

/obj/item/organ/cyberimp/examine(mob/user)
	. = ..()
	if(hacked)
		. += "It seems to have been tinkered with."
	if(HAS_TRAIT(user,TRAIT_DIAGNOSTIC_HUD))
		switch(implant_class)
			if(CYBER_CLASS_DEFAULT)
				. += "It is an implant of unknown origin."
			if(CYBER_CLASS_NT_LOW)
				. += "It is a cheaply made Nanotrasen implant."
			if(CYBER_CLASS_NT_HIGH)
				. += "It is a well made Nanotrasen implant."
			if(CYBER_CLASS_SYNDICATE)
				. += "It is an implant clearly manufactured by one of the Syndicate factions."
			if(CYBER_CLASS_TERRA)
				. += "It is an implant manufactured by the Terran government."
			if(CYBER_CLASS_CRACKED)
				. += "This implant has been heavily tinkered with, it's impossible to determine it's original manufacturer."
			if(CYBER_CLASS_ADMIN)
				. += "This implant was made by beings that have capabilities far beyond our current technological progress."

/obj/item/organ/cyberimp/emp_act(severity)
	. = ..()
	if(severity == EMP_HEAVY && prob(5))
		owner.getlink()?.throw_error(6)
		implant_class = CYBER_CLASS_CRACKED
	else
		owner.getlink()?.throw_error(5)

/obj/item/organ/cyberimp/New(mob/M = null)
	if(iscarbon(M))
		src.Insert(M)
	if(implant_overlay)
		var/mutable_appearance/overlay = mutable_appearance(icon, implant_overlay)
		overlay.color = implant_color
		add_overlay(overlay)
	return ..()

/obj/item/organ/cyberimp/proc/get_stress( obj/item/organ/cyberimp/cyberlink/link = null)
	if(link && link.implant_class == implant_class)
		return max(0,GLOB.implant_class_tiers[implant_class] - 1)
	return GLOB.implant_class_tiers
