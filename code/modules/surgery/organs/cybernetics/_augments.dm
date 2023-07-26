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
		to_chat(owner,"<span class = 'danger'> cyberlink beeps: ERR03 HEAVY ELECTROMAGNETIC MALFUNCTION DETECTED IN [uppertext(name)].DAMAGE DETECTED, INTERNAL MEMORY DAMAGED. </span>")
		implant_class = CYBER_CLASS_CRACKED
	else
		to_chat(owner,"<span class = 'danger'> cyberlink beeps: ERR02 ELECTROMAGNETIC MALFUNCTION DETECTED IN [uppertext(name)] </span>")


/obj/item/organ/cyberimp/New(mob/M = null)
	if(iscarbon(M))
		src.Insert(M)
	if(implant_overlay)
		var/mutable_appearance/overlay = mutable_appearance(icon, implant_overlay)
		overlay.color = implant_color
		add_overlay(overlay)
	return ..()

/obj/item/organ/cyberimp/proc/get_stress( obj/item/organ/cyberimp/cyberlink/link = null)
	if(link?.implant_class == implant_class)
		return max(0,GLOB.implant_class_tiers[implant_class] - 1)
	return GLOB.implant_class_tiers

/obj/item/organ/cyberimp/cyberlink
	name = "cybernetic brain link"
	desc = "Manages the cybernetic allowing the body to handle more cybernetics before the stress they put on the nervous system causes a total mental collapse."
	icon_state = "brain_implant"
	implant_overlay = "brain_implant_overlay"
	slot = ORGAN_SLOT_LINK
	zone = BODY_ZONE_HEAD
	w_class = WEIGHT_CLASS_TINY
	actions_types = list(/datum/action/item_action/organ_action/cyberlink_program)

	var/implant_stress_reduction = 0
	var/cyberlink_attack = 0
	var/cyberlink_defense = 0


	var/list/programs = list()
	var/programs_max_size = 1

/obj/item/organ/cyberimp/cyberlink/Initialize()
	. = ..()
	AddComponent(/datum/component/storage/concrete/cyberlink,null,programs_max_size)

/obj/item/organ/cyberimp/cyberlink/ui_action_click(mob/user, actiontype)
	SEND_SIGNAL(src, COMSIG_TRY_STORAGE_SHOW, user, TRUE)

/obj/item/organ/cyberimp/cyberlink/proc/can_overpower(obj/item/organ/cyberimp/cyberlink/other)
	if(!other)
		return TRUE
	if(cyberlink_attack == other.cyberlink_defense)
		return prob(50)
	return cyberlink_attack > other.cyberlink_defense

/obj/item/organ/cyberimp/cyberlink/proc/throw_error(err_code)
	switch(err_code)
		if(1)
			to_chat(owner,"<span class='warning'>Cyberlink beeps: CODE01 - SOME NEURAL STRESS DETECTED. INCREASE NEURAL STRESS RECOVERY CAPABILITIES.</span>")
		if(2)
			to_chat(owner,"<span class='warning'>Cyberlink beeps: CODE02 - NEURAL STRESS DETECTED. REFRAIN FROM FURTHER UPGRADING YOUR IMPLANTS AND CONSIDER VISITING A ROBOTICS LABORATORY.</span>")
		if(3)
			to_chat(owner,"<span class='warning'>Cyberlink beeps: CODE03 - NEURAL SYSTEM UNDER TOO MUCH STRESS. VISIT A ROBOTICIST FOR A MAINTENANCE CHECK.</span>")
		if(4)
			to_chat(owner,"<span class='danger'>Cyberlink beeps: CODE04 - NEURAL SYSTEM UNDER TOO MUCH STRESS. NEUROLOGICAL COLLAPSE IMMINENT.</span>")
		if(5)
			to_chat(owner,"<span class = 'danger'>Cyberlink beeps: CODE05 - ELECTROMAGNETIC MALFUNCTION DETECTED </span>")
		if(6)
			to_chat(owner,"<span class = 'danger'>Cyberlink beeps: CODE06 - HEAVY ELECTROMAGNETIC MALFUNCTION DETECTED. DAMAGE TO THE IMPLANTS MAY HAVE OCCURED. </span>")
		if(7)
			to_chat(owner,"<span class='warning'>Cyberlink beeps: CODE07 - UNAUTHORIZED ACCESS DETECTED.</span>")
		if(8)
			to_chat(owner,"<span class='warning'>Cyberlink beeps: CODE08 - UNAUTHORIZED ACCESS DENIED.</span>")

/obj/item/organ/cyberimp/cyberlink/proc/insert_program(obj/item/cyberlink_program/program)
	programs += program
	program.added_to_link(src)
	program.added_to_mob(owner)
	return

/obj/item/organ/cyberimp/cyberlink/proc/eject_program(obj/item/cyberlink_program/program)
	program.removed_from_mob(owner)
	program.removed_from_link(src)
	programs -= program
	return

/obj/item/organ/cyberimp/cyberlink/proc/add_programs_to(mob/user)
	for(var/obj/item/cyberlink_program/program as anything in programs)
		program.added_to_mob(user)
	return

/obj/item/organ/cyberimp/cyberlink/proc/remove_programs_from(mob/user)
	for(var/obj/item/cyberlink_program/program as anything in programs)
		program.removed_from_mob(user)
	return

/obj/item/organ/cyberimp/cyberlink/proc/update_programs()
	return

//Happens in Life() so about every 2 seconds
/obj/item/organ/cyberimp/cyberlink/proc/programs_tick()
	for(var/obj/item/cyberlink_program/program as anything in programs)
		program.program_tick(owner)
/*
	1 - caster can overpower
	0 - victim is stronger
	-1 - either the caster or the victim doesnt have a cyberlink

*/
/proc/cyberlink_overpower_check(mob/living/carbon/human/caster, mob/living/carbon/human/victim)
	var/obj/item/organ/cyberimp/cyberlink/attacker = caster.getorganslot(ORGAN_SLOT_LINK)
	var/obj/item/organ/cyberimp/cyberlink/defender = victim.getorganslot(ORGAN_SLOT_LINK)
	if(!attacker || !defender)
		return -1
	return attacker.can_overpower(defender)

/obj/item/organ/cyberimp/cyberlink/nt_low
	name = "NT Cyberlink 1.0"
	implant_class = CYBER_CLASS_NT_LOW
	implant_stress_reduction = 0

/obj/item/organ/cyberimp/cyberlink/nt_high
	name = "NT Cyberlink 2.0"
	implant_class = CYBER_CLASS_NT_HIGH
	implant_stress_reduction = 1

/obj/item/organ/cyberimp/cyberlink/terragov
	name = "Terran Cyberware System"
	implant_class = CYBER_CLASS_TERRA
	implant_stress_reduction = 6

/obj/item/organ/cyberimp/cyberlink/syndicate
	name = "Cybersun Cybernetic Control System"
	implant_class = CYBER_CLASS_SYNDICATE
	implant_stress_reduction = 5
	syndicate_implant = TRUE

/obj/item/organ/cyberimp/cyberlink/admin
	name = "G.O.D. Cybernetics System"
	implant_class = CYBER_CLASS_ADMIN
	implant_stress_reduction = INFINITY

/obj/item/organ/cyberimp/cyberlink/cracked
	name = "custom cyberlink"
	implant_class = CYBER_CLASS_CRACKED

/obj/item/organ/cyberimp/cyberlink/cracked/Initialize(mob/living/creator)
	. = ..()
	if(!creator || !creator.mind)
		var/quality = pick_weight(list(CYBERLINK_QUALITY_SHODDY = 2,CYBERLINK_QUALITY_SHODDY = 3, CYBERLINK_QUALITY_DECENT = 7, CYBERLINK_QUALITY_GOOD = 5, CYBERLINK_QUALITY_EXCELLENT = 2, CYBERLINK_QUALITY_MASTERWORK = 1))
		set_quality(quality)
	else
		set_quality(creator.mind.get_skill_modifier(/datum/skill/implant_hacking, SKILL_CYBERLINK_QUALITY_MODIFIER))

/* Quality:
	shoddy -> -1 implant_stress_reduction
	poor -> 0 implant_stress_reduction
	decent -> 1 implant_stress_reduction
	good -> 2 implant_stres_reduction
	excellent -> 4 implant_stress_reduction
	masterwork -> 5 implant_stress_reduction
	legendary -> 7 implant_stress_reduction
*/
/obj/item/organ/cyberimp/cyberlink/cracked/proc/set_quality(quality)
	switch(quality)
		if(CYBERLINK_QUALITY_SHODDY)
			name = "shoddy custom-made cyberlink"
			implant_stress_reduction = -1
		if(CYBERLINK_QUALITY_POOR)
			name = "poor custom-made cyberlink"
			implant_stress_reduction = 0
		if(CYBERLINK_QUALITY_DECENT)
			name = "decent custom-made cyberlink"
			implant_stress_reduction = 1
		if(CYBERLINK_QUALITY_GOOD)
			name = "good custom-made cyberlink"
			implant_stress_reduction = 2
		if(CYBERLINK_QUALITY_EXCELLENT)
			name = "excellent custom-made cyberlink"
			implant_stress_reduction = 4
		if(CYBERLINK_QUALITY_MASTERWORK)
			name = "masterwork custom-made cyberlink"
			implant_stress_reduction = 5
		if(CYBERLINK_QUALITY_LEGENDARY)
			name = "legendary custom-made cyberlink"
			implant_stress_reduction = 7

/obj/item/autosurgeon/organ/cyberlink_nt_low
	starting_organ = /obj/item/organ/cyberimp/cyberlink/nt_low
	uses = 1

/obj/item/autosurgeon/organ/cyberlink_nt_high
	starting_organ = /obj/item/organ/cyberimp/cyberlink/nt_high
	uses = 1

/obj/item/autosurgeon/organ/cyberlink_terragov
	starting_organ = /obj/item/organ/cyberimp/cyberlink/terragov
	uses = 1

/obj/item/autosurgeon/organ/cyberlink_syndicate
	starting_organ = /obj/item/organ/cyberimp/cyberlink/syndicate
	uses = 1

/obj/item/autosurgeon/organ/cyberlink_admin
	starting_organ = /obj/item/organ/cyberimp/cyberlink/admin
	uses = 1


/obj/item/debug_vitruvian
	name = "Debug vitruvian"
	icon = 'icons/obj/surgery.dmi'
	icon_state = "brain_implant"

/obj/item/debug_vitruvian/attack_hand(mob/user)
	. = ..()

/obj/item/debug_vitruvian/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "VitruvianTesting", name)
		ui.open()

/obj/item/debug_vitruvian/ui_assets(mob/user)
	return list(
		get_asset_datum(/datum/asset/simple/vitruvian),
	)


