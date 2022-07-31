/datum/chem_assembly_instruction/get
	var/transfer_left
	var/amount = 0

/datum/chem_assembly_instruction/get/execute(obj/machinery/chem_assembler/A, delta_time)
	var/TS = A.transfer_speed * delta_time
	var/TA = amount > TS ? TS : amount
	if (transfer_left)
		TA = transfer_left > TA ? TA : transfer_left
		transfer_left = max(0, transfer_left - TA)
	else if (amount > TS)
		transfer_left = amount - TS
	A.current_slot.trans_to(A.chem_holder, TA)
	if (A.chem_holder.total_volume == A.chem_holder.maximum_volume || A.current_slot.total_volume == 0)
		transfer_left = 0
		return CHEM_INST_SUCCESS
	return transfer_left ? CHEM_INST_RERUN : CHEM_INST_SUCCESS

/datum/chem_assembly_instruction/get/parse_arguments(list/arguments, state)
	if (!arguments.len || arguments.len > 1)
		return "one argument only"
	var/S = text2num(arguments[1])
	if (!isnum(S))
		return "invalid number [arguments[1]]"
	if (S < 0 || S > state["hold_size"])
		return "number too large/small 0 < [S] < [state["hold_size"]]"
	amount = S
	return
