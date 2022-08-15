/obj/item/card_access_chip
	name = "\improper AA-chip"
	desc = "Additional Access chip, used to add access to ID cards."
	icon = 'icons/obj/card.dmi'
	icon_state = "aachip"

	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 100, ACID = 100)
	resistance_flags = FIRE_PROOF | ACID_PROOF
	var/list/access = list()
	// The following are only used for writing new chips.
	var/rewritable = FALSE
	var/access_tier = 0
	var/access_count_max = 0

/obj/item/card_access_chip/proc/apply_access(obj/item/card/id/id)
	// this is += instead of |= because chips could share accesses.
	id.additional_access += access

/obj/item/card_access_chip/proc/remove_access(obj/item/card/id/id)
	id.additional_access -= access

/obj/item/card_access_chip/roundstart
	icon_state = "aachip-roundstart"
	var/assignment = ""

/obj/item/card_access_chip/roundstart/Initialize(mapload, _assignment)
	. = ..()
	assignment = _assignment
	name = "[_assignment] AA-chip"

/obj/item/card_access_chip/mining
	name = "mining access chip"
	icon_state = "aachip-cargo"
	access = list(ACCESS_MAILSORTING, ACCESS_MECH_MINING, ACCESS_MINERAL_STOREROOM, ACCESS_MINING, ACCESS_MINING_STATION)

/obj/item/card_access_chip/rewritable
	desc = "Rewritable additional access chip, used to add access to ID cards."
	icon_state = "aachip-printed"
	obj_flags = UNIQUE_RENAME
	rewritable = TRUE
	access_tier = 3
	access_count_max = 3

/obj/item/card_access_chip/rewritable/tier4
	icon_state = "aachip-silver"
	access_tier = 4
