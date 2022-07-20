/datum/card_access/job
	flags = CARD_ACCESS_ASSIGNABLE
	region = REGION_STATION
	var/list/minimal_access = list()
	var/list/full_access = list()

/datum/card_access/job/get_access()
	. = ..()
	. |= minimal_access
	if (!CONFIG_GET(flag/jobs_have_minimal_access))
		. |= full_access

/datum/card_access/job/security/get_access()
	. = ..()
	if (CONFIG_GET(flag/security_has_maint_access))
		. |= ACCESS_MAINT_TUNNELS

/datum/card_access/job/assistant
	assignment = "Assistant"
	region = REGION_GENERAL

/datum/card_access/job/assistant/get_access()
	. = ..()
	if (CONFIG_GET(flag/assistants_have_maint_access))
		. |= ACCESS_MAINT_TUNNELS

/datum/card_access/job/atmospheric_technician
	assignment = "Atmospheric Technician"
	region = REGION_ENGINEERING
	full_access = list(ACCESS_ENGINE, ACCESS_ENGINE_EQUIP, ACCESS_TECH_STORAGE, ACCESS_EXTERNAL_AIRLOCKS)
	minimal_access = list(ACCESS_ATMOSPHERICS, ACCESS_MAINT_TUNNELS, ACCESS_AUX_BASE, ACCESS_CONSTRUCTION, ACCESS_MECH_ENGINE,
					ACCESS_MINERAL_STOREROOM)

/datum/card_access/job/bartender
	assignment = "Bartender"
	region = REGION_GENERAL
	full_access = list(ACCESS_HYDROPONICS, ACCESS_KITCHEN, ACCESS_MORGUE)
	minimal_access = list(ACCESS_BAR, ACCESS_WEAPONS, ACCESS_MINERAL_STOREROOM, ACCESS_THEATRE)

/datum/card_access/job/botanist
	assignment = "Botanist"
	region = REGION_GENERAL
	full_access = list(ACCESS_BAR, ACCESS_KITCHEN)
	minimal_access = list(ACCESS_HYDROPONICS, ACCESS_MORGUE, ACCESS_MINERAL_STOREROOM)

/datum/card_access/job/captain
	assignment = "Captain"
	region = REGION_COMMAND

/datum/card_access/job/captain/get_access()
	. = ..()
	. += SSid_access.accesses_by_region[REGION_STATION]

/datum/card_access/job/cargo_technician
	assignment = "Cargo Technician"
	region = REGION_SUPPLY
	full_access = list(ACCESS_QM, ACCESS_MINING, ACCESS_MINING_STATION)
	minimal_access = list(ACCESS_MAINT_TUNNELS, ACCESS_CARGO, ACCESS_MAILSORTING, ACCESS_MINERAL_STOREROOM, ACCESS_MECH_MINING)

/datum/card_access/job/chaplain
	assignment = "Chaplain"
	region = REGION_GENERAL
	minimal_access = list(ACCESS_MORGUE, ACCESS_CHAPEL_OFFICE, ACCESS_CREMATORIUM, ACCESS_THEATRE)

/datum/card_access/job/chemist
	assignment = "Chemist"
	region = REGION_MEDBAY
	full_access = list(ACCESS_SURGERY, ACCESS_VIROLOGY)
	minimal_access = list(ACCESS_MEDICAL, ACCESS_MORGUE, ACCESS_CHEMISTRY, ACCESS_MECH_MEDICAL, ACCESS_MINERAL_STOREROOM, ACCESS_PHARMACY)

/datum/card_access/job/chief_engineer
	assignment = "Chief Engineer"
	region = REGION_COMMAND
	full_access = list(ACCESS_TELEPORTER)
	minimal_access = list(ACCESS_ENGINE, ACCESS_ENGINE_EQUIP, ACCESS_TECH_STORAGE, ACCESS_MAINT_TUNNELS,
					ACCESS_EXTERNAL_AIRLOCKS, ACCESS_ATMOSPHERICS, ACCESS_EVA, ACCESS_AUX_BASE,
					ACCESS_HEADS, ACCESS_CONSTRUCTION, ACCESS_SEC_DOORS, ACCESS_MINISAT, ACCESS_MECH_ENGINE,
					ACCESS_CE, ACCESS_RC_ANNOUNCE, ACCESS_KEYCARD_AUTH, ACCESS_TCOMSAT, ACCESS_MINERAL_STOREROOM)

/datum/card_access/job/chief_medical_officer
	assignment = "Chief Medical Officer"
	region = REGION_COMMAND
	full_access = list(ACCESS_TELEPORTER)
	minimal_access = list(ACCESS_MEDICAL, ACCESS_PSYCHOLOGY, ACCESS_MORGUE, ACCESS_PHARMACY, ACCESS_HEADS, ACCESS_MINERAL_STOREROOM,
			ACCESS_CHEMISTRY, ACCESS_VIROLOGY, ACCESS_SURGERY, ACCESS_RC_ANNOUNCE, ACCESS_MECH_MEDICAL,
			ACCESS_KEYCARD_AUTH, ACCESS_SEC_DOORS, ACCESS_MAINT_TUNNELS, ACCESS_EVA, ACCESS_CMO)

/datum/card_access/job/clown
	assignment = "Clown"
	region = REGION_GENERAL
	minimal_access = list(ACCESS_THEATRE)

/datum/card_access/job/cook
	assignment = "Cook"
	region = REGION_GENERAL
	full_access = list(ACCESS_HYDROPONICS, ACCESS_BAR)
	minimal_access = list(ACCESS_KITCHEN, ACCESS_MORGUE, ACCESS_MINERAL_STOREROOM)

/datum/card_access/job/curator
	assignment = "Curator"
	region = REGION_GENERAL
	minimal_access = list(ACCESS_LIBRARY, ACCESS_AUX_BASE, ACCESS_MINING_STATION)

/datum/card_access/job/security/detective
	assignment = "Detective"
	minimal_access = list(ACCESS_SEC_DOORS, ACCESS_FORENSICS_LOCKERS, ACCESS_MORGUE, ACCESS_MAINT_TUNNELS, ACCESS_MECH_SECURITY, ACCESS_COURT, ACCESS_BRIG, ACCESS_WEAPONS, ACCESS_MINERAL_STOREROOM)

/datum/card_access/job/geneticist
	assignment = "Geneticist"
	region = REGION_RESEARCH
	full_access = list(ACCESS_XENOBIOLOGY, ACCESS_ROBOTICS, ACCESS_TECH_STORAGE)
	minimal_access = list(ACCESS_MORGUE, ACCESS_GENETICS, ACCESS_MECH_SCIENCE, ACCESS_RESEARCH, ACCESS_MINERAL_STOREROOM, ACCESS_RND)

/datum/card_access/job/head_of_personnel
	assignment = "Head of Personnel"
	region = REGION_COMMAND
	minimal_access = list(ACCESS_SECURITY, ACCESS_SEC_DOORS, ACCESS_COURT, ACCESS_WEAPONS,
						ACCESS_MEDICAL, ACCESS_PSYCHOLOGY, ACCESS_ENGINE, ACCESS_CHANGE_IDS, ACCESS_AI_UPLOAD, ACCESS_EVA, ACCESS_HEADS,
						ACCESS_ALL_PERSONAL_LOCKERS, ACCESS_MAINT_TUNNELS, ACCESS_BAR, ACCESS_JANITOR, ACCESS_CONSTRUCTION, ACCESS_MORGUE,
						ACCESS_CREMATORIUM, ACCESS_KITCHEN, ACCESS_CARGO, ACCESS_MAILSORTING, ACCESS_QM, ACCESS_HYDROPONICS, ACCESS_LAWYER,
						ACCESS_MECH_MINING, ACCESS_MECH_ENGINE, ACCESS_MECH_SCIENCE, ACCESS_MECH_SECURITY, ACCESS_MECH_MEDICAL,
						ACCESS_THEATRE, ACCESS_CHAPEL_OFFICE, ACCESS_LIBRARY, ACCESS_RESEARCH, ACCESS_MINING, ACCESS_VAULT, ACCESS_MINING_STATION,
						ACCESS_RC_ANNOUNCE, ACCESS_KEYCARD_AUTH, ACCESS_GATEWAY, ACCESS_MINERAL_STOREROOM, ACCESS_AUX_BASE, ACCESS_TELEPORTER, ACCESS_HOP)

/datum/card_access/job/security/head_of_security
	assignment = "Head of Security"
	full_access = list(ACCESS_TELEPORTER)
	minimal_access = list(ACCESS_SECURITY, ACCESS_SEC_DOORS, ACCESS_BRIG, ACCESS_ARMORY, ACCESS_COURT, ACCESS_WEAPONS, ACCESS_MECH_SECURITY,
					ACCESS_FORENSICS_LOCKERS, ACCESS_MORGUE, ACCESS_MAINT_TUNNELS, ACCESS_ALL_PERSONAL_LOCKERS, ACCESS_AUX_BASE,
					ACCESS_RESEARCH, ACCESS_ENGINE, ACCESS_MINING, ACCESS_MEDICAL, ACCESS_CONSTRUCTION, ACCESS_MAILSORTING, ACCESS_EVA,
					ACCESS_HEADS, ACCESS_RC_ANNOUNCE, ACCESS_KEYCARD_AUTH, ACCESS_GATEWAY, ACCESS_MINERAL_STOREROOM, ACCESS_HOS)

/datum/card_access/job/janitor
	assignment = "Janitor"
	region = REGION_GENERAL
	minimal_access = list(ACCESS_JANITOR, ACCESS_MAINT_TUNNELS, ACCESS_MINERAL_STOREROOM)

/datum/card_access/job/lawyer
	assignment = "Lawyer"
	region = REGION_GENERAL
	minimal_access = list(ACCESS_LAWYER, ACCESS_COURT, ACCESS_SEC_DOORS)

/datum/card_access/job/medical_doctor
	assignment = "Medical Doctor"
	region = REGION_MEDBAY
	full_access = list(ACCESS_CHEMISTRY, ACCESS_VIROLOGY)
	minimal_access = list(ACCESS_MEDICAL, ACCESS_MORGUE, ACCESS_SURGERY, ACCESS_MECH_MEDICAL, ACCESS_MINERAL_STOREROOM, ACCESS_PHARMACY)

/datum/card_access/job/mime
	assignment = "Mime"
	region = REGION_GENERAL
	minimal_access = list(ACCESS_THEATRE)

/datum/card_access/job/paramedic
	assignment = "Paramedic"
	region = REGION_MEDBAY
	full_access = list(ACCESS_SURGERY)
	minimal_access = list(ACCESS_MEDICAL, ACCESS_MORGUE, ACCESS_MECH_MEDICAL, ACCESS_MINERAL_STOREROOM, ACCESS_MAINT_TUNNELS, ACCESS_EVA,
						ACCESS_ENGINE, ACCESS_CONSTRUCTION, ACCESS_CARGO, ACCESS_HYDROPONICS, ACCESS_RESEARCH, ACCESS_AUX_BASE)

/datum/card_access/job/prisoner
	assignment = "Prisoner"
	region = REGION_GENERAL

/datum/card_access/job/psychologist
	assignment = "Psychologist"
	region = REGION_MEDBAY
	minimal_access = list(ACCESS_MEDICAL, ACCESS_PSYCHOLOGY)

/datum/card_access/job/quartermaster
	assignment = "Quartermaster"
	region = REGION_SUPPLY
	minimal_access = list(ACCESS_MAINT_TUNNELS, ACCESS_MAILSORTING, ACCESS_CARGO, ACCESS_QM, ACCESS_MINING, ACCESS_MECH_MINING,
						ACCESS_MINING_STATION, ACCESS_MINERAL_STOREROOM, ACCESS_VAULT, ACCESS_AUX_BASE, ACCESS_RC_ANNOUNCE)

/datum/card_access/job/research_director
	assignment = "Research Director"
	region = REGION_COMMAND
	minimal_access = list(ACCESS_HEADS, ACCESS_RND, ACCESS_GENETICS, ACCESS_MORGUE,
						ACCESS_TOXINS, ACCESS_TELEPORTER, ACCESS_SEC_DOORS, ACCESS_MECH_SCIENCE,
						ACCESS_RESEARCH, ACCESS_ROBOTICS, ACCESS_XENOBIOLOGY, ACCESS_AI_UPLOAD,
						ACCESS_RC_ANNOUNCE, ACCESS_KEYCARD_AUTH, ACCESS_GATEWAY, ACCESS_MINERAL_STOREROOM,
						ACCESS_TECH_STORAGE, ACCESS_MINISAT, ACCESS_MAINT_TUNNELS, ACCESS_NETWORK,
						ACCESS_TOXINS_STORAGE, ACCESS_AUX_BASE, ACCESS_EVA, ACCESS_RD)

/datum/card_access/job/roboticist
	assignment = "Roboticist"
	region = REGION_RESEARCH
	full_access = list(ACCESS_RND, ACCESS_TOXINS, ACCESS_TOXINS_STORAGE, ACCESS_XENOBIOLOGY, ACCESS_GENETICS)
	minimal_access = list(ACCESS_ROBOTICS, ACCESS_TECH_STORAGE, ACCESS_MORGUE, ACCESS_RESEARCH, ACCESS_MECH_SCIENCE, ACCESS_MINERAL_STOREROOM,
						ACCESS_RND, ACCESS_AUX_BASE)

/datum/card_access/job/scientist
	assignment = "Scientist"
	region = REGION_RESEARCH
	full_access = list(ACCESS_ROBOTICS, ACCESS_TECH_STORAGE, ACCESS_GENETICS)
	minimal_access = list(ACCESS_RND, ACCESS_TOXINS, ACCESS_TOXINS_STORAGE, ACCESS_RESEARCH, ACCESS_XENOBIOLOGY, ACCESS_MECH_SCIENCE,
							ACCESS_MINERAL_STOREROOM, ACCESS_AUX_BASE)

/datum/card_access/job/security/officer
	assignment = "Security Officer"
	full_access = list(ACCESS_MAINT_TUNNELS, ACCESS_MORGUE, ACCESS_FORENSICS_LOCKERS)
	minimal_access = list(ACCESS_SECURITY, ACCESS_SEC_DOORS, ACCESS_BRIG, ACCESS_COURT, ACCESS_WEAPONS, ACCESS_MECH_SECURITY, ACCESS_MINERAL_STOREROOM)
	var/department_access = list()

/datum/card_access/job/security/officer/get_access()
	. = ..()
	. |= department_access

/datum/card_access/job/security/officer/supply
	assignment = "Security Officer (Cargo)"
	flags = NONE
	department_access = list(ACCESS_MAILSORTING, ACCESS_MINING, ACCESS_MINING_STATION, ACCESS_CARGO, ACCESS_AUX_BASE)

/datum/card_access/job/security/officer/engineering
	assignment = "Security Officer (Engineering)"
	flags = NONE
	department_access = list(ACCESS_CONSTRUCTION, ACCESS_ENGINE, ACCESS_ATMOSPHERICS, ACCESS_AUX_BASE)

/datum/card_access/job/security/officer/medical
	assignment = "Security Officer (Medical)"
	flags = NONE
	department_access = list(ACCESS_MEDICAL, ACCESS_MORGUE, ACCESS_SURGERY)

/datum/card_access/job/security/officer/science
	assignment = "Security Officer (Science)"
	flags = NONE
	department_access = list(ACCESS_RESEARCH, ACCESS_RND, ACCESS_AUX_BASE)

/datum/card_access/job/shaft_miner
	assignment = "Shaft Miner"
	region = REGION_SUPPLY
	full_access = list(ACCESS_MAINT_TUNNELS, ACCESS_CARGO, ACCESS_QM)
	minimal_access = list(ACCESS_MINING, ACCESS_MECH_MINING, ACCESS_MINING_STATION, ACCESS_MAILSORTING, ACCESS_MINERAL_STOREROOM, ACCESS_AUX_BASE)

/datum/card_access/job/shaft_miner/spare
	flags = NONE
	minimal_access = list(ACCESS_MINING, ACCESS_MINING_STATION, ACCESS_MECH_MINING, ACCESS_MAILSORTING, ACCESS_MINERAL_STOREROOM)

/datum/card_access/job/station_engineer
	assignment = "Station Engineer"
	region = REGION_ENGINEERING
	full_access = list(ACCESS_ATMOSPHERICS)
	minimal_access = list(ACCESS_ENGINE, ACCESS_ENGINE_EQUIP, ACCESS_TECH_STORAGE, ACCESS_MAINT_TUNNELS, ACCESS_MECH_ENGINE, ACCESS_AUX_BASE,
						ACCESS_EXTERNAL_AIRLOCKS, ACCESS_CONSTRUCTION, ACCESS_TCOMSAT, ACCESS_MINERAL_STOREROOM)

/datum/card_access/job/virologist
	assignment = "Virologist"
	region = REGION_MEDBAY
	full_access = list(ACCESS_MORGUE, ACCESS_SURGERY, ACCESS_CHEMISTRY)
	minimal_access = list(ACCESS_MEDICAL, ACCESS_VIROLOGY, ACCESS_MECH_MEDICAL, ACCESS_MINERAL_STOREROOM)

/datum/card_access/job/security/warden
	assignment = "Warden"
	full_access = list(ACCESS_MAINT_TUNNELS, ACCESS_MORGUE, ACCESS_FORENSICS_LOCKERS)
	minimal_access = list(ACCESS_SECURITY, ACCESS_SEC_DOORS, ACCESS_BRIG, ACCESS_ARMORY,
						ACCESS_MECH_SECURITY, ACCESS_COURT, ACCESS_WEAPONS, ACCESS_MINERAL_STOREROOM)
