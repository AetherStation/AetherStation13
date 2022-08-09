#define NUKE_RESULT_FLUKE 0
#define NUKE_RESULT_NUKE_WIN 1
#define NUKE_RESULT_CREW_WIN 2
#define NUKE_RESULT_CREW_WIN_SYNDIES_DEAD 3
#define NUKE_RESULT_DISK_LOST 4
#define NUKE_RESULT_DISK_STOLEN 5
#define NUKE_RESULT_NOSURVIVORS 6
#define NUKE_RESULT_WRONG_STATION 7
#define NUKE_RESULT_WRONG_STATION_DEAD 8

//fugitive end results
#define FUGITIVE_RESULT_BADASS_HUNTER 0
#define FUGITIVE_RESULT_POSTMORTEM_HUNTER 1
#define FUGITIVE_RESULT_MAJOR_HUNTER 2
#define FUGITIVE_RESULT_HUNTER_VICTORY 3
#define FUGITIVE_RESULT_MINOR_HUNTER 4
#define FUGITIVE_RESULT_STALEMATE 5
#define FUGITIVE_RESULT_MINOR_FUGITIVE 6
#define FUGITIVE_RESULT_FUGITIVE_VICTORY 7
#define FUGITIVE_RESULT_MAJOR_FUGITIVE 8

#define APPRENTICE_DESTRUCTION "destruction"
#define APPRENTICE_BLUESPACE "bluespace"
#define APPRENTICE_ROBELESS "robeless"
#define APPRENTICE_HEALING "healing"

//ERT Types
#define ERT_BLUE "Blue"
#define ERT_RED  "Red"
#define ERT_AMBER "Amber"
#define ERT_DEATHSQUAD "Deathsquad"

//ERT subroles
#define ERT_SEC "sec"
#define ERT_MED "med"
#define ERT_ENG "eng"
#define ERT_LEADER "leader"
#define DEATHSQUAD "ds"
#define DEATHSQUAD_LEADER "ds_leader"

//Shuttle elimination hijacking
/// Does not stop elimination hijacking but itself won't elimination hijack
#define ELIMINATION_NEUTRAL 0
/// Needs to be present for shuttle to be elimination hijacked
#define ELIMINATION_ENABLED 1
/// Prevents elimination hijack same way as non-antags
#define ELIMINATION_PREVENT 2

//Syndicate Contracts
#define CONTRACT_STATUS_INACTIVE 1
#define CONTRACT_STATUS_ACTIVE 2
#define CONTRACT_STATUS_BOUNTY_CONSOLE_ACTIVE 3
#define CONTRACT_STATUS_EXTRACTING 4
#define CONTRACT_STATUS_COMPLETE 5
#define CONTRACT_STATUS_ABORTED 6

#define CONTRACT_PAYOUT_LARGE 1
#define CONTRACT_PAYOUT_MEDIUM 2
#define CONTRACT_PAYOUT_SMALL 3

#define CONTRACT_UPLINK_PAGE_CONTRACTS "CONTRACTS"
#define CONTRACT_UPLINK_PAGE_HUB "HUB"

//Heretic path defines
#define PATH_START "Start"
#define PATH_SIDE "Side"
#define PATH_ASH "Ash"
#define PATH_RUST "Rust"
#define PATH_FLESH "Flesh"
#define PATH_VOID "Void"
#define PATH_BLADE "Blade"

/// A define used in ritual priority for heretics.
#define MAX_KNOWLEDGE_PRIORITY 100

/// Checks if the passed mob can become a heretic ghoul.
/// - Must be a human (type, not species)
/// - Skeletons cannot be husked (they are snowflaked instead of having a trait)
/// - Monkeys are monkeys, not quite human (balance reasons)
#define IS_VALID_GHOUL_MOB(mob) (ishuman(mob) && !isskeleton(mob) && !ismonkey(mob))

/// Forces the blob to place the core where they currently are, ignoring any checks.
#define BLOB_FORCE_PLACEMENT -1
/// Normal blob placement, does the regular checks to make sure the blob isn't placing itself in an invalid location
#define BLOB_NORMAL_PLACEMENT 0
/// Selects a random location for the blob to be placed.
#define BLOB_RANDOM_PLACEMENT 1

#define CONSTRUCT_JUGGERNAUT "Juggernaut"
#define CONSTRUCT_WRAITH "Wraith"
#define CONSTRUCT_ARTIFICER "Artificer"


/// How many telecrystals a normal traitor starts with
#define TELECRYSTALS_DEFAULT 20
/// How many telecrystals mapper/admin only "precharged" uplink implant
#define TELECRYSTALS_PRELOADED_IMPLANT 10
/// The normal cost of an uplink implant; used for calcuating how many
/// TC to charge someone if they get a free implant through choice or
/// because they have nothing else that supports an implant.
#define UPLINK_IMPLANT_TELECRYSTAL_COST 4

/// The Classic Wizard wizard loadout.
#define WIZARD_LOADOUT_CLASSIC "loadout_classic"
/// Mjolnir's Power wizard loadout.
#define WIZARD_LOADOUT_MJOLNIR "loadout_hammer"
/// Fantastical Army wizard loadout.
#define WIZARD_LOADOUT_WIZARMY "loadout_army"
/// Soul Tapper wizard loadout.
#define WIZARD_LOADOUT_SOULTAP "loadout_tap"
/// Convenient list of all wizard loadouts for unit testing.
#define ALL_WIZARD_LOADOUTS list( \
	WIZARD_LOADOUT_CLASSIC, \
	WIZARD_LOADOUT_MJOLNIR, \
	WIZARD_LOADOUT_WIZARMY, \
	WIZARD_LOADOUT_SOULTAP, \
)

///File to the traitor flavor
#define TRAITOR_FLAVOR_FILE "traitor_flavor.json"

///employers that are from the syndicate
GLOBAL_LIST_INIT(syndicate_employers, list(
	"Tiger Cooperative Fanatic",
	"Waffle Corporation Terrorist",
	"Animal Rights Consortium",
	"Bee Liberation Front",
	"Cybersun Industries",
	"MI13",
	"Gorlex Marauders",
	"Donk Corporation",
	"Waffle Corporation",
))
///employers that are from nanotrasen
GLOBAL_LIST_INIT(nanotrasen_employers, list(
	"Gone Postal",
	"Internal Affairs Agent",
	"Corporate Climber",
	"Legal Trouble"
))

///employers who hire agents to do the hijack
GLOBAL_LIST_INIT(hijack_employers, list(
	"Tiger Cooperative Fanatic",
	"Waffle Corporation Terrorist",
	"Animal Rights Consortium",
	"Bee Liberation Front",
	"Gone Postal"
))

///employers who hire agents to do a task and escape... or martyrdom. whatever
GLOBAL_LIST_INIT(normal_employers, list(
	"Cybersun Industries",
	"MI13",
	"Gorlex Marauders",
	"Donk Corporation",
	"Waffle Corporation",
	"Internal Affairs Agent",
	"Corporate Climber",
	"Legal Trouble"
))

///how long traitors will have to wait before an unreasonable objective is rerolled
#define OBJECTIVE_REROLL_TIMER 10 MINUTES

///all the employers that are syndicate
#define FACTION_SYNDICATE "syndicate"
///all the employers that are nanotrasen
#define FACTION_NANOTRASEN "nanotrasen"

#define UPLINK_THEME_SYNDICATE "syndicate"

#define UPLINK_THEME_UNDERWORLD_MARKET "neutral"

/// Checks if the given mob is a blood cultist
#define IS_CULTIST(mob) (mob?.mind?.has_antag_datum(/datum/antagonist/cult))

/// Checks if the given mind is a leader of the monkey antagonists
#define IS_MONKEY_LEADER(mind) mind?.has_antag_datum(/datum/antagonist/monkey/leader)

/// Checks if the given mind is a monkey antagonist
#define IS_INFECTED_MONKEY(mind) mind?.has_antag_datum(/datum/antagonist/monkey)

/// Checks if the given mob is a nuclear operative
#define IS_NUKE_OP(mob) (mob?.mind?.has_antag_datum(/datum/antagonist/nukeop))

/// Checks if the given mob is a heretic.
#define IS_HERETIC(mob) (mob.mind?.has_antag_datum(/datum/antagonist/heretic))

/// Check if the given mob is a heretic monster.
#define IS_HERETIC_MONSTER(mob) (mob.mind?.has_antag_datum(/datum/antagonist/heretic_monster))

/// Checks if the given mob is either a heretic or a heretic monster.
#define IS_HERETIC_OR_MONSTER(mob) (IS_HERETIC(mob) || IS_HERETIC_MONSTER(mob))

/// Define for the heretic faction applied to heretics and heretic mobs.
#define FACTION_HERETIC "heretics"

/// Checks if the given mob is a wizard
#define IS_WIZARD(mob) (mob?.mind?.has_antag_datum(/datum/antagonist/wizard))

/// Checks if the given mob is a revolutionary. Will return TRUE for rev heads as well.
#define IS_REVOLUTIONARY(mob) (mob?.mind?.has_antag_datum(/datum/antagonist/rev))

/// Checks if the given mob is a head revolutionary.
#define IS_HEAD_REVOLUTIONARY(mob) (mob?.mind?.has_antag_datum(/datum/antagonist/rev/head))

///Shadowlings
#define ANTAG_DATUM_THRALL		/datum/antagonist/thrall
#define ANTAG_DATUM_SLING		/datum/antagonist/shadowling

#define is_thrall(M) (istype(M, /mob/living) && M.mind && M.mind.has_antag_datum(/datum/antagonist/thrall))
#define is_shadow(M) (istype(M, /mob/living) && M.mind && M.mind.has_antag_datum(/datum/antagonist/shadowling))
#define is_shadow_or_thrall(M) (is_thrall(M) || is_shadow(M))

#define LIGHT_HEAL_THRESHOLD 2
#define LIGHT_DAMAGE_TAKEN 7
#define LIGHT_DAM_THRESHOLD 0.25

/datum/species/shadow/ling
	//Normal shadowpeople but with enhanced effects
	name = "Shadowling"
	id = "shadowling"
	say_mod = "chitters"
	species_traits = list(NOBLOOD,NO_UNDERWEAR,NO_DNA_COPY,NOTRANSSTING,NOEYES)
	inherent_traits = list(TRAIT_NOGUNS, TRAIT_RESISTCOLD, TRAIT_RESISTHIGHPRESSURE,TRAIT_RESISTLOWPRESSURE, TRAIT_NOBREATH, TRAIT_RADIMMUNE, TRAIT_VIRUSIMMUNE, TRAIT_PIERCEIMMUNE)
	no_equip = list(SLOT_WEAR_MASK, SLOT_GLASSES, SLOT_GLOVES, SLOT_SHOES, SLOT_W_UNIFORM, SLOT_S_STORE)
	nojumpsuit = TRUE
	mutanteyes = /obj/item/organ/eyes/night_vision/alien/sling
	burnmod = 1.5 //1.5x burn damage, 2x is excessive
	heatmod = 1.5
	var/mutable_appearance/eyes_overlay
	var/shadow_charges = 3
	var/last_charge = 0

/datum/species/shadow/ling/on_species_gain(mob/living/carbon/human/C)
	C.draw_yogs_parts(TRUE)
	eyes_overlay = mutable_appearance('yogstation/icons/mob/sling.dmi', "eyes", 25)
	C.add_overlay(eyes_overlay)
	. = ..()

/datum/species/shadow/ling/on_species_loss(mob/living/carbon/human/C)
	C.draw_yogs_parts(FALSE)
	if(eyes_overlay)
		C.cut_overlay(eyes_overlay)
		QDEL_NULL(eyes_overlay)
	. = ..()

/datum/species/shadow/ling/spec_life(mob/living/carbon/human/H)
	H.nutrition = NUTRITION_LEVEL_WELL_FED //i aint never get hongry
	if(isturf(H.loc))
		var/turf/T = H.loc
		var/light_amount = T.get_lumcount()
		if(light_amount > LIGHT_DAM_THRESHOLD) //Can survive in very small light levels. Also doesn't take damage while incorporeal, for shadow walk purposes
			H.take_overall_damage(0, LIGHT_DAMAGE_TAKEN)
			if(H.stat != DEAD)
				to_chat(H, "<span class='userdanger'>The light burns you!</span>") //Message spam to say "GET THE FUCK OUT"
				H.playsound_local(get_turf(H), 'sound/weapons/sear.ogg', 150, 1, pressure_affected = FALSE)
		else if (light_amount < LIGHT_HEAL_THRESHOLD)
			H.heal_overall_damage(5,5)
			H.adjustToxLoss(-5)
			H.adjustBrainLoss(-25) //Shad O. Ling gibbers, "CAN U BE MY THRALL?!!"
			H.adjustCloneLoss(-1)
			H.SetKnockdown(0)
			H.SetStun(0)
	var/charge_time = 400 - ((SSticker.mode.thralls && SSticker.mode.thralls.len) || 0)*10
	if(world.time >= charge_time+last_charge)
		shadow_charges = min(shadow_charges + 1, 3)
		last_charge = world.time

/datum/species/shadow/ling/bullet_act(obj/item/projectile/P, mob/living/carbon/human/H)
	var/turf/T = H.loc
	if(istype(T) && shadow_charges > 0)
		var/light_amount = T.get_lumcount()
		if(light_amount < LIGHT_DAM_THRESHOLD)
			H.visible_message("<span class='danger'>The shadows around [H] ripple as they absorb \the [P]!</span>")
			playsound(T, "bullet_miss", 75, 1)
			shadow_charges = min(shadow_charges - 1, 0)
			return -1
	return 0

/datum/species/shadow/ling/lesser //Empowered thralls. Obvious, but powerful
	name = "Lesser Shadowling"
	id = "l_shadowling"
	say_mod = "chitters"
	species_traits = list(NOBLOOD,NO_DNA_COPY,NOTRANSSTING,NOEYES)
	inherent_traits = list(TRAIT_NOBREATH, TRAIT_RADIMMUNE)
	burnmod = 1.1
	heatmod = 1.1

/datum/species/shadow/ling/lesser/spec_life(mob/living/carbon/human/H)
	H.nutrition = NUTRITION_LEVEL_WELL_FED //i aint never get hongry
	if(isturf(H.loc))
		var/turf/T = H.loc
		var/light_amount = T.get_lumcount()
		if(light_amount > LIGHT_DAM_THRESHOLD && !H.incorporeal_move)
			H.take_overall_damage(0, LIGHT_DAMAGE_TAKEN/2)
		else if (light_amount < LIGHT_HEAL_THRESHOLD)
			H.heal_overall_damage(2,2)
			H.adjustToxLoss(-5)
			H.adjustBrainLoss(-25)
			H.adjustCloneLoss(-1)

/datum/game_mode/proc/update_shadow_icons_added(datum/mind/shadow_mind)
	var/datum/atom_hud/antag/shadow_hud = GLOB.huds[ANTAG_HUD_SHADOW]
	shadow_hud.join_hud(shadow_mind.current)
	set_antag_hud(shadow_mind.current, ((is_shadow(shadow_mind.current)) ? "shadowling" : "thrall"))

/datum/game_mode/proc/update_shadow_icons_removed(datum/mind/shadow_mind)
	var/datum/atom_hud/antag/shadow_hud = GLOB.huds[ANTAG_HUD_SHADOW]
	shadow_hud.leave_hud(shadow_mind.current)
	set_antag_hud(shadow_mind.current, null)

/mob/living/proc/add_thrall()
	if(!istype(mind))
		return FALSE
	return mind.add_antag_datum(ANTAG_DATUM_THRALL)

/mob/living/proc/add_sling()
	if(!istype(mind))
		return FALSE
	return mind.add_antag_datum(ANTAG_DATUM_SLING)

/mob/living/proc/remove_thrall()
	if(!istype(mind))
		return FALSE
	return mind.remove_antag_datum(ANTAG_DATUM_THRALL)

/mob/living/proc/remove_sling()
	if(!istype(mind))
		return FALSE
	return mind.remove_antag_datum(ANTAG_DATUM_SLING) 
