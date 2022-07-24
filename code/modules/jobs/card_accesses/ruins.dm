/datum/card_access/away
	access = list(ACCESS_AWAY_GENERAL)

/datum/card_access/away/hotel
	access = list(ACCESS_AWAY_GENERAL, ACCESS_AWAY_MAINT)

/datum/card_access/away/hotel/security
	access = list(ACCESS_AWAY_GENERAL, ACCESS_AWAY_MAINT, ACCESS_AWAY_SEC)

/datum/card_access/away/old/sec
	assignment = "Charlie Station Security Officer"
	access = list(ACCESS_AWAY_GENERAL, ACCESS_AWAY_SEC)

/datum/card_access/away/old/sci
	assignment = "Charlie Station Scientist"
	access = list(ACCESS_AWAY_GENERAL)

/datum/card_access/away/old/eng
	assignment = "Charlie Station Engineer"
	access = list(ACCESS_AWAY_GENERAL, ACCESS_AWAY_ENGINE)

/datum/card_access/away/old/apc
	access = list(ACCESS_ENGINE_EQUIP)

/datum/card_access/away/cat_surgeon
	assignment = "Cat Surgeon"
	access = list(ACCESS_AWAY_GENERAL, ACCESS_AWAY_MAINT)

/datum/card_access/away/hilbert
	assignment = "Head Researcher"
	access = list(ACCESS_AWAY_GENERIC3, ACCESS_RESEARCH)

/datum/card_access/lifeguard
	assignment = "Lifeguard"

/datum/card_access/space_bartender
	assignment = "Space Bartender"
	access = list(ACCESS_BAR)

/datum/card_access/centcom/corpse/bridge_officer
	assignment = "Bridge Officer"
	access = list(ACCESS_CENT_CAPTAIN)

/datum/card_access/centcom/corpse/commander
	assignment = "Commander"
	access = list(ACCESS_CENT_CAPTAIN, ACCESS_CENT_GENERAL, ACCESS_CENT_SPECOPS, ACCESS_CENT_MEDICAL, ACCESS_CENT_STORAGE)

/datum/card_access/centcom/corpse/private_security
	assignment = "Private Security Force"
	access = list(ACCESS_CENT_CAPTAIN, ACCESS_CENT_GENERAL, ACCESS_CENT_SPECOPS, ACCESS_CENT_MEDICAL, ACCESS_CENT_STORAGE, ACCESS_SECURITY, ACCESS_MECH_SECURITY)

/datum/card_access/centcom/corpse/private_security/tradepost_officer
	assignment = "Tradepost Officer"

/datum/card_access/centcom/corpse/assault
	assignment = "Nanotrasen Assault Force"
	access = list(ACCESS_CENT_CAPTAIN, ACCESS_CENT_GENERAL, ACCESS_CENT_SPECOPS, ACCESS_CENT_MEDICAL, ACCESS_CENT_STORAGE, ACCESS_SECURITY, ACCESS_MECH_SECURITY)

/datum/card_access/engioutpost
	assignment = "Senior Station Engineer"
	access = list(ACCESS_AWAY_GENERAL, ACCESS_AWAY_ENGINE, ACCESS_ENGINE, ACCESS_ENGINE_EQUIP, ACCESS_MAINT_TUNNELS)

/datum/card_access/job/station_engineer/gunner
	flags = NONE
	assignment = "Gunner"

/datum/card_access/pirate
	assignment = "Pirate"
	access = list(ACCESS_SYNDICATE)

/datum/card_access/pirate/silverscale
	assignment = "Silver Scale Member"

/datum/card_access/pirate/captain
	assignment = "Pirate Captain"

/datum/card_access/pirate/captain/silverscale
	assignment = "Silver Scale VIP"
