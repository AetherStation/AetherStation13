/datum/card_access
	var/assignment = ""
	var/region = REGION_AWAY
	var/flags = NONE
	var/list/access = list()

/datum/card_access/New()
	var/list/list/_access = list(
		"[ACCESS_TIER_1]" = list(),
		"[ACCESS_TIER_2]" = list(),
		"[ACCESS_TIER_3]" = list(),
		"[ACCESS_TIER_4]" = list(),
		"[ACCESS_TIER_5]" = list(),
		"[ACCESS_TIER_6]" = list()
	)
	for (var/a in get_access())
		_access[SSid_access.get_access_tier(a)].Add(a)
	access = _access

/datum/card_access/proc/get_access()
	return access
