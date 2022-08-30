//Programs that buff the host in generally passive ways.

/datum/nanite_program/nervous
	name = "Nerve Support"
	desc = "The nanites absorb excess strain on the nervous system, allowing the host to resist incapacitating attacks."
	use_rate = 1.5
	rogue_types = list(/datum/nanite_program/nerve_decay)

/datum/nanite_program/nervous/enable_passive_effect()
	. = ..()
	if(ishuman(host_mob))
		var/mob/living/carbon/human/H = host_mob
		H.physiology.stun_mod *= 0.5
		H.physiology.stamina_mod *= 0.5

/datum/nanite_program/nervous/disable_passive_effect()
	. = ..()
	if(ishuman(host_mob))
		var/mob/living/carbon/human/H = host_mob
		H.physiology.stun_mod *= 2
		H.physiology.stamina_mod *= 2

/datum/nanite_program/hardening
	name = "Dermal Hardening"
	desc = "The nanites form a mesh under the host's skin, protecting them from melee and bullet impacts."
	use_rate = 0.5
	rogue_types = list(/datum/nanite_program/skin_decay)

//TODO on_hit effect that turns skin grey for a moment

/datum/nanite_program/hardening/enable_passive_effect()
	. = ..()
	if(ishuman(host_mob))
		var/mob/living/carbon/human/H = host_mob
		H.physiology.armor.melee += 25
		H.physiology.armor.bullet += 20

/datum/nanite_program/hardening/disable_passive_effect()
	. = ..()
	if(ishuman(host_mob))
		var/mob/living/carbon/human/H = host_mob
		H.physiology.armor.melee -= 25
		H.physiology.armor.bullet -= 20

/datum/nanite_program/refractive
	name = "Dermal Refractive Surface"
	desc = "The nanites form a membrane above the host's skin, reducing the effect of laser and energy impacts."
	use_rate = 0.50
	rogue_types = list(/datum/nanite_program/skin_decay)

/datum/nanite_program/refractive/enable_passive_effect()
	. = ..()
	if(ishuman(host_mob))
		var/mob/living/carbon/human/H = host_mob
		H.physiology.armor.laser += 25
		H.physiology.armor.energy += 20

/datum/nanite_program/refractive/disable_passive_effect()
	. = ..()
	if(ishuman(host_mob))
		var/mob/living/carbon/human/H = host_mob
		H.physiology.armor.laser -= 25
		H.physiology.armor.energy -= 20

/datum/nanite_program/coagulating
	name = "Vein Repressurization"
	desc = "The nanites re-route circulating blood away from open wounds, dramatically reducing bleeding rate."
	use_rate = 0.20
	rogue_types = list(/datum/nanite_program/suffocating)

/datum/nanite_program/coagulating/enable_passive_effect()
	. = ..()
	if(ishuman(host_mob))
		var/mob/living/carbon/human/H = host_mob
		H.physiology.bleed_mod *= 0.5

/datum/nanite_program/coagulating/disable_passive_effect()
	. = ..()
	if(ishuman(host_mob))
		var/mob/living/carbon/human/H = host_mob
		H.physiology.bleed_mod *= 2

/datum/nanite_program/conductive
	name = "Electric Conduction"
	desc = "The nanites act as a grounding rod for electric shocks, protecting the host. Shocks can still damage the nanites themselves."
	use_rate = 0.20
	program_flags = NANITE_SHOCK_IMMUNE
	rogue_types = list(/datum/nanite_program/nerve_decay)

/datum/nanite_program/conductive/enable_passive_effect()
	. = ..()
	ADD_TRAIT(host_mob, TRAIT_SHOCKIMMUNE, NANITES_TRAIT)

/datum/nanite_program/conductive/disable_passive_effect()
	. = ..()
	REMOVE_TRAIT(host_mob, TRAIT_SHOCKIMMUNE, NANITES_TRAIT)

/datum/nanite_program/mindshield
	name = "Mental Barrier"
	desc = "The nanites form a protective membrane around the host's brain, shielding them from abnormal influences while they're active."
	use_rate = 0.40
	rogue_types = list(/datum/nanite_program/brain_decay, /datum/nanite_program/brain_misfire)

/datum/nanite_program/mindshield/enable_passive_effect()
	. = ..()
	if(!host_mob.mind.has_antag_datum(/datum/antagonist/rev, TRUE)) //won't work if on a rev, to avoid having implanted revs.
		ADD_TRAIT(host_mob, TRAIT_MINDSHIELD, NANITES_TRAIT)
		host_mob.sec_hud_set_implants()

/datum/nanite_program/mindshield/disable_passive_effect()
	. = ..()
	REMOVE_TRAIT(host_mob, TRAIT_MINDSHIELD, NANITES_TRAIT)
	host_mob.sec_hud_set_implants()


/datum/nanite_program/senators_law
	name = "Senator's Law"
	desc = "placeholder"
	use_rate = 0
	rogue_types = list(/datum/nanite_program/nerve_decay)
	var/datum/martial_art/senators_law/senators_law

/datum/nanite_program/senators_law/enable_passive_effect()
	. = ..()
	if(iscarbon(host_mob))
		senators_law = new(null)
		var/activated = span_spider("S.E.N.A.T.O.R. FIRMWARE ACTIVATED.")
		to_chat(host_mob, activated)
		senators_law.teach(host_mob)

/datum/nanite_program/senators_law/disable_passive_effect()
	. = ..()
	if(senators_law.SENATOR_STAGE2)
		deltimer(senators_law.timer_punish)
		senators_law.punishment(host_mob)
	if(iscarbon(host_mob))
		var/deactivated = span_spider("S.E.N.A.T.O.R. FIRMWARE DEACTIVATED.")
		to_chat(host_mob, deactivated)
		senators_law.remove(host_mob)
		QDEL_NULL(senators_law)
