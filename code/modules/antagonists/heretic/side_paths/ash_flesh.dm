/datum/eldritch_knowledge/ashen_eyes
	name = "Ashen Eyes"
	gain_text = "Piercing eyes, guide me through the mundane."
	desc = "Allows you to craft thermal vision amulet by transmutating eyes with a glass shard."
	cost = 1
	next_knowledge = list(
		/datum/eldritch_knowledge/spell/ashen_shift,
		/datum/eldritch_knowledge/limited_amount/flesh_ghoul
		)
	required_atoms = list(
		/obj/item/organ/eyes = 1,
		/obj/item/shard = 1)
	result_atoms = list(/obj/item/clothing/neck/eldritch_amulet)
	route = PATH_SIDE

/datum/eldritch_knowledge/curse/paralysis
	name = "Curse of Paralysis"
	gain_text = "Corrupt their flesh, make them bleed."
	desc = "Curse someone for 5 minutes of inability to walk. Sacrifice a knife, a pool of blood, a pair of legs, a hatchet and an item that the victim touched with their bare hands. "
	cost = 1
	required_atoms = list(
		/obj/item/bodypart/l_leg = 1,
		/obj/item/bodypart/r_leg = 1,
		/obj/item/hatchet = 1
		)
	next_knowledge = list(/datum/eldritch_knowledge/mad_mask,/datum/eldritch_knowledge/summon/raw_prophet)
	timer = 5 MINUTES
	route = PATH_SIDE

/datum/eldritch_knowledge/curse/paralysis/curse(mob/living/chosen_mob)
	. = ..()
	ADD_TRAIT(chosen_mob,TRAIT_PARALYSIS_L_LEG,MAGIC_TRAIT)
	ADD_TRAIT(chosen_mob,TRAIT_PARALYSIS_R_LEG,MAGIC_TRAIT)


/datum/eldritch_knowledge/curse/paralysis/uncurse(mob/living/chosen_mob)
	. = ..()
	REMOVE_TRAIT(chosen_mob,TRAIT_PARALYSIS_L_LEG,MAGIC_TRAIT)
	REMOVE_TRAIT(chosen_mob,TRAIT_PARALYSIS_R_LEG,MAGIC_TRAIT)

/datum/eldritch_knowledge/summon/ashy
	name = "Ashen Ritual"
	gain_text = "I combined my principle of hunger with my desire for destruction. And the Nightwatcher knew my name."
	desc = "You can now summon an Ash Man by transmutating a pile of ash, a head and a book."
	cost = 1
	required_atoms = list(
		/obj/effect/decal/cleanable/ash = 1,
		/obj/item/bodypart/head = 1,
		/obj/item/book = 1
		)
	mob_to_summon = /mob/living/simple_animal/hostile/eldritch/ash_spirit
	next_knowledge = list(/datum/eldritch_knowledge/summon/stalker,/datum/eldritch_knowledge/spell/flame_birth)
	route = PATH_SIDE

/datum/eldritch_knowledge/summon/ashy/cleanup_atoms(list/selected_atoms)
	var/obj/item/bodypart/head/ritual_head = locate() in selected_atoms
	if(!ritual_head)
		CRASH("[type] required a head bodypart, yet did not have one in selected_atoms when it reached cleanup_atoms.")

	// Spill out any brains or stuff before we delete it.
	ritual_head.drop_organs()
	return ..()
