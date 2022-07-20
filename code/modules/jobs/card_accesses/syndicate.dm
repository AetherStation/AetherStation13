/datum/card_access/syndicom
	assignment = "Syndicate Overlord"
	region = REGION_SYNDICATE
	access = list(ACCESS_SYNDICATE)

/datum/card_access/syndicom/crew
	assignment = "Syndicate Operative"
	access = list(ACCESS_SYNDICATE, ACCESS_ROBOTICS)

/datum/card_access/syndicom/captain
	assignment = "Syndicate Ship Captain"
	access = list(ACCESS_SYNDICATE, ACCESS_ROBOTICS)

/datum/card_access/battlecruiser
	assignment = "Syndicate Battlecruiser Crew"
	access = list(ACCESS_SYNDICATE)

/datum/card_access/battlecruiser/captain
	assignment = "Syndicate Battlecruiser Captain"
	access = list(ACCESS_SYNDICATE, ACCESS_SYNDICATE_LEADER)

/datum/card_access/chameleon
	assignment = "Unknown"
	access = list(ACCESS_SYNDICATE, ACCESS_MAINT_TUNNELS)

/datum/card_access/chameleon/operative
	assignment = "Syndicate Operative"

/datum/card_access/chameleon/operative/clown
	assignment = "Syndicate Entertainment Operative"

/datum/card_access/chameleon/operative/clown_leader
	assignment = "Syndicate Entertainment Operative Leader"
	access = list(ACCESS_MAINT_TUNNELS, ACCESS_SYNDICATE, ACCESS_SYNDICATE_LEADER)

/datum/card_access/chameleon/operative/nuke_leader
	assignment = "Syndicate Operative Leader"
	access = list(ACCESS_MAINT_TUNNELS, ACCESS_SYNDICATE, ACCESS_SYNDICATE_LEADER)
