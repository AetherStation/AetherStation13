/**
 * An armblade that instantly snuffs out lights
 */
/obj/item/light_eater
	name = "light eater" //as opposed to heavy eater
	icon = 'icons/obj/changeling_items.dmi'
	icon_state = "arm_blade"
	inhand_icon_state = "arm_blade"
	force = 25
	armour_penetration = 35
	lefthand_file = 'icons/mob/inhands/antag/changeling_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/antag/changeling_righthand.dmi'
	item_flags = ABSTRACT | DROPDEL | ACID_PROOF
	w_class = WEIGHT_CLASS_HUGE
	sharpness = SHARP_EDGED
	tool_behaviour = TOOL_MINING
	hitsound = 'sound/weapons/bladeslice.ogg'
	wound_bonus = -30
	bare_wound_bonus = 20

/obj/item/light_eater/Initialize()
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, HAND_REPLACEMENT_TRAIT)
	AddComponent(/datum/component/butchering, 80, 70)
	AddComponent(/datum/component/light_eater)

/obj/item/clothing/suit/space/shadow
	name = "chitin shell"
	desc = "A dark, semi-transparent shell. Protects against vacuum, but not against the light of the stars." //Still takes damage from spacewalking but is immune to space itself
	icon = 'icons/obj/clothing/suits.dmi'
	worn_icon = 'icons/obj/clothing/suits.dmi'
	icon_state = "sl_shell"
	worn_icon_state = "sl_shell"
	body_parts_covered = FULL_BODY
	cold_protection = FULL_BODY
	min_cold_protection_temperature = SPACE_SUIT_MIN_TEMP_PROTECT
	flags_inv = HIDEGLOVES | HIDESHOES | HIDEJUMPSUIT
	slowdown = 0
	heat_protection = null
	max_heat_protection_temperature = null
	armor = list("melee" = 30, "bullet" = 30, "laser" = 0, "energy" = 0, "bomb" = 25, "bio" = 100, "rad" = 100)
	item_flags = ABSTRACT | DROPDEL
	clothing_flags = THICKMATERIAL | STOPSPRESSUREDAMAGE
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF

/obj/item/clothing/suit/space/shadow/Initialize()
	.=..()
	ADD_TRAIT(src, TRAIT_NODROP, ABSTRACT_ITEM_TRAIT)

/obj/item/clothing/head/shadow
	name = "chitin helm"
	desc = "A helmet-like enclosure of the head."
	icon = 'icons/obj/clothing/suits.dmi'
	worn_icon = 'icons/obj/clothing/suits.dmi'
	icon_state = "sl_head"
	worn_icon_state = "sl_head"
	cold_protection = HEAD
	min_cold_protection_temperature = SPACE_HELM_MIN_TEMP_PROTECT
	heat_protection = HEAD
	max_heat_protection_temperature = SPACE_HELM_MAX_TEMP_PROTECT
	armor = list("melee" = 30, "bullet" = 30, "laser" = 0, "energy" = 0, "bomb" = 25, "bio" = 100, "rad" = 100)
	clothing_flags = STOPSPRESSUREDAMAGE
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	item_flags = ABSTRACT | DROPDEL

/obj/item/clothing/head/shadow/Initialize()
	.=..()
	ADD_TRAIT(src, TRAIT_NODROP, ABSTRACT_ITEM_TRAIT) 
