/obj/item/cyberlink_connector
	name = "Wireless personal connector"
	desc = "Allows you to connect to crack the implants reducing their neural stress impact but also forfeiting their discount from matching cyberlink classes."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "connector"
	var/list/datum/hacking_minigame/game_list = list()
	var/current_timer_id = FALSE
	var/obj/item/organ/cyberimp/cybernetic
	var/mob/living/current_user

/obj/item/cyberlink_connector/Destroy()
	. = ..()
	cleanup()

///We dont open the tgui when we click on this.
/obj/item/cyberlink_connector/interact(mob/user)
	add_fingerprint(user)

/obj/item/cyberlink_connector/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(!proximity_flag)
		return

	if(!istype(target,/obj/item/organ/cyberimp) || istype(target,/obj/item/organ/cyberimp/cyberlink))
		return

	game_list = list()


	current_user = user
	cybernetic = target

	var/diffrences = GLOB.implant_class_tiers[cybernetic.implant_class]

	if(diffrences == 0)
		to_chat(current_user,"<span class='notice'> Cyberlink beeps: [uppertext(cybernetic.name)] ALREADY CRACKED.</span>")
		cleanup()
		return

	if(!game_list.len)
		for(var/i in 1 to diffrences)
			var/datum/hacking_minigame/game = new/datum/hacking_minigame()
			game.generate()
			game_list += game

	ui_interact(user)

/obj/item/cyberlink_connector/proc/cleanup()
	current_user = null
	cybernetic = null
	QDEL_LIST(game_list)
	deltimer(current_timer_id)
	current_timer_id = FALSE

/obj/item/cyberlink_connector/proc/hack_success(success as num)
	cybernetic.implant_class = CYBER_CLASS_CRACKED
	current_user.mind.adjust_experience(/datum/skill/implant_hacking,success * 25)
	to_chat(current_user,"<span class='notice'> Cyberlink beeps: HACKING [uppertext(cybernetic.name)] SUCCESS. COMPATIBILITY ACHIEVED.</span>")
	cleanup()

/obj/item/cyberlink_connector/proc/hack_failure(failed as num)
	var/chance = rand(0,40*failed)
	switch(chance)
		if(0 to 25)
			to_chat(current_user,"<span class='warning'> Cyberlink beeps: HACKING [uppertext(cybernetic.name)] MINOR FAILURE. CRACKING PROCESS ABORTED.</span>")
		if(26 to 40)
			to_chat(current_user,"<span class='warning'> Cyberlink beeps: HACKING [uppertext(cybernetic.name)] MEDIUM FAILURE. CRACKING PROCESS ABORTED. SMALL AMOUNT OF DAMAGE DETECTED.</span>")
			current_user.adjustFireLoss(10)
			current_user.emote("scream")
		if(41 to 50)
			to_chat(current_user,"<span class='warning'> Cyberlink beeps: HACKING [uppertext(cybernetic.name)] MEDIUM FAILURE. CRACKING PROCESS ABORTED. IMPLANT MOTHER BOARD DAMAGED, NEUROLOGICAL STRESS IMPACT AFFECTED.</span>")
			cybernetic.implant_class = CYBER_CLASS_CRACKED_BAD
		if(51 to 75)
			to_chat(current_user,"<span class='danger'> Cyberlink beeps: HACKING [uppertext(cybernetic.name)] MAJOR FAILURE. CRACKING PROCESS ABORTED. MINOR ELECTROMAGNETIC PULSE DETECTED.</span>")
			empulse(current_user, 0, 1)
		if(76 to 99)
			to_chat(current_user,"<span class='danger'> Cyberlink beeps: HACKING [uppertext(cybernetic.name)] MAJOR FAILURE. CRACKING PROCESS ABORTED. MAJOR ELECTROMAGNETIC PULSE DETECTED.</span>")
			empulse(current_user, 1, 2)
		if(100 to INFINITY)
			to_chat(current_user,"<span class='danger'> Cyberlink beeps: HACKING [uppertext(cybernetic.name)] CRITICAL FAILURE. CRACKING PROCESS ABORTED. IMPLANT OVERHEATING IN 5 SECONDS.</span>")
			cybernetic.visible_message("<span class='danger'>[cybernetic.name] begins to flare and twitch as the electronics fry and sizzle!</span>")
			addtimer(CALLBACK(src, .proc/explode), 5 SECONDS)
	current_user.mind.adjust_experience(/datum/skill/implant_hacking,(4 - failed)*2)
	cleanup()

/obj/item/cyberlink_connector/proc/explode()
	SIGNAL_HANDLER

	dyn_explosion(get_turf(cybernetic),2,1)
	qdel(src)

/obj/item/cyberlink_connector/proc/game_update(end_game = FALSE)
	var/finished = TRUE
	var/failed = 0

	for(var/datum/hacking_minigame/game in game_list)
		if(!game.finished)
			finished = FALSE
			failed++

	if(finished)
		hack_success(game_list.len)

	if(end_game)
		hack_failure(failed)

/obj/item/cyberlink_connector/ui_data(mob/user)
	var/list/data = list()
	data["timeleft"] = current_timer_id ? timeleft(current_timer_id) : 0

	for(var/datum/hacking_minigame/game in game_list)
		data["games"] += list(game.get_simplified_image())
	return data

/obj/item/cyberlink_connector/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		if(!current_timer_id)
			var/time_left = (game_list.len * 10  - 2 * (game_list.len-1) + user.mind.get_skill_modifier(/datum/skill/implant_hacking, SKILL_TIME_MODIFIER)) SECONDS
			current_timer_id = addtimer(CALLBACK(src,.proc/game_update, TRUE),time_left,TIMER_STOPPABLE)
			START_PROCESSING(SSprocessing,src)
		ui = new(user, src, "Hacking", name)
		ui.open()

/obj/item/cyberlink_connector/ui_assets(mob/user)
	. = ..() || list()
	. += get_asset_datum(/datum/asset/simple/hacking)

/obj/item/cyberlink_connector/ui_act(action,list/params,datum/tgui/ui)
	. = ..()
	if(action == "click")
		var/xcord = text2num(params["xcord"])+1
		var/ycord = text2num(params["ycord"])+1 //we need to slightly offset these so they work properly
		var/minigame_id = text2num(params["id"])+1
		if(game_list[minigame_id] && !game_list[minigame_id].finished)
			game_list[minigame_id].board[xcord][ycord].rotate()
			game_list[minigame_id].game_check()
			game_update()
		return TRUE

