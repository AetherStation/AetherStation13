/* Cards
 * Contains:
 * DATA CARD
 * ID CARD
 * FINGERPRINT CARD HOLDER
 * FINGERPRINT CARD
 */



/*
 * DATA CARDS - Used for the IC data card reader
 */

/obj/item/card
	name = "card"
	desc = "Does card things."
	icon = 'icons/obj/card.dmi'
	w_class = WEIGHT_CLASS_TINY

	var/list/files = list()

/obj/item/card/suicide_act(mob/living/carbon/user)
	user.visible_message(span_suicide("[user] begins to swipe [user.p_their()] neck with \the [src]! It looks like [user.p_theyre()] trying to commit suicide!"))
	return BRUTELOSS

/obj/item/card/data
	name = "data card"
	desc = "A plastic magstripe card for simple and speedy data storage and transfer. This one has a stripe running down the middle."
	icon_state = "data_1"
	obj_flags = UNIQUE_RENAME
	var/function = "storage"
	var/data = "null"
	var/special = null
	inhand_icon_state = "card-id"
	lefthand_file = 'icons/mob/inhands/equipment/idcards_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/idcards_righthand.dmi'
	var/detail_color = COLOR_ASSEMBLY_ORANGE

/obj/item/card/data/Initialize()
	.=..()
	update_appearance()

/obj/item/card/data/update_overlays()
	. = ..()
	if(detail_color == COLOR_FLOORTILE_GRAY)
		return
	var/mutable_appearance/detail_overlay = mutable_appearance('icons/obj/card.dmi', "[icon_state]-color")
	detail_overlay.color = detail_color
	. += detail_overlay

/obj/item/card/data/full_color
	desc = "A plastic magstripe card for simple and speedy data storage and transfer. This one has the entire card colored."
	icon_state = "data_2"

/obj/item/card/data/disk
	desc = "A plastic magstripe card for simple and speedy data storage and transfer. This one inexplicibly looks like a floppy disk."
	icon_state = "data_3"

/*
 * ID CARDS
 */

/obj/item/card/id
	name = "identification card"
	desc = "A card used to provide ID and determine access across the station."
	icon_state = "tier1"
	inhand_icon_state = "card-id"
	lefthand_file = 'icons/mob/inhands/equipment/idcards_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/idcards_righthand.dmi'
	slot_flags = ITEM_SLOT_ID
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 100, ACID = 100)
	resistance_flags = FIRE_PROOF | ACID_PROOF

	/// Cached icon that has been built for this card. Intended for use in chat.
	var/icon/cached_flat_icon

	// Card access
	var/datum/card_access/card_access

	/// How many magical mining Disney Dollars this card has for spending at the mining equipment vendors.
	var/mining_points = 0
	/// The name registered on the card (for example: Dr Bryan See)
	var/registered_name = null
	/// Linked bank account.
	var/datum/bank_account/registered_account
	/// Linked paystand.
	var/obj/machinery/paystand/my_store
	/// Registered owner's age.
	var/registered_age = 30

	/// The job name registered on the card (for example: Assistant).
	var/assignment

	/// Highest allowed access tier for this card.
	var/access_tier = 0

	/// How many additional access chips can this ID card have?
	var/chip_slots = 0

	/// List of installed additional access chips.
	var/list/chips = list()

	/// Access levels held by this card.
	var/list/access = list()

	/// Access levels that shouldn't be modifiable normally.
	var/list/additional_access = list()

/obj/item/card/id/Initialize(mapload)
	. = ..()
	if (card_access)
		SSid_access.apply_card_access(src, card_access, force = TRUE)

	update_icon(UPDATE_OVERLAYS)
	update_label()

	RegisterSignal(src, COMSIG_ATOM_UPDATED_ICON, PROC_REF(update_in_wallet))

/obj/item/card/id/Destroy()
	if (registered_account)
		registered_account.bank_cards -= src
	if (my_store && my_store.my_card == src)
		my_store.my_card = null
	return ..()

/obj/item/card/id/get_id_examine_strings(mob/user)
	. = ..()
	. += list("[icon2html(get_cached_flat_icon(), user, extra_classes = "bigicon")]")

/obj/item/card/id/update_overlays()
	. = ..()
	if (chip_slots)
		. += "chip[min(chips.len, 2)]"
		cached_flat_icon = null

/// If no cached_flat_icon exists, this proc creates it and crops it. This proc then returns the cached_flat_icon. Intended only for use displaying ID card icons in chat.
/obj/item/card/id/proc/get_cached_flat_icon()
	if(!cached_flat_icon)
		cached_flat_icon = getFlatIcon(src)
	return cached_flat_icon

/obj/item/card/id/get_examine_string(mob/user, thats = FALSE)
	return "[icon2html(get_cached_flat_icon(), user)] [thats? "That's ":""][get_examine_name(user)]"

/**
 * Attempts to add the given accesses to the ID card.
 *
 * Arguments:
 * * add_accesses - List of accesses to add.
 */
/obj/item/card/id/proc/add_access(list/add_accesses, ignore_tier = FALSE)
	if (!ignore_tier)
		for (var/a in add_accesses)
			if (text2num(SSid_access.get_access_tier(a)) > access_tier)
				add_accesses -= a
	access |= add_accesses
	return add_accesses.len

/**
 * Removes the given accesses from the ID Card.
 *
 * Arguments:
 * * rem_accesses - List of accesses to remove.
 */
/obj/item/card/id/proc/remove_access(list/rem_accesses)
	access -= rem_accesses

/**
 * Attempts to set the card's accesses to the given accesses, clearing all accesses not in the given list.
 *
 * Arguments:
 * * new_access_list - List of all accesses that this card should hold exclusively.
 */
/obj/item/card/id/proc/set_access(list/new_access_list)
	clear_access()

	access = new_access_list.Copy()

	return TRUE

/// Clears all accesses from the ID card
/obj/item/card/id/proc/clear_access()
	access.Cut()

/// Clears the economy account from the ID card.
/obj/item/card/id/proc/clear_account()
	registered_account = null

/obj/item/card/id/attack_self(mob/user)
	if(Adjacent(user))
		var/minor
		if(registered_name && registered_age && registered_age < AGE_MINOR)
			minor = " <b>(MINOR)</b>"
		user.visible_message(span_notice("[user] shows you: [icon2html(src, viewers(user))] [src.name][minor]."), span_notice("You show \the [src.name][minor]."))
	add_fingerprint(user)

/obj/item/card/id/vv_edit_var(var_name, var_value)
	. = ..()
	if(.)
		switch(var_name)
			if(NAMEOF(src, assignment), NAMEOF(src, registered_name), NAMEOF(src, registered_age))
				update_label()

/obj/item/card/id/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/rupee))
		to_chat(user, span_warning("Your ID smartly rejects the strange shard of glass. Who knew, apparently it's not ACTUALLY valuable!"))
		return
	else if(iscash(W))
		insert_money(W, user)
		return
	else if(istype(W, /obj/item/storage/bag/money))
		var/obj/item/storage/bag/money/money_bag = W
		var/list/money_contained = money_bag.contents
		var/money_added = mass_insert_money(money_contained, user)
		if (money_added)
			to_chat(user, span_notice("You stuff the contents into the card! They disappear in a puff of bluespace smoke, adding [money_added] worth of credits to the linked account."))
		return
	else if (istype(W, /obj/item/card_access_chip))
		if (chips.len >= chip_slots)
			to_chat(user, span_notice("There is not enough space to install this."))
		else
			to_chat(user, span_notice("You slot the [W] into the ID card."))
			apply_access_chip(W)
			update_appearance(UPDATE_OVERLAYS)
		return
	else if (W.tool_behaviour == TOOL_SCREWDRIVER && chips.len)
		var/chip = chips[chips.len]
		to_chat(user, span_notice("You remove [chip] from the card."))
		remove_access_chip(chip, user) // remove last in list
		update_appearance(UPDATE_OVERLAYS)
		return
	else
		return ..()

/obj/item/card/id/proc/apply_access_chip(obj/item/card_access_chip/C)
	C.apply_access(src)
	C.forceMove(src)
	chips += C

/obj/item/card/id/proc/remove_access_chip(obj/item/card_access_chip/C, mob/user)
	C.remove_access(src)
	if (!user?.put_in_hands(C))
		C.forceMove(get_turf(src))
	chips -= C

/**
 * Insert credits or coins into the ID card and add their value to the associated bank account.
 *
 * Arguments:
 * money - The item to attempt to convert to credits and insert into the card.
 * user - The user inserting the item.
 * physical_currency - Boolean, whether this is a physical currency such as a coin and not a holochip.
 */
/obj/item/card/id/proc/insert_money(obj/item/money, mob/user)
	var/physical_currency
	if(istype(money, /obj/item/stack/spacecash) || istype(money, /obj/item/coin))
		physical_currency = TRUE

	if(!registered_account)
		to_chat(user, span_warning("[src] doesn't have a linked account to deposit [money] into!"))
		return
	var/cash_money = money.get_item_credit_value()
	if(!cash_money)
		to_chat(user, span_warning("[money] doesn't seem to be worth anything!"))
		return
	registered_account.adjust_money(cash_money)
	SSblackbox.record_feedback("amount", "credits_inserted", cash_money)
	log_econ("[cash_money] credits were inserted into [src] owned by [src.registered_name]")
	if(physical_currency)
		to_chat(user, span_notice("You stuff [money] into [src]. It disappears in a small puff of bluespace smoke, adding [cash_money] credits to the linked account."))
	else
		to_chat(user, span_notice("You insert [money] into [src], adding [cash_money] credits to the linked account."))

	to_chat(user, span_notice("The linked account now reports a balance of [registered_account.account_balance] cr."))
	qdel(money)

/**
 * Insert multiple money or money-equivalent items at once.
 *
 * Arguments:
 * money - List of items to attempt to convert to credits and insert into the card.
 * user - The user inserting the items.
 */
/obj/item/card/id/proc/mass_insert_money(list/money, mob/user)
	if(!registered_account)
		to_chat(user, span_warning("[src] doesn't have a linked account to deposit into!"))
		return FALSE

	if (!money || !money.len)
		return FALSE

	var/total = 0

	for (var/obj/item/physical_money in money)
		total += physical_money.get_item_credit_value()
		CHECK_TICK

	registered_account.adjust_money(total)
	SSblackbox.record_feedback("amount", "credits_inserted", total)
	log_econ("[total] credits were inserted into [src] owned by [src.registered_name]")
	QDEL_LIST(money)

	return total

/// Helper proc. Can the user alt-click the ID?
/obj/item/card/id/proc/alt_click_can_use_id(mob/living/user)
	if(!isliving(user))
		return
	if(!user.canUseTopic(src, BE_CLOSE, FALSE, NO_TK))
		return

	return TRUE

/// Attempts to set a new bank account on the ID card.
/obj/item/card/id/proc/set_new_account(mob/living/user)
	. = FALSE
	var/datum/bank_account/old_account = registered_account

	var/new_bank_id = input(user, "Enter your account ID number.", "Account Reclamation", 111111) as num | null

	if (isnull(new_bank_id))
		return

	if(!alt_click_can_use_id(user))
		return
	if(!new_bank_id || new_bank_id < 111111 || new_bank_id > 999999)
		to_chat(user, span_warning("The account ID number needs to be between 111111 and 999999."))
		return
	if (registered_account && registered_account.account_id == new_bank_id)
		to_chat(user, span_warning("The account ID was already assigned to this card."))
		return

	var/datum/bank_account/B = SSeconomy.bank_accounts_by_id["[new_bank_id]"]
	if(B)
		if (old_account)
			old_account.bank_cards -= src

		B.bank_cards += src
		registered_account = B
		to_chat(user, span_notice("The provided account has been linked to this ID card."))

		return TRUE

	to_chat(user, span_warning("The account ID number provided is invalid."))
	return

/obj/item/card/id/AltClick(mob/living/user)
	if(!alt_click_can_use_id(user))
		return

	if(!registered_account)
		set_new_account(user)
		return

	if (registered_account.being_dumped)
		registered_account.bank_card_talk(span_warning("内部服务器错误"), TRUE)
		return

	var/amount_to_remove =  FLOOR(input(user, "How much do you want to withdraw? Current Balance: [registered_account.account_balance]", "Withdraw Funds", 5) as num|null, 1)

	if(!amount_to_remove || amount_to_remove < 0)
		return
	if(!alt_click_can_use_id(user))
		return
	if(registered_account.adjust_money(-amount_to_remove))
		var/obj/item/holochip/holochip = new (user.drop_location(), amount_to_remove)
		user.put_in_hands(holochip)
		to_chat(user, span_notice("You withdraw [amount_to_remove] credits into a holochip."))
		SSblackbox.record_feedback("amount", "credits_removed", amount_to_remove)
		log_econ("[amount_to_remove] credits were removed from [src] owned by [src.registered_name]")
		return
	else
		var/difference = amount_to_remove - registered_account.account_balance
		registered_account.bank_card_talk(span_warning("ERROR: The linked account requires [difference] more credit\s to perform that withdrawal."), TRUE)

/obj/item/card/id/examine(mob/user)
	. = ..()
	if(registered_account)
		. += "The account linked to the ID belongs to '[registered_account.account_holder]' and reports a balance of [registered_account.account_balance] cr."
	if (chips.len)
		. += "There [chips.len == 1 ? "is an AA-chip" : "are [chips.len] AA-chips"] installed."
	. += span_notice("<i>There's more information below, you can look again to take a closer look...</i>")

/obj/item/card/id/examine_more(mob/user)
	var/list/msg = list(span_notice("<i>You examine [src] closer, and note the following...</i>"))
	msg += "The card has an access tier of [access_tier]."
	if(registered_age)
		msg += "The card indicates that the holder is [registered_age] years old. [(registered_age < AGE_MINOR) ? "There's a holographic stripe that reads <b>[span_danger("'MINOR: DO NOT SERVE ALCOHOL OR TOBACCO'")]</b> along the bottom of the card." : ""]"
	if(mining_points)
		msg += "There's [mining_points] mining equipment redemption point\s loaded onto this card."
	if(registered_account)
		msg += "The account linked to the ID belongs to '[registered_account.account_holder]' and reports a balance of [registered_account.account_balance] cr."
		if(registered_account.account_job)
			var/datum/bank_account/D = SSeconomy.get_dep_account(registered_account.account_job.paycheck_department)
			if(D)
				msg += "The [D.account_holder] reports a balance of [D.account_balance] cr."
		msg += span_info("Alt-Click the ID to pull money from the linked account in the form of holochips.")
		msg += span_info("You can insert credits into the linked account by pressing holochips, cash, or coins against the ID.")
		if(registered_account.civilian_bounty)
			msg += "<span class='info'><b>There is an active civilian bounty.</b>"
			msg += span_info("<i>[registered_account.bounty_text()]</i>")
			msg += span_info("Quantity: [registered_account.bounty_num()]")
			msg += span_info("Reward: [registered_account.bounty_value()]")
		if(registered_account.account_holder == user.real_name)
			msg += span_boldnotice("If you lose this ID card, you can reclaim your account by Alt-Clicking a blank ID card while holding it and entering your account ID number.")
	else
		msg += span_info("There is no registered account linked to this card. Alt-Click to add one.")

	return msg

//XXX: Cache the result if this somehow ends up being too slow, var/list/cached_access or something like that.
/obj/item/card/id/get_access()
	return access + additional_access

/obj/item/card/id/get_id()
	return src

/obj/item/card/id/remove_id()
	return src

/// Called on COMSIG_ATOM_UPDATED_ICON. Updates the visuals of the wallet this card is in.
/obj/item/card/id/proc/update_in_wallet()
	SIGNAL_HANDLER

	if(istype(loc, /obj/item/storage/wallet))
		var/obj/item/storage/wallet/powergaming = loc
		if(powergaming.front_id == src)
			powergaming.update_label()
			powergaming.update_appearance()

/// Updates the name based on the card's vars and state.
/obj/item/card/id/proc/update_label()
	var/name_string = registered_name ? "[registered_name]'s ID Card" : initial(name)
	name = "[name_string] ([assignment])"

/obj/item/card/id/tier0
	icon_state = "tier0"
	access_tier = 0

/obj/item/card/id/tier1
	icon_state = "tier1"
	chip_slots = 2
	access_tier = 1

/obj/item/card/id/tier2
	icon_state = "tier2"
	chip_slots = 2
	access_tier = 2

/obj/item/card/id/tier3
	icon_state = "tier3"
	chip_slots = 2
	access_tier = 3

/obj/item/card/id/tier4
	icon_state = "tier4"
	chip_slots = 2
	access_tier = 4

/obj/item/card/id/tier5
	name = "gold identification card"
	desc = "A golden card which shows power and might."
	icon_state = "tier5"
	chip_slots = 2
	access_tier = 5

/obj/item/card/id/away
	name = "\proper a perfectly generic identification card"
	desc = "A perfectly generic identification card. Looks like it could use some flavor."
	icon_state = "card_retro"
	registered_age = null
	card_access = /datum/card_access/away

/obj/item/card/id/away/hotel
	name = "Staff ID"
	desc = "A staff ID used to access the hotel's doors."
	card_access = /datum/card_access/away/hotel

/obj/item/card/id/away/hotel/security
	name = "Officer ID"
	card_access = /datum/card_access/away/hotel/security

/obj/item/card/id/away/old
	name = "\proper a perfectly generic identification card"
	desc = "A perfectly generic identification card. Looks like it could use some flavor."

/obj/item/card/id/away/old/sec
	name = "Charlie Station Security Officer's ID card"
	desc = "A faded Charlie Station ID card. You can make out the rank \"Security Officer\"."
	card_access = /datum/card_access/away/old/sec

/obj/item/card/id/away/old/sci
	name = "Charlie Station Scientist's ID card"
	desc = "A faded Charlie Station ID card. You can make out the rank \"Scientist\"."
	card_access = /datum/card_access/away/old/sci

/obj/item/card/id/away/old/eng
	name = "Charlie Station Engineer's ID card"
	desc = "A faded Charlie Station ID card. You can make out the rank \"Station Engineer\"."
	card_access = /datum/card_access/away/old/eng

/obj/item/card/id/away/old/apc
	name = "APC Access ID"
	desc = "A special ID card that allows access to APC terminals."
	card_access = /datum/card_access/away/old/apc

/obj/item/card/id/away/deep_storage //deepstorage.dmm space ruin
	name = "bunker access ID"

/obj/item/card/id/departmental_budget
	name = "departmental card (ERROR)"
	desc = "Provides access to the departmental budget."
	icon_state = "budgetcard"
	var/department_ID = ACCOUNT_CIV
	var/department_name = ACCOUNT_CIV_NAME
	registered_age = null

/obj/item/card/id/departmental_budget/Initialize()
	. = ..()
	var/datum/bank_account/B = SSeconomy.get_dep_account(department_ID)
	if(B)
		registered_account = B
		if(!B.bank_cards.Find(src))
			B.bank_cards += src
		name = "departmental card ([department_name])"
		desc = "Provides access to the [department_name]."
	SSeconomy.dep_cards += src

/obj/item/card/id/departmental_budget/Destroy()
	SSeconomy.dep_cards -= src
	return ..()

/obj/item/card/id/departmental_budget/update_label()
	return

/obj/item/card/id/departmental_budget/car
	department_ID = ACCOUNT_CAR
	department_name = ACCOUNT_CAR_NAME
	icon_state = "car_budget" //saving up for a new tesla

/obj/item/card/id/departmental_budget/AltClick(mob/living/user)
	registered_account.bank_card_talk(span_warning("Withdrawing is not compatible with this card design."), TRUE) //prevents the vault bank machine being useless and putting money from the budget to your card to go over personal crates

/obj/item/card/id/reaper
	name = "Thirteen's ID Card (Reaper)"
	registered_name = "Thirteen"
	icon_state = "tier4"
	inhand_icon_state = "silver_id"

/obj/item/card/id/tier5/captains_spare
	name = "captain's spare ID"
	desc = "The spare ID of the High Lord himself."
	registered_name = "Captain"
	registered_age = null
	card_access = /datum/card_access/job/captain

/obj/item/card/id/tier5/captains_spare/update_label() //so it doesn't change to Captain's ID card (Captain) on a sneeze
	if(registered_name == "Captain")
		name = "[initial(name)][(!assignment || assignment == "Captain") ? "" : " ([assignment])"]"
	else
		..()

/obj/item/card/id/centcom
	name = "\improper CentCom ID"
	desc = "An ID straight from Central Command."
	icon_state = "card_centcom"
	registered_name = "Central Command"
	registered_age = null

/obj/item/card/id/centcom/ert
	name = "\improper CentCom ID"
	desc = "An ERT ID card."

/obj/item/card/id/black
	name = "black identification card"
	desc = "This card is telling you one thing and one thing alone. The person holding this card is an utter badass."
	icon_state = "card_black"

/obj/item/card/id/black/deathsquad
	name = "\improper Death Squad ID"
	desc = "A Death Squad ID card."
	registered_name = "Death Commando"

/obj/item/card/id/black/syndicate_command
	name = "syndicate ID card"
	desc = "An ID straight from the Syndicate."
	registered_name = "Syndicate"
	registered_age = null

/obj/item/card/id/debug
	name = "\improper Debug ID"
	desc = "A debug ID card. Has ALL the all access, you really shouldn't have this."
	icon_state = "card_centcom"
	card_access = /datum/card_access/admin
	access_tier = 6

/obj/item/card/id/debug/Initialize()
	. = ..()
	registered_account = SSeconomy.get_dep_account(ACCOUNT_CAR)

/obj/item/card/id/prisoner
	name = "prisoner ID card"
	desc = "You are a number, you are not a free man."
	icon_state = "card_prisoner"
	inhand_icon_state = "orange-id"
	lefthand_file = 'icons/mob/inhands/equipment/idcards_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/idcards_righthand.dmi'
	registered_name = "Scum"
	registered_age = null

	/// Number of gulag points required to earn freedom.
	var/goal = 0
	/// Number of gulag points earned.
	var/points = 0

/obj/item/card/id/prisoner/attack_self(mob/user)
	to_chat(usr, span_notice("You have accumulated [points] out of the [goal] points you need for freedom."))

/obj/item/card/id/prisoner/one
	name = "Prisoner #13-001"
	registered_name = "Prisoner #13-001"

/obj/item/card/id/prisoner/two
	name = "Prisoner #13-002"
	registered_name = "Prisoner #13-002"

/obj/item/card/id/prisoner/three
	name = "Prisoner #13-003"
	registered_name = "Prisoner #13-003"

/obj/item/card/id/prisoner/four
	name = "Prisoner #13-004"
	registered_name = "Prisoner #13-004"

/obj/item/card/id/prisoner/five
	name = "Prisoner #13-005"
	registered_name = "Prisoner #13-005"

/obj/item/card/id/prisoner/six
	name = "Prisoner #13-006"
	registered_name = "Prisoner #13-006"

/obj/item/card/id/prisoner/seven
	name = "Prisoner #13-007"
	registered_name = "Prisoner #13-007"

/obj/item/card/id/mining
	name = "mining ID"
	access_tier = 2
	card_access = /datum/card_access/job/shaft_miner/spare

/obj/item/card/id/highlander
	name = "highlander ID"
	registered_name = "Highlander"
	desc = "There can be only one!"
	icon_state = "card_black"
	card_access = /datum/card_access/highlander

/obj/item/card/id/chameleon
	name = "agent card"
	desc = "A highly advanced chameleon ID card. Touch this card on another ID card or human to choose which accesses to copy. Has special magnetic properties which force it to the front of wallets."
	card_access = /datum/card_access/chameleon
	access_tier = 5
	/// Have we set a custom name and job assignment, or will we use what we're given when we chameleon change?
	var/forged = FALSE

/obj/item/card/id/chameleon/Initialize()
	. = ..()

	var/datum/action/item_action/chameleon/change/id/chameleon_card_action = new(src)
	chameleon_card_action.chameleon_type = /obj/item/card/id
	chameleon_card_action.chameleon_name = "ID Card"
	chameleon_card_action.initialize_disguises()

/obj/item/card/id/chameleon/afterattack(atom/target, mob/user, proximity)
	if(!proximity)
		return

	if(istype(target, /obj/item/card/id))
		var/obj/item/card/id/id = target
		access |= id.get_access()
		to_chat(user, span_notice("You successfully sync your [src] with \the [id]."))
		return

	return ..()

/obj/item/card/id/chameleon/pre_attack_secondary(atom/target, mob/living/user, params)
	// If we're attacking a human, we want it to be covert. We're not ATTACKING them, we're trying
	// to sneakily steal their accesses by swiping our agent ID card near them. As a result, we
	// return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN to cancel any part of the following the attack chain.
	if(istype(target, /mob/living/carbon/human))
		to_chat(user, span_notice("You covertly start to scan [target] with \the [src], hoping to pick up a wireless ID card signal..."))

		if(!do_mob(user, target, 2 SECONDS))
			to_chat(user, span_notice("The scan was interrupted."))
			return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

		var/mob/living/carbon/human/human_target = target

		var/list/target_id_cards = human_target.get_all_contents_type(/obj/item/card/id)

		if(!length(target_id_cards))
			to_chat(user, span_notice("The scan failed to locate any ID cards."))
			return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

		var/obj/item/card/id/selected_id = pick(target_id_cards)
		to_chat(user, span_notice("You successfully sync your [src] with \the [selected_id]."))
		access |= selected_id.get_access()
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

	if(istype(target, /obj/item))
		var/obj/item/target_item = target

		to_chat(user, span_notice("You covertly start to scan [target] with your [src], hoping to pick up a wireless ID card signal..."))

		var/list/target_id_cards = target_item.get_all_contents_type(/obj/item/card/id)

		if(!length(target_id_cards))
			to_chat(user, span_notice("The scan failed to locate any ID cards.</span>"))
			return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

		var/obj/item/card/id/selected_id = pick(target_id_cards)
		to_chat(user, span_notice("You successfully sync your [src] with \the [selected_id]."))
		access |= selected_id.get_access()
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

	return ..()

/obj/item/card/id/chameleon/attack_self(mob/user)
	if(isliving(user) && user.mind)
		var/popup_input = tgui_alert(user, "Choose Action", "Agent ID", list("Show", "Forge/Reset", "Change Account ID"))
		if(user.incapacitated())
			return
		if(!user.is_holding(src))
			return
		if(popup_input == "Forge/Reset")
			if(!forged)
				var/input_name = stripped_input(user, "What name would you like to put on this card? Leave blank to randomise.", "Agent card name", registered_name ? registered_name : (ishuman(user) ? user.real_name : user.name), MAX_NAME_LEN)
				input_name = sanitize_name(input_name)
				if(!input_name)
					// Invalid/blank names give a randomly generated one.
					if(user.gender == MALE)
						input_name = "[pick(GLOB.first_names_male)] [pick(GLOB.last_names)]"
					else if(user.gender == FEMALE)
						input_name = "[pick(GLOB.first_names_female)] [pick(GLOB.last_names)]"
					else
						input_name = "[pick(GLOB.first_names)] [pick(GLOB.last_names)]"

				registered_name = input_name
				var/target_occupation = stripped_input(user, "What occupation would you like to put on this card?\nNote: This will not grant any access levels.", "Agent card job assignment", assignment ? assignment : "Assistant", MAX_MESSAGE_LEN)
				if(target_occupation)
					assignment = target_occupation

				var/new_age = input(user, "Choose the ID's age:\n([AGE_MIN]-[AGE_MAX])", "Agent card age") as num|null
				if(new_age)
					registered_age = max(round(text2num(new_age)), 0)

				if(tgui_alert(user, "Activate wallet ID spoofing, allowing this card to force itself to occupy the visible ID slot in wallets?", "Wallet ID Spoofing", list("Yes", "No")) == "Yes")
					ADD_TRAIT(src, TRAIT_MAGNETIC_ID_CARD, CHAMELEON_ITEM_TRAIT)

				update_label()
				update_icon()
				forged = TRUE
				to_chat(user, span_notice("You successfully forge the ID card."))
				log_game("[key_name(user)] has forged \the [initial(name)] with name \"[registered_name]\", occupation \"[assignment]\".")

				if(!registered_account)
					if(ishuman(user))
						var/mob/living/carbon/human/accountowner = user

						var/datum/bank_account/account = SSeconomy.bank_accounts_by_id["[accountowner.account_id]"]
						if(account)
							account.bank_cards += src
							registered_account = account
							to_chat(user, span_notice("Your account number has been automatically assigned."))
				return
			if(forged)
				registered_name = initial(registered_name)
				assignment = initial(assignment)
				REMOVE_TRAIT(src, TRAIT_MAGNETIC_ID_CARD, CHAMELEON_ITEM_TRAIT)
				log_game("[key_name(user)] has reset \the [initial(name)] named \"[src]\" to default.")
				update_label()
				update_icon()
				forged = FALSE
				to_chat(user, span_notice("You successfully reset the ID card."))
				return
		if (popup_input == "Change Account ID")
			set_new_account(user)
			return
	return ..()

/obj/item/card/id/chameleon/black
	icon_state = "card_black"

/obj/item/card/id/engioutpost
	registered_name = "George 'Plastic' Miller"
	desc = "A card used to provide ID and determine access across the station. There's blood dripping from the corner. Ew."
	registered_age = 47

/obj/item/card/id/simple_bot
	name = "simple bot ID card"
	desc = "An internal ID card used by the station's non-sentient bots. You should report this to a coder if you're holding it."

/obj/item/card/id/red
	name = "Red Team identification card"
	desc = "A card used to identify members of the red team for CTF"
	icon_state = "ctf_red"

/obj/item/card/id/blue
	name = "Blue Team identification card"
	desc = "A card used to identify members of the blue team for CTF"
	icon_state = "ctf_blue"

/obj/item/card/id/yellow
	name = "Yellow Team identification card"
	desc = "A card used to identify members of the yellow team for CTF"
	icon_state = "ctf_yellow"

/obj/item/card/id/green
	name = "Green Team identification card"
	desc = "A card used to identify members of the green team for CTF"
	icon_state = "ctf_green"

/obj/item/card/id/chip_programmer
	name = "additional access chip programmer"
	desc = "A card used to program new access chips."
	icon_state = "tier1"
	chip_slots = 1

/obj/item/card/id/chip_programmer/update_label()
	return // noope

/obj/item/card/id/chip_programmer/attack_self(mob/user)
	var/chip = chips[chips.len]
	to_chat(user, span_notice("You remove [chip] from \the [src]."))
	remove_access_chip(chip, user) // remove last in list
	update_appearance(UPDATE_OVERLAYS)
	add_fingerprint(user)

/obj/item/card/id/chip_programmer/apply_access_chip(obj/item/card_access_chip/C)
	access += C.access
	access_tier = C.access_tier
	C.forceMove(src)
	chips += C

/obj/item/card/id/chip_programmer/remove_access_chip(obj/item/card_access_chip/C, mob/user)
	access = list()
	access_tier = 0
	if (!user?.put_in_hands(C))
		C.forceMove(get_turf(src))
	chips -= C

/obj/item/card/id/chip_programmer/add_access(list/add_accesses, ignore_tier = FALSE)
	var/obj/item/card_access_chip/C = chips[1]
	if (!C.rewritable)
		return FALSE

	if (!ignore_tier)
		for (var/a in add_accesses)
			if (text2num(SSid_access.get_access_tier(a)) > access_tier)
				add_accesses -= a

	if (add_accesses.len >= C.access_count_max - C.access.len)
		add_accesses.len = C.access_count_max - C.access.len // make the list small enough to fit
	access |= add_accesses
	C.access |= add_accesses
	return add_accesses.len

/obj/item/card/id/chip_programmer/remove_access(list/rem_accesses)
	var/obj/item/card_access_chip/C = chips[1]
	if (!C.rewritable)
		return FALSE
	access -= rem_accesses
	C.access -= rem_accesses

/obj/item/card/id/chip_programmer/clear_access()
	var/obj/item/card_access_chip/C = chips[1]
	if (!C.rewritable)
		return FALSE
	C.access.Cut()
	access.Cut()
