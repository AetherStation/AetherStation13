/datum/chem_assembly_instruction/synthesise
	var/transfer_left
	var/reagent
	var/amount

/datum/chem_assembly_instruction/synthesise/execute(obj/machinery/chem_assembler/A, delta_time)
	var/TS = A.transfer_speed * delta_time
	var/TA = amount > TS ? TS : amount
	if (transfer_left)
		TA = transfer_left > TA ? TA : transfer_left
		transfer_left = max(0, transfer_left - TA)
	else if (amount > TS)
		transfer_left = amount - TS
	A.current_slot.add_reagent(reagent, TA)
	if (A.current_slot.total_volume == A.current_slot.maximum_volume)
		transfer_left = 0
		return CHEM_INST_SUCCESS
	return transfer_left ? CHEM_INST_RERUN : CHEM_INST_SUCCESS

/datum/chem_assembly_instruction/synthesise/parse_arguments(list/arguments, state)
	if (!arguments.len || arguments.len != 2)
		return "two arguments only"
	var/R = GLOB.name2reagent[arguments[1]]
	if (!R)
		return "invalid chemical [arguments[1]]"
	if (!(R in state["reagents"]))
		return "unable to synthesise chemical [arguments[1]]"
	reagent = R
	var/S = text2num(arguments[2])
	if (!isnum(S))
		return "invalid number [arguments[2]]"
	if (S < 0 || S > state["hold_size"])
		return "number too large/small 0 < [S] < [state["hold_size"]]"
	amount = S
	return
