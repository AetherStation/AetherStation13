/datum/chem_assembly_instruction/filter
	var/transfer_left
	var/reagent

/datum/chem_assembly_instruction/filter/execute(obj/machinery/chem_assembler/A, delta_time)
	if (!A.current_slot.has_reagent(reagent))
		transfer_left = 0
		return CHEM_INST_SUCCESS
	var/amount = A.current_slot.get_reagent_amount(reagent)
	var/TS = A.transfer_speed * delta_time
	var/TA = amount > TS ? TS : amount
	if (transfer_left)
		TA = transfer_left > TA ? TA : transfer_left
		transfer_left = max(0, transfer_left - TA)
	else if (amount > TS)
		transfer_left = amount - TS
	A.current_slot.trans_id_to(A.chem_holder, reagent, TA)
	if (A.chem_holder.total_volume == A.chem_holder.maximum_volume || !A.current_slot.has_reagent(reagent))
		transfer_left = 0
		return CHEM_INST_SUCCESS
	return transfer_left ? CHEM_INST_RERUN : CHEM_INST_SUCCESS

/datum/chem_assembly_instruction/filter/parse_arguments(list/arguments, state)
	if (!arguments.len || arguments.len > 1)
		return "one argument only"
	var/R = GLOB.name2reagent[arguments[1]]
	if (!R)
		return "invalid chemical [arguments[1]]"
	reagent = R
	return
