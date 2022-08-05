/datum/interaction_state
	var/secondary = FALSE
	var/harm = FALSE
	var/alternate = FALSE
	var/control = FALSE // TODO: figure out a better name for this.
	var/blocking = FALSE
	var/sex = FALSE

/datum/interaction_state/proc/reset()
	control = alternate = harm = secondary = sex = FALSE

/datum/interaction_state/proc/logging()
	// This is pretty awful
	return "[harm ? "H" : ""][alternate ? "A" : ""][control ? "C" : ""][blocking ? "B" : ""][sex ? "B" : ""]"

/datum/interaction_state/harm
	harm = TRUE
	blocking = TRUE
