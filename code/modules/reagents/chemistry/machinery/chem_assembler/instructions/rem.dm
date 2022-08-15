/datum/chem_assembly_instruction/remove
	var/const/max_amount = 300
	var/transfer_left
	var/amount = 0

/datum/chem_assembly_instruction/remove/execute(obj/machinery/chem_assembler/A)
	var/TA = amount > A.transfer_speed ? A.transfer_speed : amount
	if (transfer_left)
		TA = transfer_left > TA ? TA : transfer_left
		transfer_left = max(0, transfer_left - TA)
	else if (amount > A.transfer_speed)
		transfer_left = amount - A.transfer_speed
	A.current_slot.remove_all(TA)
	if (A.current_slot.total_volume == 0)
		transfer_left = 0
		return CHEM_INST_SUCCESS
	return transfer_left ? CHEM_INST_RERUN : CHEM_INST_SUCCESS

/datum/chem_assembly_instruction/remove/parse_arguments(list/arguments, state)
	if (!arguments.len || arguments.len > 1)
		return "one argument only"
	var/S = text2num(arguments[1])
	if (!isnum(S))
		return "invalid number [arguments[1]]"
	if (S < 0 || S > max_amount)
		return "number too large/small 0 < [S] < [max_amount]"
	amount = S
	return
