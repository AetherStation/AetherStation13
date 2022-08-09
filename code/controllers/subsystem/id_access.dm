/**
 * Non-processing subsystem that holds various procs and data structures to manage ID cards, trims and access.
 */
SUBSYSTEM_DEF(id_access)
	name = "IDs and Access"
	init_order = INIT_ORDER_IDACCESS
	flags = SS_NO_FIRE

	/// Dictionary of access tiers.
	var/list/tiers_by_access = list()
	/// Dictionary of access lists.
	var/list/accesses_by_tier
	/// Dictionary of access names. Keys are access levels. Values are their associated names.
	var/list/name_by_access
	var/list/accesses_by_region
	var/list/tgui_access_list
	/// Maps head access to their respective department, used in the ID console.
	var/list/access_to_department_map
	var/list/card_access_instances
	// this is slightly awful
	var/list/card_access_assignable = list()

/datum/controller/subsystem/id_access/Initialize(timeofday)
	accesses_by_tier = setup_access_tiers()
	name_by_access = setup_access_names()
	accesses_by_region = setup_access_regions()
	card_access_instances = setup_card_access()
	tgui_access_list = setup_tgui_list()
	access_to_department_map = setup_access_to_department_map()

	return ..()

/datum/controller/subsystem/id_access/proc/setup_card_access()
	. = list()
	for (var/p in subtypesof(/datum/card_access))
		var/datum/card_access/A = new p()
		.[p] = A
		// this is slightly more awful
		if (A.flags & CARD_ACCESS_ASSIGNABLE && A.assignment)
			card_access_assignable += A

/datum/controller/subsystem/id_access/proc/setup_access_regions()
	. = list()
	.[REGION_GENERAL] = REGION_ACCESS_GENERAL
	.[REGION_SECURITY] = REGION_ACCESS_SECURITY
	.[REGION_MEDBAY] = REGION_ACCESS_MEDBAY
	.[REGION_RESEARCH] = REGION_ACCESS_RESEARCH
	.[REGION_ENGINEERING] = REGION_ACCESS_ENGINEERING
	.[REGION_SUPPLY] = REGION_ACCESS_SUPPLY
	.[REGION_COMMAND] = REGION_ACCESS_COMMAND
	.[REGION_CENTCOM] = REGION_ACCESS_CENTCOM
	.[REGION_SYNDICATE] = REGION_ACCESS_SYNDICATE
	.[REGION_STATION] = REGION_ACCESS_STATION
	.[REGION_GLOBAL] = REGION_ACCESS_GLOBAL

/datum/controller/subsystem/id_access/proc/setup_access_to_department_map()
	. = list()
	.["[ACCESS_CE]"] = list(REGION_ENGINEERING)
	.["[ACCESS_CMO]"] = list(REGION_MEDBAY)
	.["[ACCESS_HOP]"] = list(REGION_GENERAL, REGION_SUPPLY)
	.["[ACCESS_HOS]"] = list(REGION_SECURITY)
	.["[ACCESS_RD]"] = list(REGION_RESEARCH)
	.["[ACCESS_CAPTAIN]"] = list(REGION_COMMAND)

/// Build access flag lists.
/datum/controller/subsystem/id_access/proc/setup_access_tiers()
	. = list()
	.["[ACCESS_TIER_1]"] = TIER_1_ACCESS
	.["[ACCESS_TIER_2]"] = TIER_2_ACCESS
	.["[ACCESS_TIER_3]"] = TIER_3_ACCESS
	.["[ACCESS_TIER_4]"] = TIER_4_ACCESS
	.["[ACCESS_TIER_5]"] = TIER_5_ACCESS
	.["[ACCESS_TIER_6]"] = TIER_6_ACCESS
	for (var/t in .)
		for (var/a in .[t])
			tiers_by_access["[a]"] = t

/// Setup dictionary that converts access levels to text names.
/datum/controller/subsystem/id_access/proc/setup_access_names()
	. = list()
	.["[ACCESS_CARGO]"] = "Cargo Bay"
	.["[ACCESS_SECURITY]"] = "Security"
	.["[ACCESS_BRIG]"] = "Holding Cells"
	.["[ACCESS_COURT]"] = "Courtroom"
	.["[ACCESS_FORENSICS_LOCKERS]"] = "Forensics"
	.["[ACCESS_MEDICAL]"] = "Medical"
	.["[ACCESS_GENETICS]"] = "Genetics Lab"
	.["[ACCESS_MORGUE]"] = "Morgue"
	.["[ACCESS_RND]"] = "R&D Lab"
	.["[ACCESS_TOXINS]"] = "Toxins Lab"
	.["[ACCESS_TOXINS_STORAGE]"] = "Toxins Storage"
	.["[ACCESS_CHEMISTRY]"] = "Chemistry Lab"
	.["[ACCESS_RD]"] = "RD Office"
	.["[ACCESS_BAR]"] = "Bar"
	.["[ACCESS_JANITOR]"] = "Custodial Closet"
	.["[ACCESS_ENGINE]"] = "Engineering"
	.["[ACCESS_ENGINE_EQUIP]"] = "Power and Engineering Equipment"
	.["[ACCESS_MAINT_TUNNELS]"] = "Maintenance"
	.["[ACCESS_EXTERNAL_AIRLOCKS]"] = "External Airlocks"
	.["[ACCESS_CHANGE_IDS]"] = "ID Console"
	.["[ACCESS_AI_UPLOAD]"] = "AI Chambers"
	.["[ACCESS_TELEPORTER]"] = "Teleporter"
	.["[ACCESS_EVA]"] = "EVA"
	.["[ACCESS_HEADS]"] = "Bridge"
	.["[ACCESS_CAPTAIN]"] = "Captain"
	.["[ACCESS_ALL_PERSONAL_LOCKERS]"] = "Personal Lockers"
	.["[ACCESS_CHAPEL_OFFICE]"] = "Chapel Office"
	.["[ACCESS_TECH_STORAGE]"] = "Technical Storage"
	.["[ACCESS_ATMOSPHERICS]"] = "Atmospherics"
	.["[ACCESS_CREMATORIUM]"] = "Crematorium"
	.["[ACCESS_ARMORY]"] = "Armory"
	.["[ACCESS_CONSTRUCTION]"] = "Construction"
	.["[ACCESS_KITCHEN]"] = "Kitchen"
	.["[ACCESS_HYDROPONICS]"] = "Hydroponics"
	.["[ACCESS_LIBRARY]"] = "Library"
	.["[ACCESS_LAWYER]"] = "Law Office"
	.["[ACCESS_ROBOTICS]"] = "Robotics"
	.["[ACCESS_VIROLOGY]"] = "Virology"
	.["[ACCESS_PSYCHOLOGY]"] = "Psychology"
	.["[ACCESS_CMO]"] = "CMO Office"
	.["[ACCESS_QM]"] = "Quartermaster"
	.["[ACCESS_SURGERY]"] = "Surgery"
	.["[ACCESS_THEATRE]"] = "Theatre"
	.["[ACCESS_RESEARCH]"] = "Science"
	.["[ACCESS_MINING]"] = "Mining"
	.["[ACCESS_MAILSORTING]"] = "Cargo Office"
	.["[ACCESS_VAULT]"] = "Main Vault"
	.["[ACCESS_MINING_STATION]"] = "Mining EVA"
	.["[ACCESS_XENOBIOLOGY]"] = "Xenobiology Lab"
	.["[ACCESS_HOP]"] = "HoP Office"
	.["[ACCESS_HOS]"] = "HoS Office"
	.["[ACCESS_CE]"] = "CE Office"
	.["[ACCESS_PHARMACY]"] = "Pharmacy"
	.["[ACCESS_RC_ANNOUNCE]"] = "RC Announcements"
	.["[ACCESS_KEYCARD_AUTH]"] = "Keycode Auth."
	.["[ACCESS_TCOMSAT]"] = "Telecommunications"
	.["[ACCESS_GATEWAY]"] = "Gateway"
	.["[ACCESS_SEC_DOORS]"] = "Brig"
	.["[ACCESS_MINERAL_STOREROOM]"] = "Mineral Storage"
	.["[ACCESS_MINISAT]"] = "AI Satellite"
	.["[ACCESS_WEAPONS]"] = "Weapon Permit"
	.["[ACCESS_NETWORK]"] = "Network Access"
	.["[ACCESS_MECH_MINING]"] = "Mining Mech Access"
	.["[ACCESS_MECH_MEDICAL]"] = "Medical Mech Access"
	.["[ACCESS_MECH_SECURITY]"] = "Security Mech Access"
	.["[ACCESS_MECH_SCIENCE]"] = "Science Mech Access"
	.["[ACCESS_MECH_ENGINE]"] = "Engineering Mech Access"
	.["[ACCESS_AUX_BASE]"] = "Auxiliary Base"
	.["[ACCESS_CENT_GENERAL]"] = "Code Grey"
	.["[ACCESS_CENT_THUNDER]"] = "Code Yellow"
	.["[ACCESS_CENT_STORAGE]"] = "Code Orange"
	.["[ACCESS_CENT_LIVING]"] = "Code Green"
	.["[ACCESS_CENT_MEDICAL]"] = "Code White"
	.["[ACCESS_CENT_TELEPORTER]"] = "Code Blue"
	.["[ACCESS_CENT_SPECOPS]"] = "Code Black"
	.["[ACCESS_CENT_CAPTAIN]"] = "Code Gold"
	.["[ACCESS_CENT_BAR]"] = "Code Scotch"

/datum/controller/subsystem/id_access/proc/setup_tgui_list()
	. = list()
	for (var/r in accesses_by_region)
		.[r] = list()
		for (var/a in accesses_by_region[r])
			.[r] += list(list(
				"name" = name_by_access["[a]"],
				"id" = a,
				"tier" = tiers_by_access["[a]"]
			))

/**
 * Returns the access tier associated with any given access level.
 *
 * Arguments:
 * * access - Access as either pure number or as a string representation of the number.
 */
/datum/controller/subsystem/id_access/proc/get_access_tier(access)
	return tiers_by_access["[access]"]

/**
 * Returns the access description associated with any given access level.
 *
 * In proc form due to accesses being stored in the list as text instead of numbers.
 * Arguments:
 * * access - Access as either pure number or as a string representation of the number.
 */
/datum/controller/subsystem/id_access/proc/get_access_name(access)
	return name_by_access["[access]"]

/**
 * Returns the list of all accesses associated with any given access tier.
 *
 * In proc form due to accesses being stored in the list as text instead of numbers.
 * Arguments:
 * * tier - The tier to get access for as either a pure number of string representation of the tier.
 */
/datum/controller/subsystem/id_access/proc/get_tier_access_list(tier)
	return accesses_by_tier["[tier]"]

/**
 * Tallies up all accesses the card has that have flags greater than or equal to the tier supplied.
 *
 * Returns the number of accesses that have flags matching tier or a higher tier access.
 * Arguments:
 * * id_card - The ID card to tally up access for.
 * * tier - The minimum access tier required for an access to be tallied up.
 */
/datum/controller/subsystem/id_access/proc/tally_access(obj/item/card/id/id_card, tier = NONE)
	var/tally = 0

	var/list/id_card_access = id_card.access
	for(var/access in id_card_access)
		if (tiers_by_access["[access]"] >= tier)
			tally++

	return tally

/datum/controller/subsystem/id_access/proc/apply_card_access(obj/item/card/id/id, card_access_path, chip = FALSE, force = FALSE)
	var/datum/card_access/card_access = card_access_instances[card_access_path]
	var/list/chip_access = list()
	id.assignment = card_access.assignment
	for (var/tier in card_access.access)
		if (!force && id.access_tier < text2num(tier))
			if (chip)
				chip_access.Add(card_access.access[tier])
			continue
		id.add_access(card_access.access[tier], ignore_tier = TRUE)
	id.update_label()

	if (chip_access.len)
		var/obj/item/card_access_chip/roundstart/AA = new(id, card_access.assignment)
		AA.access = chip_access
		id.apply_access_chip(AA)
