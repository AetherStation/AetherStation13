/datum/interaction_mode/intents
	var/intent = INTENT_HELP

/datum/interaction_mode/intents/update_istate(mob/M, modifiers)
	M.istate.reset()
	if (intent == INTENT_HELP)
		return
	M.istate.blocking = TRUE
	switch (intent)
		if (INTENT_DISARM)
			M.istate.secondary = TRUE
		if (INTENT_GRAB)
			M.istate.control = TRUE
		if (INTENT_HARM)
			M.istate.harm = TRUE

/datum/interaction_mode/intents/procure_hud(mob/M, datum/hud/H, robot = FALSE)
	var/atom/movable/screen/act_intent/AI
	AI = new /atom/movable/screen/act_intent()
	AI.hud = H
	AI.intents = src
	UI = AI
	return AI

/datum/interaction_mode/intents/state_changed(datum/interaction_state/state)
	if (state.harm)
		intent = INTENT_HARM
	else if (state.secondary)
		intent = INTENT_DISARM
	else if (state.control)
		intent = INTENT_GRAB
	else
		intent = INTENT_HELP
	update_istate(owner.mob, null)
	UI.icon_state = intent

/datum/interaction_mode/intents/keybind(type)
	var/static/next_intent = list(
		INTENT_HELP = INTENT_DISARM,
		INTENT_DISARM = INTENT_GRAB,
		INTENT_GRAB = INTENT_HARM,
		INTENT_HARM = INTENT_HELP)
	switch (type)
		if (0)
			intent = INTENT_HELP
		if (1)
			intent = INTENT_DISARM
		if (2)
			intent = INTENT_GRAB
		if (3)
			intent = INTENT_HARM
		if (4)
			intent = next_intent[intent]
	update_istate(owner.mob, null)
	UI.icon_state = intent

/datum/interaction_mode/intents/status()
	return "Intent: [intent]"
