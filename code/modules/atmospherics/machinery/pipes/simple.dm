// Simple Pipe
// The regular pipe you see everywhere, including bent ones.

/obj/machinery/atmospherics/pipe/simple
	icon = 'icons/obj/atmospherics/pipes/simple.dmi'
	icon_state = "pipe11-3"

	name = "pipe"
	desc = "A one meter section of regular pipe."

	dir = SOUTH
	initialize_directions = SOUTH|NORTH
	pipe_flags = PIPING_CARDINAL_AUTONORMALIZE

	device_type = BINARY
	amendable = TRUE

	construction_type = /obj/item/pipe/binary/bendable
	pipe_state = "simple"

/obj/machinery/atmospherics/pipe/simple/SetInitDirections()
	if(ISDIAGONALDIR(dir))
		initialize_directions = dir
		return
	switch(dir)
		if(NORTH, SOUTH)
			initialize_directions = SOUTH|NORTH
		if(EAST, WEST)
			initialize_directions = EAST|WEST

/obj/machinery/atmospherics/pipe/simple/update_icon_state()
	icon_state = "pipe[nodes[1] ? "1" : "0"][nodes[2] ? "1" : "0"]-[piping_layer]"
	return ..()

/obj/machinery/atmospherics/pipe/simple/createAmend(turf/T, direction)
	var/obj/machinery/atmospherics/pipe/manifold/new_pipe = new /obj/machinery/atmospherics/pipe/manifold/(T)
	new_pipe.setDir((initialize_directions | direction) ^ 15)
	return new_pipe
