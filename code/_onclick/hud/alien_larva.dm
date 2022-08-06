/datum/hud/larva
	has_interaction_ui = TRUE
	ui_style = 'icons/hud/screen_alien.dmi'

/datum/hud/larva/New(mob/owner)
	..()
	var/atom/movable/screen/using

	healths = new /atom/movable/screen/healths/alien()
	healths.hud = src
	infodisplay += healths

	alien_queen_finder = new /atom/movable/screen/alien/alien_queen_finder()
	alien_queen_finder.hud = src
	infodisplay += alien_queen_finder

	pull_icon = new /atom/movable/screen/pull()
	pull_icon.icon = 'icons/hud/screen_alien.dmi'
	pull_icon.update_appearance()
	pull_icon.screen_loc = ui_above_movement
	pull_icon.hud = src
	hotkeybuttons += pull_icon

	using = new/atom/movable/screen/language_menu
	using.screen_loc = ui_alien_language_menu
	using.hud = src
	static_inventory += using

	zone_select = new /atom/movable/screen/zone_sel/alien()
	zone_select.hud = src
	zone_select.update_appearance()
	static_inventory += zone_select
