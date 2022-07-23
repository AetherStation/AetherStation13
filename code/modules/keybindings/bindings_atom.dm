
/client
	var/tmp/mloop = FALSE
	var/tmp/client_move_dir = 0
	var/tmp/true_dir = 0
	var/tmp/key_presses = 0

/client/verb/MoveKey(Dir as num, State as num)
	// MK because BYOND sends the name as a string, this will make the packet smaller
	set name = "MK"
	set hidden = TRUE
	set instant = TRUE

	var/static/list/opposite_dirs = list(SOUTH,NORTH,NORTH|SOUTH,WEST,SOUTHWEST,NORTHWEST,NORTH|SOUTH|WEST,EAST,SOUTHEAST,NORTHEAST,NORTH|SOUTH|EAST,WEST|EAST,WEST|EAST|NORTH,WEST|EAST|SOUTH,WEST|EAST|NORTH|SOUTH)

	if (!client_move_dir)
		. = TRUE
	var/opposite = opposite_dirs[Dir]
	if (State)
		client_move_dir |= Dir
		key_presses |= Dir
		if (opposite & key_presses)
			client_move_dir &= ~opposite
	else
		client_move_dir &= ~Dir
		key_presses &= ~Dir
		if (opposite & key_presses)
			client_move_dir |= opposite
		else
			client_move_dir |= key_presses

	true_dir = client_move_dir
	if(. && true_dir)
		keyLoop(src)

/client/keyLoop()
	set waitfor = FALSE
	if (mloop || !mob.focus) return
	mloop = TRUE
	if(movement_locked)
		mob.focus?.keybind_face_direction(true_dir)
	else
		Move(get_step(src, true_dir), true_dir)
	while (true_dir && mob.focus)
		sleep (world.tick_lag)
		if (true_dir && mob.focus)
			if(movement_locked)
				mob.focus?.keybind_face_direction(true_dir)
			else
				Move(get_step(mob, true_dir), true_dir)
	mloop = FALSE
