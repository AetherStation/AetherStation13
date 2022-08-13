/obj/item/clothing/head/hooded/cult_hoodie/eldritch
	name = "ominous hood"
	icon_state = "eldritch"
	desc = "A torn, dust-caked hood. Strange eyes line the inside."
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDEHAIR|HIDEFACIALHAIR|HIDESNOUT
	flags_cover = HEADCOVERSEYES | HEADCOVERSMOUTH | PEPPERPROOF
	flash_protect = FLASH_PROTECTION_WELDER

/obj/item/clothing/suit/hooded/cultrobes/eldritch
	name = "ominous armor"
	desc = "A ragged, dusty set of robes. Strange eyes line the inside."
	icon_state = "eldritch_armor"
	inhand_icon_state = "eldritch_armor"
	flags_inv = HIDESHOES|HIDEJUMPSUIT
	body_parts_covered = CHEST|GROIN|LEGS|FEET|ARMS
	allowed = list(/obj/item/melee/sickly_blade, /obj/item/forbidden_book)
	hoodtype = /obj/item/clothing/head/hooded/cult_hoodie/eldritch
	// slightly better than normal cult robes
	armor = list(MELEE = 50, BULLET = 50, LASER = 50,ENERGY = 50, BOMB = 35, BIO = 20, RAD = 0, FIRE = 20, ACID = 20)

/obj/item/clothing/head/hooded/cult_hoodie/void
	name = "void hood"
	icon_state = "void_cloak"
	flags_inv = NONE
	flags_cover = NONE
	desc = "Black like tar, doesn't reflect any light. Runic symbols line the outside, with each flash you loose comprehension of what you are seeing."
	item_flags = EXAMINE_SKIP
	armor = list(MELEE = 30, BULLET = 30, LASER = 30,ENERGY = 30, BOMB = 15, BIO = 0, RAD = 0, FIRE = 0, ACID = 0)

/obj/item/clothing/suit/hooded/cultrobes/void
	name = "void cloak"
	desc = "Black like tar, doesn't reflect any light. Runic symbols line the outside, with each flash you loose comprehension of what you are seeing."
	icon_state = "void_cloak"
	inhand_icon_state = "void_cloak"
	allowed = list(/obj/item/melee/sickly_blade, /obj/item/forbidden_book)
	hoodtype = /obj/item/clothing/head/hooded/cult_hoodie/void
	flags_inv = NONE
	// slightly worse than normal cult robes
	armor = list(MELEE = 30, BULLET = 30, LASER = 30,ENERGY = 30, BOMB = 15, BIO = 0, RAD = 0, FIRE = 0, ACID = 0)
	pocket_storage_component_path = /datum/component/storage/concrete/pockets/void_cloak
	alternative_mode = TRUE

/obj/item/clothing/suit/hooded/cultrobes/void/RemoveHood()
	var/mob/living/carbon/carbon_user = loc
	to_chat(carbon_user,span_notice("The kaleidoscope of colours collapses around you, as the cloak shifts to visibility!"))
	item_flags &= ~EXAMINE_SKIP
	return ..()

/obj/item/clothing/suit/hooded/cultrobes/void/MakeHood()
	if(!iscarbon(loc))
		CRASH("[src] attempted to make a hood on a non-carbon thing: [loc]")

	var/mob/living/carbon/carbon_user = loc
	if(IS_HERETIC_OR_MONSTER(carbon_user))
		. = ..()
		to_chat(carbon_user,span_notice("The light shifts around you making the cloak invisible!"))
		item_flags |= EXAMINE_SKIP
		return

	to_chat(carbon_user,span_danger("You can't force the hood onto your head!"))
