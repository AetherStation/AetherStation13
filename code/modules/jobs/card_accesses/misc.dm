/datum/card_access/admin
	assignment = "Jannie"

/datum/card_access/admin/get_access()
	. = ..()
	. += SSid_access.accesses_by_region[REGION_GLOBAL]

/datum/card_access/highlander
	assignment = "Highlander"

/datum/card_access/highlander/New()
	. = ..()
	. += SSid_access.accesses_by_region[REGION_CENTCOM]
	. += SSid_access.accesses_by_region[REGION_STATION]

/datum/card_access/reaper_assassin
	assignment = "Reaper"

/datum/card_access/reaper_assassin/get_access()
	. = ..()
	. += SSid_access.accesses_by_region[REGION_STATION]

/datum/card_access/mobster
	assignment = "Mobster"

/datum/card_access/vr
	assignment = "VR Participant"

/datum/card_access/vr/get_access()
	. = ..()
	. += SSid_access.accesses_by_region[REGION_STATION]

/datum/card_access/vr/operative
	assignment = "Syndicate VR Operative"

/datum/card_access/vr/operative/get_access()
	. = ..()
	. |= list(ACCESS_SYNDICATE, ACCESS_MAINT_TUNNELS)

/datum/card_access/tunnel_clown
	assignment = "Tunnel Clown!"

/datum/card_access/tunnel_clown/get_access()
	. = ..()
	. += SSid_access.accesses_by_region[REGION_STATION]

/datum/card_access/space_police
	assignment = "Space Police"

/datum/card_access/space_police/get_access()
	. = ..()
	. += SSid_access.accesses_by_region[REGION_STATION]
