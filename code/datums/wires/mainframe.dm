
/datum/wires/mainframe
	holder_type = /obj/machinery/mainframe/main_unit
	proper_name = "Main unit"

/datum/wires/mainframe/New(atom/holder)
	wires = list(WIRE_POWER, WIRE_INTERRUPT1, WIRE_INTERRUPT2)
	..()

/datum/wires/mainframe/on_pulse(wire)
	var/obj/machinery/mainframe/main_unit/MU = holder
	switch(wire)
		if(WIRE_POWER)
			MU.toggle_power()
		if(WIRE_INTERRUPT1)
			MU.processor.irq()
		if(WIRE_INTERRUPT2)
			MU.processor.nmi()
	..()

/datum/wires/mainframe/on_cut(wire, mend)
	var/obj/machinery/mainframe/main_unit/MU = holder
	if (wire == WIRE_POWER && !mend && MU.on)
		MU.toggle_power()
