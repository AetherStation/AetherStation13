/datum/interaction_mode/combat_mode
	var/combat_mode = FALSE
	shift_to_open_context_menu = TRUE

/datum/interaction_mode/combat_mode/update_istate(mob/M, modifiers)
	M.istate.harm = combat_mode
	M.istate.blocking = combat_mode
	M.istate.secondary = LAZYACCESS(modifiers, RIGHT_CLICK)
	M.istate.alternate = LAZYACCESS(modifiers, SHIFT_CLICK)
	M.istate.control = LAZYACCESS(modifiers, CTRL_CLICK)

/datum/interaction_mode/combat_mode/procure_hud(mob/M, datum/hud/H, robot = FALSE)
	var/atom/movable/screen/combattoggle/CT
	if (robot)
		CT = new /atom/movable/screen/combattoggle/robot()
	else
		CT = new /atom/movable/screen/combattoggle/flashy()
	CT.hud = H
	CT.icon = H.ui_style
	CT.combat_mode = src
	UI = CT
	return CT

/datum/interaction_mode/combat_mode/state_changed(datum/interaction_state/state)
	if (state.harm)
		combat_mode = TRUE
	else
		combat_mode = FALSE
	UI.update_icon_state()

/datum/interaction_mode/combat_mode/keybind(type)
	switch (type)
		if (0)
			combat_mode = TRUE
		if (1)
			combat_mode = FALSE
		if (3)
			combat_mode = !combat_mode
	UI.update_icon_state()
