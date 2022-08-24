/**
 * A highly aggressive subset of shadowlings
 */
/datum/species/shadow/nightmare
	name = "Nightmare"
	id = SPECIES_NIGHTMARE
	limbs_id = "shadow"
	burnmod = 1.5
	no_equip = list(ITEM_SLOT_MASK, ITEM_SLOT_GLOVES, ITEM_SLOT_FEET, ITEM_SLOT_ICLOTHING, ITEM_SLOT_SUITSTORE)
	species_traits = list(NOBLOOD,NO_UNDERWEAR,NO_DNA_COPY,NOTRANSSTING,NOEYESPRITES)
	inherent_traits = list(
		TRAIT_ADVANCEDTOOLUSER,
		TRAIT_CAN_STRIP,
		TRAIT_RESISTCOLD,
		TRAIT_NOBREATH,
		TRAIT_RESISTHIGHPRESSURE,
		TRAIT_RESISTLOWPRESSURE,
		TRAIT_CHUNKYFINGERS,
		TRAIT_RADIMMUNE,
		TRAIT_VIRUSIMMUNE,
		TRAIT_PIERCEIMMUNE,
		TRAIT_NODISMEMBER,
		TRAIT_NOHUNGER,
	)
	mutanteyes = /obj/item/organ/eyes/night_vision/nightmare
	mutantheart = /obj/item/organ/heart/nightmare
	mutantbrain = /obj/item/organ/brain/nightmare
	var/obj/item/clothing/suit/space/shadow/suit
	var/obj/item/clothing/head/shadow/helmet

/datum/species/shadow/nightmare/on_species_gain(mob/living/carbon/C, datum/species/old_species)
	C.unequip_everything()
	suit = new /obj/item/clothing/suit/space/shadow(C)
	C.equip_to_slot_or_del(suit, ITEM_SLOT_OCLOTHING)
	helmet = new /obj/item/clothing/head/shadow(C)
	C.equip_to_slot_or_del(helmet, ITEM_SLOT_HEAD)

	. = ..()

	C.fully_replace_character_name(null, pick(GLOB.nightmare_names))
	C.set_safe_hunger_level()
	C._LoadComponent(/datum/component/walk/shadow)

/datum/species/shadow/nightmare/on_species_loss(mob/living/carbon/C)
	. = ..()
	C.RemoveComponent(/datum/component/walk/shadow)
	qdel(suit)
	qdel(helmet)

/datum/species/shadow/nightmare/bullet_act(obj/projectile/P, mob/living/carbon/human/H)
	var/turf/T = H.loc
	if(istype(T))
		var/light_amount = T.get_lumcount()
		if(light_amount < SHADOW_SPECIES_LIGHT_THRESHOLD)
			H.visible_message(span_danger("[H] dances in the shadows, evading [P]!"))
			playsound(T, "bullet_miss", 75, TRUE)
			return BULLET_ACT_FORCE_PIERCE
	return ..()

/datum/species/shadow/nightmare/check_roundstart_eligible()
	return FALSE
