/datum/eldritch_knowledge/starting/base_ash
	name = "Nightwatcher's Secret"
	desc = "Opens up the Path of Ash to you. \
		Allows you to transmute a match and a knife into an Ashen Blade. \
		You can only create two at a time."
	gain_text = "The City Guard know their watch. If you ask them at night, they may tell you about the ashy lantern."
	next_knowledge = list(/datum/eldritch_knowledge/ashen_grasp)
	required_atoms = list(
		/obj/item/kitchen/knife = 1,
		/obj/item/match = 1
		)
	result_atoms = list(/obj/item/melee/sickly_blade/ash)
	route = PATH_ASH

/datum/eldritch_knowledge/ashen_grasp
	name = "Grasp of Ash"
	desc = "Your Mansus Grasp will burn the eyes of the victim, causing damage and blindness."
	gain_text = "The Nightwatcher was the first of them, his treason started it all. \
		Their lantern, expired to ash - their watch, absent."
	next_knowledge = list(/datum/eldritch_knowledge/spell/ashen_shift)
	cost = 1
	route = PATH_ASH

/datum/eldritch_knowledge/ashen_grasp/on_gain(mob/user)
	RegisterSignal(user, COMSIG_HERETIC_MANSUS_GRASP_ATTACK, .proc/on_mansus_grasp)

/datum/eldritch_knowledge/ashen_grasp/on_lose(mob/user)
	UnregisterSignal(user, COMSIG_HERETIC_MANSUS_GRASP_ATTACK)

/datum/eldritch_knowledge/ashen_grasp/proc/on_mansus_grasp(mob/living/source, mob/living/target)
	SIGNAL_HANDLER

	if(target.is_blind())
		return

	if(!target.getorganslot(ORGAN_SLOT_EYES))
		return

	to_chat(target, span_danger("A bright green light burns your eyes horrifically!"))
	target.adjustOrganLoss(ORGAN_SLOT_EYES, 15)
	target.blur_eyes(10)


/datum/eldritch_knowledge/spell/ashen_shift
	name = "Ashen Shift"
	desc = "Grants you Ashen Passage, a silent but short range jaunt."
	gain_text = "He knew how to walk between the planes."
	cost = 1
	spell_to_add = /obj/effect/proc_holder/spell/targeted/ethereal_jaunt/shift/ash
	next_knowledge = list(
		/datum/eldritch_knowledge/mark/ash_mark,
		/datum/eldritch_knowledge/essence,
		/datum/eldritch_knowledge/ashen_eyes
	)
	route = PATH_ASH

/datum/eldritch_knowledge/mark/ash_mark
	name = "Mark of Ash"
	desc = "Your Mansus Grasp now applies the Mark of Ash. The mark is triggered from an attack with your Ashen Blade. \
		When triggered, the victim takes additional stamina and burn damage, and the mark is transferred to any nearby heathens. \
		Damage dealt is decreased with each transfer."
	gain_text = "He was a very particular man, always watching in the dead of night. \
		But in spite of his duty, he regularly tranced through the Manse with his blazing lantern held high. \
		He shone brightly in the darkness, until the blaze begin to die."
	next_knowledge = list(/datum/eldritch_knowledge/knowledge_ritual/ash)
	route = PATH_ASH
	mark_type = /datum/status_effect/eldritch/ash

/datum/eldritch_knowledge/mark/ash_mark/trigger_mark(mob/living/source, mob/living/target)
	. = ..()
	if(!.)
		return

	// Also refunds 75% of charge!
	for(var/obj/effect/proc_holder/spell/targeted/touch/mansus_grasp/grasp in source.mind.spell_list)
		grasp.charge_counter = min(round(grasp.charge_counter + grasp.charge_max * 0.75), grasp.charge_max)

/datum/eldritch_knowledge/knowledge_ritual/ash
	next_knowledge = list(/datum/eldritch_knowledge/mad_mask)
	route = PATH_ASH

/datum/eldritch_knowledge/mad_mask
	name = "Mask of Madness"
	gain_text = "The Nightwater was lost. That's what the Watch believed. Yet he walked the world, unnoticed by the masses."
	desc = "Allows you to transmute any mask, with a candle and a pair of eyes, to create a mask of madness, It causes passive stamina damage to everyone around the wearer and hallucinations, can be forced on a non believer to make him unable to take it off..."
	cost = 1
	result_atoms = list(/obj/item/clothing/mask/void_mask)
	required_atoms = list(
		/obj/item/organ/eyes = 1,
		/obj/item/clothing/mask = 1,
		/obj/item/candle = 1
		)
	next_knowledge = list(
		/datum/eldritch_knowledge/curse/corrosion,
		/datum/eldritch_knowledge/blade_upgrade/ash,
		/datum/eldritch_knowledge/curse/paralysis
	)
	route = PATH_ASH

/datum/eldritch_knowledge/blade_upgrade/ash
	name = "Fiery Blade"
	desc = "Your blade now lights enemies ablaze on attack."
	gain_text = "He returned, blade in hand, he swung and swung as the ash fell from the skies. \
		His city, the people he swore to watch... and watch he did, as they all burnt to cinders."
	next_knowledge = list(/datum/eldritch_knowledge/spell/flame_birth)
	route = PATH_ASH

/datum/eldritch_knowledge/blade_upgrade/ash/do_melee_effects(mob/living/source, mob/living/target, obj/item/melee/sickly_blade/blade)
	if(source == target)
		return

	target.adjust_fire_stacks(1)
	target.IgniteMob()

/datum/eldritch_knowledge/spell/flame_birth
	name = "Flame Birth"
	desc = "Grants you Nightwater's Rebirth, a spell that extinguishes you and \
		burns all nearby heathens who are currently on fire, healing you for every victim afflicted. \
		If any victims afflicted are in critical condition, they will also instantly die."
	gain_text = "The fire was inescapable, and yet, life remained in his charred body. \
		The Nightwater was a particular man, always watching."
	cost = 1
	spell_to_add = /obj/effect/proc_holder/spell/targeted/fiery_rebirth
	next_knowledge = list(
		/datum/eldritch_knowledge/summon/ashy,
		/datum/eldritch_knowledge/summon/rusty,
		/datum/eldritch_knowledge/final/ash_final,
	)
	route = PATH_ASH

/datum/eldritch_knowledge/final/ash_final
	name = "Ashlord's Rite"
	gain_text = "The Watch is dead, the Nightwatcher burned with it. Yet his fire burns evermore, \
		for the Nightwater brought forth the rite to mankind! His gaze continues, as now I am one with the flames, \
		WITNESS MY ASCENSION, THE ASHY LANTERN BLAZES ONCE MORE!"
	desc = "Bring 3 corpses onto a transmutation rune, you will become immune to fire, the vacuum of space, cold and other enviromental hazards and become overall sturdier to all other damages. You will gain a spell that passively creates ring of fire around you as well ,as you will gain a powerful ability that lets you create a wave of flames all around you."
	route = PATH_ASH
	var/list/trait_list = list(
		TRAIT_RESISTHEAT,
		TRAIT_NOBREATH,
		TRAIT_RESISTCOLD,
		TRAIT_RESISTHIGHPRESSURE,
		TRAIT_RESISTLOWPRESSURE,
		TRAIT_NOFIRE
	)

/datum/eldritch_knowledge/final/ash_final/on_finished_recipe(mob/living/user, list/selected_atoms, turf/loc)
	. = ..()
	priority_announce("[generate_eldritch_text()] Fear the blaze, for the Ashlord, [user.real_name] has ascended! The flames shall consume all! [generate_eldritch_text()]","[generate_eldritch_text()]", ANNOUNCER_SPANOMALIES)
	user.mind.AddSpell(new /obj/effect/proc_holder/spell/aoe_turf/fire_cascade/big)
	user.mind.AddSpell(new /obj/effect/proc_holder/spell/targeted/fire_sworn)
	user.client?.give_award(/datum/award/achievement/misc/ash_ascension, user)
	for(var/trait in trait_list)
		ADD_TRAIT(user, trait, MAGIC_TRAIT)
