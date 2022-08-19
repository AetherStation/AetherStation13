/datum/card_access/centcom
	access = list(ACCESS_CENT_GENERAL)
	region = REGION_CENTCOM
	assignment = "Central Command"

/datum/card_access/centcom/vip
	access = list(ACCESS_CENT_GENERAL)
	assignment = "VIP Guest"

/datum/card_access/centcom/custodian
	access = list(ACCESS_CENT_GENERAL, ACCESS_CENT_LIVING, ACCESS_CENT_STORAGE)
	assignment = "Custodian"

/datum/card_access/centcom/thunderdome_overseer
	access = list(ACCESS_CENT_GENERAL, ACCESS_CENT_THUNDER)
	assignment = "Thunderdome Overseer"

/datum/card_access/centcom/official
	access = list(ACCESS_CENT_GENERAL, ACCESS_CENT_LIVING, ACCESS_WEAPONS)
	assignment = "CentCom Official"

/datum/card_access/centcom/intern
	access = list(ACCESS_CENT_GENERAL, ACCESS_CENT_LIVING, ACCESS_WEAPONS)
	assignment = "CentCom Intern"

/datum/card_access/centcom/intern/head
	assignment = "CentCom Head Intern"

/datum/card_access/centcom/intern/head/get_access()
	. = ..()
	. |= SSid_access.get_tier_access_list(ACCESS_TIER_1)

/datum/card_access/centcom/bartender
	access = list(ACCESS_CENT_GENERAL, ACCESS_CENT_LIVING, ACCESS_CENT_BAR)
	assignment = "CentCom Bartender"

/datum/card_access/centcom/medical_officer
	access = list(ACCESS_CENT_GENERAL, ACCESS_CENT_LIVING, ACCESS_CENT_MEDICAL)
	assignment = "Medical Officer"

/datum/card_access/centcom/research_officer
	access = list(ACCESS_CENT_GENERAL, ACCESS_CENT_SPECOPS, ACCESS_CENT_MEDICAL, ACCESS_CENT_TELEPORTER, ACCESS_CENT_STORAGE)
	assignment = "Research Officer"

/datum/card_access/centcom/specops_officer
	assignment = "Special Ops Officer"

/datum/card_access/centcom/specops_officer/get_access()
	. = ..()
	. |= SSid_access.accesses_by_region[REGION_STATION] + SSid_access.accesses_by_region[REGION_CENTCOM]

/datum/card_access/centcom/admiral
	assignment = "Admiral"

/datum/card_access/centcom/admiral/get_access()
	. = ..()
	. |= SSid_access.accesses_by_region[REGION_STATION] + SSid_access.accesses_by_region[REGION_CENTCOM]

/datum/card_access/centcom/commander
	assignment = "CentCom Commander"

/datum/card_access/centcom/commander/get_access()
	. = ..()
	. |= SSid_access.accesses_by_region[REGION_STATION] + SSid_access.accesses_by_region[REGION_CENTCOM]

/datum/card_access/centcom/deathsquad
	assignment = "Death Commando"

/datum/card_access/centcom/deathsquad/get_access()
	. = ..()
	. |= SSid_access.accesses_by_region[REGION_STATION] + SSid_access.accesses_by_region[REGION_CENTCOM]

/datum/card_access/centcom/ert
	access = list(ACCESS_CENT_GENERAL)
	assignment = "Emergency Response Team Intern"

/datum/card_access/centcom/ert/get_access()
	. = ..()
	. |= (SSid_access.accesses_by_region[REGION_STATION] - ACCESS_CHANGE_IDS)

/datum/card_access/centcom/ert/commander
	assignment = "Emergency Response Team Commander"

/datum/card_access/centcom/ert/commander/get_access()
	. = ..()
	. |= SSid_access.accesses_by_region[REGION_STATION] + SSid_access.accesses_by_region[REGION_CENTCOM]

/datum/card_access/centcom/ert/security
	access = list(ACCESS_CENT_GENERAL, ACCESS_CENT_SPECOPS, ACCESS_CENT_LIVING)
	assignment = "Security Response Officer"

/datum/card_access/centcom/ert/engineer
	access = list(ACCESS_CENT_GENERAL, ACCESS_CENT_SPECOPS, ACCESS_CENT_LIVING, ACCESS_CENT_STORAGE)
	assignment = "Engineering Response Officer"

/datum/card_access/centcom/ert/medical
	access = list(ACCESS_CENT_GENERAL, ACCESS_CENT_SPECOPS, ACCESS_CENT_MEDICAL, ACCESS_CENT_LIVING)
	assignment = "Medical Response Officer"

/datum/card_access/centcom/ert/chaplain
	access = list(ACCESS_CENT_GENERAL, ACCESS_CENT_SPECOPS, ACCESS_CENT_LIVING)
	assignment = "Religious Response Officer"

/datum/card_access/centcom/ert/janitor
	access = list(ACCESS_CENT_GENERAL, ACCESS_CENT_LIVING)
	assignment = "Janitorial Response Officer"

/datum/card_access/centcom/ert/clown
	access = list(ACCESS_CENT_GENERAL, ACCESS_CENT_LIVING)
	assignment = "Entertainment Response Officer"
